// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ViewInspector",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v7)
    ],
    products: [
        .library(
            name: "ViewInspector", targets: ["ViewInspector"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.41.0"),
    ],
    targets: [
        .target(
            name: "ViewInspector",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"),
            ]),
        .testTarget(
            name: "ViewInspectorTests",
            dependencies: [
                "ViewInspector",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"),
            ],
            resources: [.process("TestResources")]),
    ]
)
