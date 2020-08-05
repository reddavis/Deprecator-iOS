// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Deprecator",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "Deprecator",
            targets: ["Deprecator"]),
    ],
    targets: [
        .target(
            name: "Deprecator",
            dependencies: [],
            path: "Deprecator"),
        .testTarget(
            name: "DeprecatorTests",
            dependencies: ["Deprecator"],
            path: "DeprecatorTests"),
    ]
)
