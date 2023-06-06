// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SingleFactorAuth",
    platforms: [
        .iOS(.v14), .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SingleFactorAuth",
            targets: ["SingleFactorAuth"])
    ],
    dependencies: [
        .package(url: "https://github.com/torusresearch/fetch-node-details-swift.git", from: "4.0.1"),
        .package(url: "https://github.com/torusresearch/torus-utils-swift.git", from: "5.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0"),
        .package(name: "SessionManager", url: "https://github.com/Web3Auth/session-manager-swift.git", from: "2.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SingleFactorAuth",
            dependencies: [
                .product(name: "FetchNodeDetails", package: "fetch-node-details-swift"),
                .product(name: "TorusUtils", package: "torus-utils-swift"),
                .product(name: "SessionManager", package: "SessionManager")
            ]),
        .testTarget(
            name: "SingleFactorAuthTests",
            dependencies: ["SingleFactorAuth", .product(name: "JWTKit", package: "jwt-kit")])
    ]
)
