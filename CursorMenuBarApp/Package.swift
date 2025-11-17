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
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "CursorMenuBarApp",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .testTarget(
            name: "CursorMenuBarAppTests",
            dependencies: ["CursorMenuBarApp"]
        ),
    ]
)

