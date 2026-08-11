import XCTest
@testable import ReportKit

final class GnomonReportLinksTests: XCTestCase {
    private let target = ReportTarget(
        appID: "gnomon",
        displayName: "Gnomon",
        template: "gnomon-bug.yml"
    )
    private let metadata = ReportMetadata(
        version: "1.7.2 beta",
        build: "42",
        os: "macOS 15.6",
        device: "Mac",
        diagnostics: "오류 코드: sample"
    )

    func testGitHubLinkUsesFormFieldIDsAndPreservesUnicode() throws {
        let link = try XCTUnwrap(target.github(metadata: metadata))
        let components = try XCTUnwrap(URLComponents(url: link.url, resolvingAgainstBaseURL: false))
        let values = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).compactMap { item in
            item.value.map { (item.name, $0) }
        })

        XCTAssertEqual(values["template"], "gnomon-bug.yml")
        XCTAssertEqual(values["version"], metadata.version)
        XCTAssertEqual(values["build"], metadata.build)
        XCTAssertEqual(values["os"], metadata.os)
        XCTAssertEqual(values["device"], metadata.device)
        XCTAssertEqual(values["diagnostics"], metadata.diagnostics)
        XCTAssertNil(values["labels"])
        XCTAssertNil(values["body"])
    }

    func testDiagnosticsAreLimitedToTwoHundredCharacters() throws {
        let longMetadata = ReportMetadata(
            version: "1",
            build: "1",
            os: "macOS 15",
            device: "Mac",
            diagnostics: String(repeating: "가", count: 250)
        )
        let link = try XCTUnwrap(target.github(metadata: longMetadata))
        let components = try XCTUnwrap(URLComponents(url: link.url, resolvingAgainstBaseURL: false))
        let diagnostics = components.queryItems?.first(where: { $0.name == "diagnostics" })?.value

        XCTAssertEqual(diagnostics?.count, 200)
    }
}
