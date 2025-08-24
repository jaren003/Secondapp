// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LunchManager",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "LunchManager",
            targets: ["LunchManager"]
        )
    ],
    targets: [
        .executableTarget(
            name: "LunchManager",
            path: "Sources/LunchManager"
        )
    ]
)
