// swift-tools-version: 5.8.1

import PackageDescription

let package = Package(
    name: "InfrastructureNetwork",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "InfrastructureNetwork",
            targets: [
                "InfrastructureNetwork"
            ]
        ),
        .library(
            name: "InfrastructureNetworkAPI",
            targets: [
                "InfrastructureNetworkAPI"
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/iune-co/infrastructure-dependency-container.git",
            exact: Version("2.0.1")
        )
    ],
    targets: [
        .target(
            name: "InfrastructureNetwork",
            dependencies: [
				"InfrastructureNetworkAPI",
                .product(
                    name: "InfrastructureDependencyContainer",
                    package: "infrastructure-dependency-container"
                )
            ]
        ),
        .target(
            name: "InfrastructureNetworkAPI",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "InfrastructureNetworkTests",
            dependencies: [
                "InfrastructureNetwork"
            ]
        ),
    ]
)
