import XCTest
@testable import ReportKit

final class SpamCall070ReportLinksTests: XCTestCase {
    private let target = ReportTarget(
        appID: "spamcall070",
        displayName: "SpamCall070",
        template: "spamcall070-bug.yml"
    )
    private let metadata = ReportMetadata(
        version: "1.3 beta",
        build: "6",
        os: "iOS 18.6",
        device: "iPhone",
        diagnostics: "enabled=58/58; failed_blocks=2; error_codes=unknown"
    )

    func testGitHubLinkUsesFormFieldIDsAndPreservesUnicode() throws {
        let link = try XCTUnwrap(target.github(metadata: metadata))
        let components = try XCTUnwrap(URLComponents(url: link.url, resolvingAgainstBaseURL: false))
        let values = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).compactMap { item in
            item.value.map { (item.name, $0) }
        })

        XCTAssertEqual(values["template"], "spamcall070-bug.yml")
        XCTAssertEqual(values["version"], metadata.version)
        XCTAssertEqual(values["build"], metadata.build)
        XCTAssertEqual(values["os"], metadata.os)
        XCTAssertEqual(values["device"], metadata.device)
        XCTAssertEqual(values["diagnostics"], metadata.diagnostics)
        XCTAssertNil(values["labels"])
        XCTAssertNil(values["body"])
    }

    func testEmptyMetadataUsesUnknownInsteadOfBlank() throws {
        let metadata = ReportMetadata(version: "", build: "", os: "", device: "")
        let link = try XCTUnwrap(target.github(metadata: metadata))
        let components = try XCTUnwrap(URLComponents(url: link.url, resolvingAgainstBaseURL: false))
        let values = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).compactMap { item in
            item.value.map { (item.name, $0) }
        })

        XCTAssertEqual(values["version"], "unknown")
        XCTAssertEqual(values["build"], "unknown")
        XCTAssertEqual(values["os"], "unknown")
        XCTAssertEqual(values["device"], "unknown")
    }
}
