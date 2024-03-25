// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SingleFactorAuth",
    platforms: [
        .iOS(.v14), .macOS(.v11)
    ],
    products: [

        .library(
            name: "SingleFactorAuth",
            targets: ["SingleFactorAuth"])
    ],
    dependencies: [
        .package(url: "https://github.com/torusresearch/fetch-node-details-swift.git", from: "5.1.0"),
        .package(url: "https://github.com/torusresearch/torus-utils-swift.git", from: "8.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0"),
        .package(url: "https://github.com/Web3Auth/session-manager-swift.git", from: "3.0.1")
    ],
    targets: [
        .target(
            name: "SingleFactorAuth",
            dependencies: [
                .product(name: "FetchNodeDetails", package: "fetch-node-details-swift"),
                .product(name: "TorusUtils", package: "torus-utils-swift"),
                .product(name: "SessionManager", package: "session-manager-swift")
            ]),
        .testTarget(
            name: "SingleFactorAuthTests",
            dependencies: ["SingleFactorAuth", .product(name: "JWTKit", package: "jwt-kit")])
    ]
)
