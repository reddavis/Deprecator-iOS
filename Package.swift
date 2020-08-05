// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Damson",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "Damson",
            targets: ["Damson"]),
    ],
    targets: [
        .target(
            name: "Damson",
            dependencies: [],
            path: "Damson"),
        .testTarget(
            name: "DamsonTests",
            dependencies: ["Damson"],
            path: "DamsonTests"),
    ]
)
