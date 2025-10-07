//
//  JSONValue.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 9/9/2025.
//

import Foundation

// @dynamicMemberLookup
public enum JSONValue:
    Encodable,
    Hashable,
    Sendable,
    ExpressibleByStringLiteral,
    ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral,
    ExpressibleByBooleanLiteral,
    ExpressibleByNilLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case let .string(s):
            try c.encode(s)
        case let .number(n):
            try c.encode(n)
        case let .bool(b):
            try c.encode(b)
        case let .array(a):
            try c.encode(a)
        case let .object(o):
            try c.encode(o)
        case .null:
            try c.encodeNil()
        }
    }

    public init(stringLiteral value: String) {
        self = .string(value)
    }

    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }

    public init(floatLiteral value: Double) {
        self = .number(value)
    }

    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }

    public init(nilLiteral: ()) {
        self = .null
    }

    public init(arrayLiteral elements: JSONValue...) {
        self = .array(elements)
    }

    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        self = .object(.init(uniqueKeysWithValues: elements))
    }
}
