//
//  Asciidoctor.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 8/9/2025.
//

import DocslothCore
import Foundation
import JavaScriptCore

public final actor Asciidoctor: DocslothHTMLBaseConverter {
    public static var methodName: String {
        "convertAsciiDocToHtml"
    }

    public static var scriptFileURL: URL {
        Bundle.module.url(forResource: "asciidoctor.iife", withExtension: "js")!
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

    public struct Options: OptionsRepresentable {
        public static let `default` = Self(
            processorOptions: .init(attributes: ["showtitle": .bool(true)])
        )
        
        public struct ProcessorOptions: Encodable, Hashable, Sendable {
            public var attributes: [String: JSONValue]?
            public var backend: String?
            public var baseDir: String?
            public var catalogAssets: Bool?
            public var doctype: String?
            public var extensionRegistry: Registry?
            public var headerFooter: Bool?
            public var standalone: Bool?
            public var mkdirs: Bool?
            public var parse: Bool?
            public var safe: IntOrString?
            public var sourcemap: Bool?
            public var templateDirs: [String]?
            public var timings: Timings?
            public var toDir: String?
            public var toFile: BoolOrString?

            public typealias Attributes = [String: JSONValue]

            public struct Registry: Encodable, Hashable, Sendable {
                public var raw: [String: JSONValue]
                public init(raw: [String: JSONValue] = [:]) {
                    self.raw = raw
                }
            }

            public struct Timings: Encodable, Hashable, Sendable {
                public var raw: [String: JSONValue]
                public init(raw: [String: JSONValue] = [:]) {
                    self.raw = raw
                }
            }
        }
        
        var processorOptions: ProcessorOptions
    }
}
