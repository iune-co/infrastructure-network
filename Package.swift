// swift-tools-version: 6.0.0

import PackageDescription

struct InfrastructureNetworkPackage {
        static let name = "InfrastructureNetwork"
        
        static let testTargetName = name + "Tests"
        
        static var target: Target.Dependency {
                .target(name: name)
        }
}

let package = Package(
        name: InfrastructureNetworkPackage.name,
        platforms: [.iOS(.v17)],
        products: [
                .library(
                        name: InfrastructureNetworkPackage.name,
                        targets: [
                                InfrastructureNetworkPackage.name
                        ]
                )
        ],
        targets: [
                .target(name: InfrastructureNetworkPackage.name),
                .testTarget(
                        name: InfrastructureNetworkPackage.testTargetName,
                        dependencies: [
                                InfrastructureNetworkPackage.target
                        ]
                ),
        ]
)
