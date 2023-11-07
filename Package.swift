// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ToolbarManager",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ToolbarManager",
            targets: ["ToolbarManager"]),
    ],
    targets: [
        .target(
            name: "ToolbarManager")
    ]
)
