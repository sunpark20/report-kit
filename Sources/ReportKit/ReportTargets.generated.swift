// This file is generated from shipping.yml manifests.
// Run: python3 scripts/generate_targets.py
// Do not edit by hand.

public enum ReportTargets {
    public static let book = ReportTarget(
        appID: "book",
        displayName: "Book",
        template: "book-bug.yml"
    )

    public static let breaklockTimer = ReportTarget(
        appID: "breaklock-timer",
        displayName: "Breaklock Timer",
        template: "breaklock-timer-bug.yml"
    )

    public static let callninja = ReportTarget(
        appID: "callninja",
        displayName: "CallNinja - Spam Call Blocker",
        template: "callninja-bug.yml"
    )

    public static let centuryiris = ReportTarget(
        appID: "centuryiris",
        displayName: "Century Iris",
        template: "centuryiris-bug.yml"
    )

    public static let earth = ReportTarget(
        appID: "earth",
        displayName: "Earth: World Time & Sky",
        template: "earth-bug.yml"
    )

    public static let eatwater = ReportTarget(
        appID: "eatwater",
        displayName: "The Bird That Drinks Water",
        template: "eatwater-bug.yml"
    )

    public static let gnomon = ReportTarget(
        appID: "gnomon",
        displayName: "Gnomon",
        template: "gnomon-bug.yml"
    )

    public static let memoryPalace = ReportTarget(
        appID: "memory-palace",
        displayName: "기억의궁전 뇌모닉",
        template: "memory-palace-bug.yml"
    )

    public static let quickQuit = ReportTarget(
        appID: "quick-quit",
        displayName: "Quick Quit",
        template: "quick-quit-bug.yml"
    )

    public static let snapcart = ReportTarget(
        appID: "snapcart",
        displayName: "SnapCart Grocery Calculator",
        template: "snapcart-bug.yml"
    )

    public static let spamcall070 = ReportTarget(
        appID: "spamcall070",
        displayName: "SpamCall070",
        template: "spamcall070-bug.yml"
    )

    public static let ytBulkDownloader = ReportTarget(
        appID: "yt-bulk-downloader",
        displayName: "YT Chita",
        template: "yt-bulk-downloader-bug.yml"
    )

    public static let ytdi = ReportTarget(
        appID: "ytdi",
        displayName: "ytdi",
        template: "ytdi-bug.yml"
    )

    public static let all: [ReportTarget] = [
        book,
        breaklockTimer,
        callninja,
        centuryiris,
        earth,
        eatwater,
        gnomon,
        memoryPalace,
        quickQuit,
        snapcart,
        spamcall070,
        ytBulkDownloader,
        ytdi,
    ]

    public static func target(forAppID appID: String) -> ReportTarget? {
        switch appID {
        case "book": return book
        case "breaklock-timer": return breaklockTimer
        case "callninja": return callninja
        case "centuryiris": return centuryiris
        case "earth": return earth
        case "eatwater": return eatwater
        case "gnomon": return gnomon
        case "memory-palace": return memoryPalace
        case "quick-quit": return quickQuit
        case "snapcart": return snapcart
        case "spamcall070": return spamcall070
        case "yt-bulk-downloader": return ytBulkDownloader
        case "ytdi": return ytdi
        default: return nil
        }
    }
}
