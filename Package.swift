// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Docsloth",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .macCatalyst(.v15),
        .driverKit(.v21),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "DocslothUI",
            targets: ["DocslothUI", "DocslothCore"]
        ),
        .library(
            name: "DocslothGitHubStyle",
            targets: ["DocslothGitHubStyle", "DocslothCore", "DocslothUI"]
        ),
        .library(
            name: "DocslothMarkdownItShared",
            targets: ["DocslothMarkdownItShared", "DocslothCore"]
        ),
        .library(
            name: "DocslothMarkdownIt",
            targets: ["DocslothMarkdownIt", "DocslothCore"]
        ),
        .library(
            name: "DocslothMarkdownItGFM",
            targets: ["DocslothMarkdownItGFM", "DocslothCore"]
        ),
        .library(
            name: "DocslothMarkdownItGFMCJKFriendly",
            targets: ["DocslothMarkdownItGFMCJKFriendly", "DocslothCore"]
        ),
        .library(
            name: "DocslothAsciidoctor",
            targets: ["DocslothAsciidoctor", "DocslothCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DocslothCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log", condition: .when(platforms: [.linux, .windows])),
            ],
            path: "Sources/Core",
        ),
        .target(
            name: "DocslothUI",
            dependencies: ["DocslothCore"],
            path: "Sources/UI",
        ),
        .target(
            name: "DocslothGitHubStyle",
            dependencies: ["DocslothCore", "DocslothUI"],
            path: "Sources/GitHubStyle",
            resources: [.process("Resources")],
        ),
        .target(
            name: "DocslothMarkdownItShared",
            dependencies: ["DocslothCore"],
            path: "Sources/MarkdownItShared",
        ),
        .target(
            name: "DocslothMarkdownIt",
            dependencies: ["DocslothCore", "DocslothMarkdownItShared"],
            path: "Sources/MarkdownIt",
            resources: [.process("../../js/dist/markdown-it.iife.js")],
        ),
        .target(
            name: "DocslothMarkdownItGFM",
            dependencies: ["DocslothCore", "DocslothMarkdownItShared"],
            path: "Sources/MarkdownItGFM",
            resources: [.process("../../js/dist/markdown-it-gfm.iife.js")],
        ),
        .target(
            name: "DocslothMarkdownItGFMCJKFriendly",
            dependencies: ["DocslothCore", "DocslothMarkdownItShared"],
            path: "Sources/MarkdownItGFMCJKFriendly",
            resources: [.process("../../js/dist/markdown-it-gfm-cjk-friendly.iife.js")],
        ),
        .target(
            name: "DocslothAsciidoctor",
            dependencies: ["DocslothCore"],
            path: "Sources/Asciidoctor",
            resources: [.process("../../js/dist/asciidoctor.iife.js")],
        ),
        .testTarget(
            name: "DocslothTests",
            dependencies: [
                "DocslothCore",
                "DocslothUI",
                "DocslothGitHubStyle",
                "DocslothMarkdownIt",
                "DocslothMarkdownItGFM",
                "DocslothMarkdownItGFMCJKFriendly",
                "DocslothAsciidoctor",
            ],
        ),
    ]
)
