// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CursorShared",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CursorShared",
            targets: ["CursorShared"]
        ),
    ],
    targets: [
        .target(
            name: "CursorShared",
            path: "Sources/CursorShared"
        ),
    ]
)
