//
//  IntOrString.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 9/9/2025.
//

public enum IntOrString: Encodable, Hashable, Sendable {
    case int(Int)
    case string(String)
    
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case let .int(i):
            try c.encode(i)
        case let .string(s):
            try c.encode(s)
        }
    }
}
