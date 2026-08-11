import Foundation

#if canImport(UIKit)
import UIKit
#endif

public struct ReportMetadata: Equatable, Sendable {
    public let version: String
    public let build: String
    public let os: String
    public let device: String
    public let diagnostics: String?

    public init(
        version: String,
        build: String,
        os: String,
        device: String,
        diagnostics: String? = nil
    ) {
        self.version = Self.normalized(version)
        self.build = Self.normalized(build)
        self.os = Self.normalized(os)
        self.device = Self.normalized(device)
        self.diagnostics = diagnostics
    }

    public static func current(diagnostics: String? = nil) -> Self {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = info?["CFBundleVersion"] as? String ?? "unknown"

        #if canImport(UIKit)
        let device = UIDevice.current
        return Self(
            version: version,
            build: build,
            os: "\(device.systemName) \(device.systemVersion)",
            device: device.model,
            diagnostics: diagnostics
        )
        #else
        let system = ProcessInfo.processInfo.operatingSystemVersion
        return Self(
            version: version,
            build: build,
            os: "macOS \(system.majorVersion).\(system.minorVersion).\(system.patchVersion)",
            device: "Mac",
            diagnostics: diagnostics
        )
        #endif
    }

    private static func normalized(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "unknown" : trimmed
    }
}
