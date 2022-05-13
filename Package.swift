// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftXMLParser",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SwiftXMLParser",
            targets: ["SwiftXMLParser"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftXMLParser",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftXMLParserTests",
            dependencies: ["SwiftXMLParser"],
            resources: [.copy("simple.xml")]
        )
    ]
)
