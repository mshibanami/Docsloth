//
//  MarkdownItBase.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 16/9/2025.
//

import DocslothCore
import Foundation

public protocol MarkdownItBase: DocslothHTMLBaseConverter where Options == MarkdownItOptions {
}

extension MarkdownItBase {
    public static var methodName: String {
        "convertMarkdownToHtml"
    }
    
    func setup() async throws(JavaScriptEngineError) {
        try await self.engine.setup(options: options)
    }
}
