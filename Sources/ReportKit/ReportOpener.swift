import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum ReportOpener {
    public enum Status: Equatable, Sendable {
        case opened
        case copiedToClipboard
        case unavailable

        public var userMessage: String? {
            switch self {
            case .opened:
                nil
            case .copiedToClipboard:
                "링크를 열 수 없어 주소를 클립보드에 복사했습니다. The report link was copied to the clipboard."
            case .unavailable:
                "신고 링크를 열거나 복사할 수 없습니다. The report link could not be opened or copied."
            }
        }
    }

    @MainActor
    @discardableResult
    public static func open(_ link: ReportLink) -> Status {
        #if canImport(UIKit)
        guard UIApplication.shared.canOpenURL(link.url) else {
            return copy(link.fallbackText)
        }
        UIApplication.shared.open(link.url)
        return .opened
        #elseif canImport(AppKit)
        guard NSWorkspace.shared.open(link.url) else {
            return copy(link.fallbackText)
        }
        return .opened
        #else
        .unavailable
        #endif
    }

    @MainActor
    @discardableResult
    public static func copy(_ text: String) -> Status {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        return .copiedToClipboard
        #elseif canImport(AppKit)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        return .copiedToClipboard
        #else
        return .unavailable
        #endif
    }
}
