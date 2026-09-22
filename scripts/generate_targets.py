#!/usr/bin/env python3
"""Generate ReportKit's public ReportTargets catalog from app shipping.yml manifests."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SHIPPING_ROOT = REPOSITORY_ROOT.parent.parent / "0.shipping"
DEFAULT_OUTPUT = REPOSITORY_ROOT / "Sources" / "ReportKit" / "ReportTargets.generated.swift"

SWIFT_KEYWORDS = {
    "associatedtype", "class", "deinit", "enum", "extension", "fileprivate",
    "func", "import", "init", "inout", "internal", "let", "open", "operator",
    "private", "protocol", "public", "rethrows", "static", "struct", "subscript",
    "typealias", "var", "break", "case", "continue", "default", "defer", "do",
    "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return",
    "switch", "where", "while", "as", "catch", "false", "is", "nil", "super",
    "self", "Self", "throw", "throws", "true", "try", "_",
}


@dataclass(frozen=True)
class App:
    app_id: str
    display_name: str
    template: str
    property_name: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--shipping-root",
        type=Path,
        default=DEFAULT_SHIPPING_ROOT,
        help="directory containing app repositories with shipping.yml manifests",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="generated Swift source path",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="verify the generated Swift source is current without writing it",
    )
    return parser.parse_args()


def fail(message: str) -> None:
    raise SystemExit(f"generate_targets.py: {message}")


def parse_scalar(raw: str) -> str:
    value = raw.strip()
    if not value:
        return ""

    if value.startswith('"'):
        try:
            decoded = json.loads(value)
        except json.JSONDecodeError as error:
            fail(f"invalid double-quoted YAML scalar {value!r}: {error}")
        if not isinstance(decoded, str):
            fail(f"expected string scalar, got {value!r}")
        return decoded

    if value.startswith("'"):
        if not value.endswith("'") or len(value) < 2:
            fail(f"invalid single-quoted YAML scalar {value!r}")
        return value[1:-1].replace("''", "'")

    # The shipping manifests use simple scalar values for the fields consumed
    # here. Strip only a conventional whitespace-prefixed inline comment.
    return re.split(r"\s+#", value, maxsplit=1)[0].strip()


def read_manifest(path: Path) -> dict[tuple[str, str], str]:
    current_section: str | None = None
    values: dict[tuple[str, str], str] = {}

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        if not raw_line.strip() or raw_line.lstrip().startswith("#"):
            continue

        indent = len(raw_line) - len(raw_line.lstrip(" "))
        stripped = raw_line.strip()

        if indent == 0:
            if ":" not in stripped:
                current_section = None
                continue
            key, _ = stripped.split(":", 1)
            current_section = key.strip()
            continue

        if indent == 2 and current_section in {"app", "reporting"} and ":" in stripped:
            key, raw_value = stripped.split(":", 1)
            values[(current_section, key.strip())] = parse_scalar(raw_value)

    return values


def swift_property_name(app_id: str) -> str:
    parts = [part for part in re.split(r"[^A-Za-z0-9]+", app_id) if part]
    if not parts:
        fail(f"cannot derive a Swift property name from app.id {app_id!r}")

    first = parts[0].lower()
    rest = "".join(part[:1].upper() + part[1:] for part in parts[1:])
    name = first + rest

    if name[0].isdigit():
        name = "app" + name[:1].upper() + name[1:]
    if name in SWIFT_KEYWORDS:
        name = "app" + name[:1].upper() + name[1:]
    return name


def load_apps(shipping_root: Path) -> list[App]:
    manifests = sorted(shipping_root.glob("*/shipping.yml"))
    if not manifests:
        fail(f"no shipping.yml manifests found under {shipping_root}")

    apps: list[App] = []
    for manifest in manifests:
        values = read_manifest(manifest)
        template = values.get(("reporting", "template"), "").strip()
        if not template:
            continue

        app_id = values.get(("app", "id"), "").strip()
        display_name = values.get(("app", "display_name"), "").strip()
        if not app_id:
            fail(f"{manifest}: app.id is required when reporting.template is present")
        if not display_name:
            fail(f"{manifest}: app.display_name is required when reporting.template is present")
        if template != f"{app_id}-bug.yml":
            fail(f"{manifest}: reporting.template must be {app_id}-bug.yml, got {template!r}")

        apps.append(
            App(
                app_id=app_id,
                display_name=display_name,
                template=template,
                property_name=swift_property_name(app_id),
            )
        )

    if not apps:
        fail(f"no report-enabled shipping.yml manifests found under {shipping_root}")

    app_ids = [app.app_id for app in apps]
    templates = [app.template for app in apps]
    properties = [app.property_name for app in apps]
    if len(set(app_ids)) != len(app_ids):
        fail("duplicate app.id values found")
    if len(set(templates)) != len(templates):
        fail("duplicate reporting.template values found")
    if len(set(properties)) != len(properties):
        fail("generated Swift property names would collide")

    return sorted(apps, key=lambda app: app.app_id)


def swift_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def render(apps: list[App]) -> str:
    lines = [
        "// This file is generated from shipping.yml manifests.",
        "// Run: python3 scripts/generate_targets.py",
        "// Do not edit by hand.",
        "",
        "public enum ReportTargets {",
    ]

    for app in apps:
        lines.extend(
            [
                f"    public static let {app.property_name} = ReportTarget(",
                f"        appID: {swift_string(app.app_id)},",
                f"        displayName: {swift_string(app.display_name)},",
                f"        template: {swift_string(app.template)}",
                "    )",
                "",
            ]
        )

    lines.append("    public static let all: [ReportTarget] = [")
    for app in apps:
        lines.append(f"        {app.property_name},")
    lines.extend(["    ]", ""])

    lines.append("    public static func target(forAppID appID: String) -> ReportTarget? {")
    lines.append("        switch appID {")
    for app in apps:
        lines.append(f"        case {swift_string(app.app_id)}: return {app.property_name}")
    lines.extend(
        [
            "        default: return nil",
            "        }",
            "    }",
            "}",
            "",
        ]
    )
    return "\n".join(lines)


def main() -> None:
    args = parse_args()
    shipping_root = args.shipping_root.expanduser().resolve()
    output = args.output.expanduser().resolve()
    generated = render(load_apps(shipping_root))

    if args.check:
        if not output.exists():
            fail(f"generated file is missing: {output}")
        current = output.read_text(encoding="utf-8")
        if current != generated:
            fail(f"generated file is stale: {output}")
        print(f"verified {len(load_apps(shipping_root))} ReportTargets from {shipping_root}")
        return

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(generated, encoding="utf-8")
    print(f"generated {len(load_apps(shipping_root))} ReportTargets -> {output}")


if __name__ == "__main__":
    main()
