//
//  MarkdownIt.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 8/9/2025.
//

import DocslothCore
import DocslothMarkdownItShared
import Foundation
import JavaScriptCore

public final actor MarkdownIt: MarkdownItBase {
    public static var scriptFileURL: URL {
        Bundle.module.url(forResource: "markdown-it-gfm-cjk-friendly.iife", withExtension: "js")!
    }

    public let engine: JavaScriptEngineRepresentable
    public let options: Options

    public init(options: Options = .default) {
        self.init(engine: nil, options: options)
    }

    public init(engine: JavaScriptEngineRepresentable?, options: Options = .default) {
        self.engine = engine ?? JavaScriptEngine(scriptFileURL: Self.scriptFileURL)
        self.options = options
    }
}
