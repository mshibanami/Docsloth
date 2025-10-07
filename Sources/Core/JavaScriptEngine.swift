//
//  JavaScriptEngine.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 8/9/2025.
//

@preconcurrency import JavaScriptCore

public protocol JavaScriptEngineRepresentable: Actor, Sendable {
    init(scriptFileURL: URL)
    func setup(options: (Encodable & Sendable)?) throws(JavaScriptEngineError)
    func convertToHTML(_ text: String, methodName: String) throws(JavaScriptEngineError) -> String
}

public enum JavaScriptEngineError: Swift.Error, LocalizedError {
    case setupNotDone
    case namespaceNotFound
    case namespaceUndefined
    case invalidScriptFileURL(url: URL)
    case invalidScriptFile(errorDescription: String)
    case javaScriptError(String)
    case invalidOptions(errorDescription: String)

    public var errorDescription: String? {
        switch self {
        case .setupNotDone:
            return "JavaScript engine hasn't been set up"
        case .namespaceNotFound:
            return "JS namespace not found"
        case .namespaceUndefined:
            return "JS namespace is undefined"
        case let .invalidScriptFileURL(url):
            return "Invalid script file URL: \(url)"
        case let .invalidScriptFile(errorDescription):
            return "Invalid script file: \(errorDescription)"
        case let .javaScriptError(message):
            return "JS error: \(message)"
        case let .invalidOptions(errorDescription):
            return "Invalid options: \(errorDescription)"
        }
    }
}

public final actor JavaScriptEngine: JavaScriptEngineRepresentable {
    private static let namespace = "Docsloth"

    private let context: JSContext
    private let scriptFileURL: URL
    private var isSetupDone = false

    public init(scriptFileURL: URL) {
        self.scriptFileURL = scriptFileURL
        self.context = JSContext()

        context.exceptionHandler = { _, exception in
            guard let exception else { return }
            let stack = exception.objectForKeyedSubscript("stack")?.toString() ?? ""
            let line = exception.objectForKeyedSubscript("line")?.toInt32() ?? 0
            let col = exception.objectForKeyedSubscript("column")?.toInt32() ?? 0
            logger.error("JS Exception: \(exception) at \(line):\(col):\n\(stack)")
        }

        let console: @convention(block) (String) -> Void = { msg in
            logger.debug("[JS] " + msg)
        }
        context.setObject(
            ["log": unsafeBitCast(console, to: AnyObject.self)],
            forKeyedSubscript: "console" as NSString
        )
    }

    public func setup(options: (Encodable & Sendable)?) throws(JavaScriptEngineError) {
        if isSetupDone {
            logger.warning("JavaScriptEngine: setup already done, skipping")
            return
        }
        let script: String
        do {
            script = try String(contentsOf: scriptFileURL, encoding: .utf8)
        } catch {
            throw .invalidScriptFileURL(url: scriptFileURL)
        }
        context.evaluateScript(script)
        if let exc = context.exception {
            context.exception = nil
            throw .invalidScriptFile(errorDescription: exc.toString())
        }
        guard let global = context.objectForKeyedSubscript(Self.namespace) else {
            throw .namespaceNotFound
        }
        guard !global.isUndefined else {
            throw .namespaceUndefined
        }
        let arguments: [Any]
        if let options {
            let encoded: Data
            do {
                encoded = try JSONEncoder().encode(options)
            } catch {
                throw .invalidOptions(errorDescription: "Failed to encode options: \(error)")
            }
            let optionsJSONObject: Any
            do {
                optionsJSONObject = try JSONSerialization.jsonObject(with: encoded)
            } catch {
                throw .invalidOptions(errorDescription: "Failed to serialize options to JSON object: \(error)")
            }
            arguments = [optionsJSONObject]
        } else {
            arguments = []
        }
        global.invokeMethod("setup", withArguments: arguments)
        if let exc = context.exception {
            context.exception = nil
            throw .javaScriptError(exc.toString() ?? "Unknown JS error")
        }
        isSetupDone = true
    }

    public func convertToHTML(_ text: String, methodName: String) throws(JavaScriptEngineError) -> String {
        guard isSetupDone else {
            throw .setupNotDone
        }
        guard let global = context.objectForKeyedSubscript(Self.namespace) else {
            throw .namespaceNotFound
        }
        guard !global.isUndefined else {
            throw .namespaceUndefined
        }
        let result = global.invokeMethod(methodName, withArguments: [text])
        if let exc = context.exception {
            context.exception = nil
            throw .javaScriptError(exc.toString() ?? "Unknown JS error")
        }
        return result?.toString() ?? ""
    }
}
