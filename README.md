# ReportKit

Swift Package for opening the public GitHub Issue Form used by Sunguk's apps.

> ReportKit development is now maintained in [errorreport](https://github.com/sunpark20/errorreport). The `ReportKit` and `ReportKitUI` products remain source-compatible; the existing 1.0.x tags are kept here for migration and rollback.

App-specific report targets are generated from each app repository's `shipping.yml`, so app IDs, display names, and Issue Form template names do not need to be duplicated by hand.

```swift
import ReportKit

let target = ReportTargets.gnomon

if let link = target.github(metadata: .current()) {
    ReportOpener.open(link)
}
```

For a dynamic app ID:

```swift
let target = ReportTargets.target(forAppID: "gnomon")
```

Regenerate the catalog after changing a `shipping.yml`:

```sh
python3 scripts/generate_targets.py
```

Verify that the committed generated file matches the manifests:

```sh
python3 scripts/generate_targets.py --check
swift test
```

The generator reads `app.id`, `app.display_name`, and `reporting.template` from the manifests supplied through `--shipping-root`. It never derives app IDs from directory or repository names.

The low-level `ReportTarget(...)` initializer remains public for callers that need a custom or non-catalog target.

`ReportKitUI` provides a bilingual SwiftUI support sheet with a GitHub-only reporting action and an app-information copy action.
