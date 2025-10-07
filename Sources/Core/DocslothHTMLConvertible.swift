//
//  Convertible.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 8/9/2025.
//
import Foundation

public protocol DocslothHTMLConvertible: Sendable where Options: OptionsRepresentable {
    associatedtype Options
    static var scriptFileURL: URL { get }
    var options: Options { get }
    func convertToHTML(_ text: String) async throws -> String
}

public protocol DocslothHTMLBaseConverter: DocslothHTMLConvertible {
    static var methodName: String { get }
    var engine: JavaScriptEngineRepresentable { get }
}

extension DocslothHTMLBaseConverter {
    public func convertToHTML(_ text: String) async throws -> String {
        try await engine.convertToHTML(text, methodName: Self.methodName)
    }
    
    public func setup() async throws(JavaScriptEngineError) {
        try await engine.setup(options: options)
    }
}

public protocol OptionsRepresentable: Encodable, Sendable, Equatable {
    static var `default`: Self { get }
}
