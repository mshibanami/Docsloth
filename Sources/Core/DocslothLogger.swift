//
//  DocslothLogger.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 8/9/2025.
//

#if canImport(os.log)
import os.log
#else
import Logging
#endif

public protocol DocslothLogger: Sendable {
    func debug(_ message: String)
    func info(_ message: String)
    func warning(_ message: String)
    func error(_ message: String)
    func log(level: DocslothLogLevel, message: String)
}

public extension DocslothLogger {
    func debug(_ message: String) { log(level: .debug, message: message) }
    func info(_ message: String) { log(level: .info, message: message) }
    func warning(_ message: String) { log(level: .warning, message: message) }
    func error(_ message: String) { log(level: .error, message: message) }
}

public enum DocslothLogLevel { case debug, info, warning, error }

private let logPrefix = "[Docsloth]"
private let subsystem = "io.github.mshibanami.docsloth"
private let category = "Main"

private let _osLogger = Logger(subsystem: subsystem, category: category)

public actor DocslothProductionLogger: DocslothLogger {
    public init() {}
    public nonisolated func log(level: DocslothLogLevel, message: String) {
        switch level {
        case .warning:
            _osLogger.notice("\(logPrefix) \(message, privacy: .public)")
        case .error:
            _osLogger.error("\(logPrefix) \(message, privacy: .public)")
        default:
            break
        }
    }
}

public actor DocslothDebugLogger: DocslothLogger {
    public init() {}
    public nonisolated func log(level: DocslothLogLevel, message: String) {
        switch level {
        case .debug:
            _osLogger.debug("\(logPrefix) \(message, privacy: .public)")
        case .info:
            _osLogger.info("\(logPrefix) \(message, privacy: .public)")
        case .warning:
            _osLogger.notice("\(logPrefix) \(message, privacy: .public)")
        case .error:
            _osLogger.error("\(logPrefix) \(message, privacy: .public)")
        }
    }
}

public nonisolated(unsafe) var docslothInternalLogger: DocslothLogger = DocslothProductionLogger()

var logger: DocslothLogger {
    docslothInternalLogger
}
