import XCTest
@testable import ReportKit

final class GeneratedReportTargetsTests: XCTestCase {
    func testGeneratedCatalogContainsAllShippingTargets() {
        XCTAssertEqual(ReportTargets.all.count, 13)
        XCTAssertEqual(Set(ReportTargets.all.map(\.appID)).count, ReportTargets.all.count)
        XCTAssertEqual(Set(ReportTargets.all.map(\.template)).count, ReportTargets.all.count)
    }

    func testLookupReturnsGeneratedTargets() {
        XCTAssertEqual(ReportTargets.target(forAppID: "gnomon"), ReportTargets.gnomon)
        XCTAssertEqual(ReportTargets.target(forAppID: "book"), ReportTargets.book)
        XCTAssertEqual(ReportTargets.target(forAppID: "memory-palace"), ReportTargets.memoryPalace)
        XCTAssertEqual(ReportTargets.target(forAppID: "yt-bulk-downloader"), ReportTargets.ytBulkDownloader)
        XCTAssertNil(ReportTargets.target(forAppID: "not-a-real-app"))
    }

    func testGeneratedTemplatesMatchAppIDs() {
        for target in ReportTargets.all {
            XCTAssertEqual(target.template, "\(target.appID)-bug.yml")
        }
    }
}
