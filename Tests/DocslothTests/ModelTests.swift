//
//  ModelTests.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 20/9/2025.
//

@testable import DocslothMarkdownItShared
import Foundation
import Testing

@Suite struct ModelTests {
    @Test func convertMarkdownItOptionsToJSONString() throws {
        let options = MarkdownItOptions(
            base: [
                "linkify": true,
                "breaks": true,
            ],
            plugins: [
                .cjkFriendly: [:],
                .footnote: [
                    "footnoteMarker": "^",
                ],
                .other(name: "custom-plugin"): [
                    "customOption": 42,
                ],
            ]
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(options)
        let jsonString = String(data: data, encoding: .utf8)!

        let expectedJSONString = """
        {
          "base" : {
            "breaks" : true,
            "linkify" : true
          },
          "disabledPlugins" : [

          ],
          "plugins" : {
            "custom-plugin" : {
              "customOption" : 42
            },
            "markdown-it-cjk-friendly" : {

            },
            "markdown-it-footnote" : {
              "footnoteMarker" : "^"
            }
          }
        }
        """

        #expect(jsonString == expectedJSONString)
    }
}
