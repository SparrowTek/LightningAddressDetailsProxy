// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "API",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(name: "API", targets: ["API"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-cloud/swift-cloud", branch: "main"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime", branch: "main"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events", branch: "main"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0"),
    ],
    targets: [
        .executableTarget(
            name: "API",
            dependencies: [
                .product(name: "CloudSDK", package: "swift-cloud"),
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
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
