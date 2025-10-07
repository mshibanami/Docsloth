// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [
        .macOS(.v13),
    ],
    products: [],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown", .upToNextMajor(from: "0.7.1")),
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.29.4")),
        .package(url: "https://github.com/objecthub/swift-markdownkit", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/JohnSundell/Ink.git", .upToNextMajor(from: "0.6.0")),
        .package(name: "Docsloth", path: "../"),
    ],
    targets: [
        .executableTarget(
            name: "MarkdownBenchmark",
            dependencies: [
                .product(name: "DocslothMarkdownIt", package: "Docsloth"),
                .product(name: "DocslothMarkdownItGFM", package: "Docsloth"),
                .product(name: "DocslothMarkdownItGFMCJKFriendly", package: "Docsloth"),
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "MarkdownKit", package: "swift-markdownkit"),
                .product(name: "Ink", package: "Ink"),
            ],
            path: "Benchmarks/Markdown",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),
    ]
)
