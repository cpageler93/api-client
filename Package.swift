// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "api-client",
    platforms: [
       .macOS(.v10_15),
       .iOS(.v10),
       .tvOS(.v13)
    ],
    products: [
        .library(name: "APIClient", targets: ["APIClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.1.1")
    ],
    targets: [
        .target(name: "APIClient", dependencies: [
            .product(name: "AsyncHTTPClient", package: "async-http-client")
        ]),
        .testTarget(name: "APIClientTests", dependencies: ["APIClient"]),
    ]
)
