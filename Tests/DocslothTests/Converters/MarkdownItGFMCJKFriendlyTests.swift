//
//  MarkdownItGFMCJKFriendly.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 26/9/2025.
//
@testable import DocslothCore
@testable import DocslothMarkdownItGFMCJKFriendly
@testable import DocslothMarkdownItShared
import Testing

@Suite @MainActor struct MarkdownItGFMCJKFriendlyTests {
    init() {
        docslothInternalLogger = DocslothDebugLogger()
    }

    @Test(arguments: [
        MarkdownItOptions.default,
        MarkdownItOptions(),
        MarkdownItOptions(
            plugins: [
                .githubAlerts: [
                    "matchCaseSensitive": true,
                ],
            ],
            disabledPlugins: [.sanitizeHTML]
        ),
        MarkdownItOptions(
            base: [
                "html": true,
            ],
        ),
        MarkdownItOptions(
            base: [
                "html": true,
            ],
            plugins: [
                .sanitizeHTML: [
                    "allowedAttributes": [
                        "*": ["class", "id"],
                        "a": ["href", "name", "target"],
                        "img": ["src", "alt", "title"],
                    ],
                    "allowedTags": MarkdownItOptions.default.plugins[.sanitizeHTML]??["allowedTags"] ?? nil,
                    "disallowedTagsMode": "escape",
                ],
            ]
        ),
    ]) func markdownItGFMCJKFriendly(engineOptions: MarkdownItOptions) async throws {
        let markdownIt = DocslothMarkdownItGFMCJKFriendly.MarkdownIt(options: engineOptions)
        try await markdownIt.setup()
        let text = """
        # Hello, MarkdownIt

        This is a **bold** text and this is *italic* text.

        - Item 1
        - Item 2
          - Subitem 2.1
          - Subitem 2.2

        Here is a [link](https://www.example.com).
        Here is an auto link: https://auto.example.com
        
        This is a first line.
        This is a second line.

        > [!NOTE]
        > This is a GitHub alert box.

        > [!warning]
        > This is a warning alert box with a lower-case tag.

        **ハロー。**ワールド。

        <kbd>Control</kbd>+<kbd>Shift</kbd>+A

        ![alt text](https://www.example.com/image.png "Image Title")

        <script>console.error("🚨 I am a log from Markdown!")</script>
        """
        let html = try await markdownIt.convertToHTML(text)
        #expect(html != "undefined")
        #expect(html.contains("<h1>"))
        #expect(html.contains("<strong>bold</strong>"))
        #expect(html.contains("<em>italic</em>"))
        #expect(html.contains("<ul>"))
        #expect(html.contains("<a href=\"https://www.example.com\">link</a>"))

        if engineOptions.base["breaks"] == true {
            #expect(html.contains("This is a first line.<br>\nThis is a second line."))
        } else {
            #expect(html.contains("This is a first line.\nThis is a second line."))
        }
        
        if engineOptions.base["linkify"] == true {
            #expect(html.contains("Here is an auto link: <a href=\"https://auto.example.com\">https://auto.example.com</a>"))
        } else {
            #expect(html.contains("Here is an auto link: https://auto.example.com"))
        }

        if engineOptions.plugins[.sanitizeHTML] != nil {
            #expect(html.contains("markdown-alert-note"))

            if engineOptions.plugins[.githubAlerts]??["matchCaseSensitive"] == true {
                #expect(html.contains("[!warning]"))
            } else {
                #expect(html.contains("markdown-alert-warning"))
            }
        }

        if engineOptions.base["html"] == true {
            if engineOptions.disabledPlugins.contains(.sanitizeHTML) {
                #expect(html.contains("<script"))
            } else {
                if engineOptions.plugins[.sanitizeHTML]??["disallowedTagsMode"] == "escape" {
                    #expect(html.contains("&lt;script"))
                } else {
                    #expect(!html.contains("script"))
                }
            }
        } else {
            if engineOptions.disabledPlugins.contains(.sanitizeHTML) {
                #expect(html.contains("&lt;script"))
            } else {
                if engineOptions.plugins[.sanitizeHTML]??["disallowedTagsMode"] == "escape" {
                    #expect(html.contains("&lt;script"))
                } else {
                    #expect(!html.contains("script"))
                }
            }
        }

        #expect(html.contains("<strong>ハロー。</strong>ワールド。"))
    }
}
