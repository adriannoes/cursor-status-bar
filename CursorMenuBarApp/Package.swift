// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CursorMenuBarApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "CursorMenuBarApp",
            targets: ["CursorMenuBarApp"]
        ),
        .executable(
            name: "APIInvestigator",
            targets: ["APIInvestigator"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0"),
        .package(path: "../CursorShared"),
    ],
    targets: [
        .executableTarget(
            name: "CursorMenuBarApp",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "CursorShared", package: "CursorShared"),
            ]
        ),
        .executableTarget(
            name: "APIInvestigator",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "CursorShared", package: "CursorShared"),
            ],
            path: "Sources/APIInvestigator"
        ),
        .testTarget(
            name: "CursorMenuBarAppTests",
            dependencies: ["CursorMenuBarApp"]
        ),
    ]
)

