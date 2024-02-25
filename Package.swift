// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyLanScanner",
    products: [
        .library(
            name: "MyLanScanner",
            targets: ["MyLanScanner"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MyLanScanner",
            dependencies: ["LanScanInternal"]
        ),
        .target(
            name: "LanScanInternal",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "LanScannerTests",
            dependencies: []),
    ]
)
