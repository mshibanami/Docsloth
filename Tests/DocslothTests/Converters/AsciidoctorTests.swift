//
//  AsciidoctorTests.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 26/9/2025.
//
@testable import DocslothAsciidoctor
@testable import DocslothCore
import Testing

@Suite @MainActor struct AsciidoctorTests {
    init() {
        docslothInternalLogger = DocslothDebugLogger()
    }

    @Test(arguments: [
        Asciidoctor.Options(processorOptions: .init()),
        Asciidoctor.Options.default,
    ]) func asciidoctor(engineOptions: Asciidoctor.Options) async throws {
        let asciidoctor = Asciidoctor(options: engineOptions)
        try await asciidoctor.setup()
        let text = """
        = Hello, Asciidoctor!

        This is a *bold* text and this is _italic_ text.

        - Item 1
        - Item 2
          - Subitem 2.1
          - Subitem 2.2

        Here is a link:https://www.example.com[link].
        Here is an auto link: https://auto.example.com

        ----
        // Code block
        print("Hello, World!")
        ----

        Hello *World*！
        *ハロー。* ワールド。
        """
        let html = try await asciidoctor.convertToHTML(text)
        #expect(html != "undefined")
        let shouldShowTitle = engineOptions.processorOptions.attributes?["showtitle"] == .bool(true)
        #expect(html.contains("<h1>") == shouldShowTitle)
        #expect(html.contains("<strong>bold</strong>"))
        #expect(html.contains("<em>italic</em>"))
        #expect(html.contains("<ul>"))
        #expect(html.contains("<a href=\"https://www.example.com\">link</a>"))
        #expect(html.contains("Hello <strong>World</strong>！"))
        #expect(html.contains("<strong>ハロー。</strong> ワールド。"))
    }
}
