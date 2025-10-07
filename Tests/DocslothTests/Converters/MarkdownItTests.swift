//
//  MarkdownItTests.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 26/9/2025.
//
@testable import DocslothCore
@testable import DocslothMarkdownIt
@testable import DocslothMarkdownItShared
import Testing

@Suite @MainActor struct MarkdownItTests {
    init() {
        docslothInternalLogger = DocslothDebugLogger()
    }

    @Test(arguments: [
        MarkdownItOptions.default,
        MarkdownItOptions(),
    ]) func markdownIt(engineOptions: MarkdownItOptions) async throws {
        let markdownIt = DocslothMarkdownIt.MarkdownIt(options: engineOptions)
        try await markdownIt.setup()
        let text = """
        # Hello, MarkdownIt!

        This is a **bold** text and this is *italic* text.

        This is a first line.
        This is a second line.
        
        - Item 1
        - Item 2
          - Subitem 2.1
          - Subitem 2.2

        Here is a [link](https://www.example.com).
        Here is an auto link: https://auto.example.com

        ```
        // Code block
        print("Hello, World!")
        ```

        **ハロー。**ワールド。
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
        #expect(html.contains("**ハロー。**ワールド。"))
    }
}
