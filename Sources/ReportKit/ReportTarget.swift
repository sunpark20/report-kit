import Foundation

public struct ReportTarget: Equatable, Sendable {
    public static let issueURL = "https://github.com/sunpark20/errorreport/issues/new"

    public let appID: String
    public let displayName: String
    public let template: String

    public init(appID: String, displayName: String, template: String) {
        self.appID = appID
        self.displayName = displayName
        self.template = template
    }

    public func github(metadata: ReportMetadata) -> ReportLink? {
        guard var components = URLComponents(string: Self.issueURL) else { return nil }

        var queryItems = [
            URLQueryItem(name: "template", value: template),
            URLQueryItem(name: "version", value: metadata.version),
            URLQueryItem(name: "build", value: metadata.build),
            URLQueryItem(name: "os", value: metadata.os),
            URLQueryItem(name: "device", value: metadata.device),
        ]

        if let diagnostics = limitedDiagnostics(metadata.diagnostics) {
            queryItems.append(URLQueryItem(name: "diagnostics", value: diagnostics))
        }

        components.queryItems = queryItems
        guard let url = components.url else { return nil }
        return ReportLink(url: url, fallbackText: url.absoluteString)
    }

    private func limitedDiagnostics(_ diagnostics: String?) -> String? {
        guard let trimmed = diagnostics?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else { return "unknown" }
        return String(trimmed.prefix(200))
    }
}
