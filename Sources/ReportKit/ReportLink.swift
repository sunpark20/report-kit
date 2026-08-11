import Foundation

public struct ReportLink: Equatable, Sendable {
    public let url: URL
    public let fallbackText: String

    public init(url: URL, fallbackText: String) {
        self.url = url
        self.fallbackText = fallbackText
    }
}
