// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ReportKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v15),
    ],
    products: [
        .library(name: "ReportKit", targets: ["ReportKit"]),
        .library(name: "ReportKitUI", targets: ["ReportKitUI"]),
    ],
    targets: [
        .target(name: "ReportKit"),
        .target(name: "ReportKitUI", dependencies: ["ReportKit"]),
        .testTarget(name: "ReportKitTests", dependencies: ["ReportKit"]),
    ]
)
