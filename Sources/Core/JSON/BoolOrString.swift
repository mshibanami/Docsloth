//
//  BoolOrString.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 9/9/2025.
//

public enum BoolOrString: Encodable, Hashable, Sendable {
    case bool(Bool)
    case string(String)

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case let .bool(b):
            try c.encode(b)
        case let .string(s):
            try c.encode(s)
        }
    }
}
