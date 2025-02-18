// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WorkoutKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "WorkoutKit",
            targets: ["WorkoutKit"]
        ),
    ],

    targets: [
        .binaryTarget(
            name: "WorkoutKit",
            path: "FZWorkoutKit.xcframework"
        )
    ]
)
