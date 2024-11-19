// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XYPlotKit",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "XYPlotKit",
            targets: ["XYPlotKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/RickStreet/DoubleKit.git", from: "1.0.8"),
        .package(url: "https://github.com/RickStreet/NSStringKit.git", from: "1.0.23"),
        .package(url: "https://github.com/RickStreet/NSViewMode", from: "1.0.5"),
        .package(url: "https://github.com/RickStreet/AxisSpacing.git", from: "1.1.1")

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "XYPlotKit",
            dependencies: ["DoubleKit", "NSStringKit", "NSViewMode", "AxisSpacing"]),
        .testTarget(
            name: "XYPlotKitTests",
            dependencies: ["XYPlotKit", "DoubleKit", "NSStringKit", "NSViewMode", "AxisSpacing"]),
    ]
)
