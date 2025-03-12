# WorkoutKit iOS SDK
This repository includes WorkoutKit XCFramework and a demo app.

## Requirements
WorkoutKit SDK supports iOS 15.0 and later and requires Swift 5.9 with Xcode 15.0 or newer.

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding WorkoutKit as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift` or the Package list in Xcode.

```swift
dependencies: [
    .package(url: "https://github.com/fysiki/workoutkit-ios-sdk.git", .upToNextMajor(from: "1.0.0"))
]
```

### Manually

If you prefer not to use SPM, you can integrate WorkoutKit into your project manually by copying the XCFramework folder.

## Documentation
WorkoutKit documentation is provided in an archive you can open within Xcode.

You will find the archive in the [FZWorkoutKit.doccarchive.zip](FZWorkoutKit.doccarchive.zip) file. Just unzip it and open with Xcode.

The archive includes:
- A start guide to help you dive in WorkoutKit.
- Detailed information about each public things you can use (basic information is provided live in the code with headers documentation).