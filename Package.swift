// swift-tools-version: 6.0.0

import PackageDescription

let package = Package(
        name: "InfrastructureNetwork",
        platforms: [
                .iOS(.v16),
                .macOS(.v12),
                .watchOS(.v8),
                .tvOS(.v15),
        ],
        products: [
                .library(
                        name: "InfrastructureNetwork",
                        targets: [
                                "InfrastructureNetwork"
                        ]
                )
        ],
        targets: [
                .target(name: "InfrastructureNetwork"),
                .testTarget(
                        name: "InfrastructureNetworkTests",
                        dependencies: [
                                "InfrastructureNetwork"
                        ]
                ),
        ]
)
