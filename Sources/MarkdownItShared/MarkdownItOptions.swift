//
//  MarkdownIt.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 8/9/2025.
//

import DocslothCore
import Foundation
import JavaScriptCore

public struct MarkdownItOptions: OptionsRepresentable {
    public enum Plugin: Encodable, Hashable, Sendable {
        case cjkFriendly
        case emoji
        case footnote
        case githubAlerts
        case sanitizeHTML
        case taskCheckbox
        case other(name: String)

        private static let knownPluginNames: [Self: String] = [
            .cjkFriendly: "markdown-it-cjk-friendly",
            .emoji: "markdown-it-emoji",
            .footnote: "markdown-it-footnote",
            .sanitizeHTML: "markdown-it-sanitize-html",
            .githubAlerts: "markdown-it-github-alerts",
            .taskCheckbox: "markdown-it-task-checkbox",
        ]

        public var name: String {
            switch self {
            case .cjkFriendly, .emoji, .footnote, .githubAlerts, .sanitizeHTML, .taskCheckbox:
                Self.knownPluginNames[self] ?? ""
            case let .other(name):
                name
            }
        }

        init(name: String) {
            self = Self.knownPluginNames
                .first { $0.value == name }?
                .key ?? .other(name: name)
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let name = try container.decode(String.self)
            self.init(name: name)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(name)
        }
    }

    public static let `default` = Self(
        base: [
            "linkify": true,
            "breaks": true,
            "html": true,
        ],
        plugins: [:],
        disabledPlugins: []
    )

    public var base: [String: JSONValue]
    public var plugins: [Plugin: [String: JSONValue]?]
    public var disabledPlugins: [Plugin]

    public init(
        base: [String: JSONValue] = [:],
        plugins: [Plugin: [String: JSONValue]?] = [:],
        disabledPlugins: [Plugin] = [],
    ) {
        self.base = base
        self.plugins = plugins
        self.disabledPlugins = disabledPlugins
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(base, forKey: .base)
        var pluginsDict: [String: [String: JSONValue]] = [:]
        for (plugin, options) in plugins {
            pluginsDict[plugin.name] = options
        }
        try container.encode(pluginsDict, forKey: .plugins)
        try container.encode(disabledPlugins, forKey: .disabledPlugins)
    }

    private enum CodingKeys: String, CodingKey {
        case base
        case plugins
        case disabledPlugins
    }
}
