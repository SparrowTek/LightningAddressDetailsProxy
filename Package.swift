// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "API",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "API", targets: ["API"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-cloud/swift-cloud.git", branch: "main"),
        .package(url: "https://github.com/soto-project/soto.git", from: "7.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0"),
    ],
    targets: [
        .executableTarget(
            name: "API",
            dependencies: [
                .product(name: "SotoLambda", package: "soto"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ],
            path: "Sources/API"
        ),
        .executableTarget(name: "Infra",
            dependencies: [
                .product(name: "Cloud", package: "swift-cloud"),
            ],
            path: "Sources/Infra"
        ),
    ]
)
