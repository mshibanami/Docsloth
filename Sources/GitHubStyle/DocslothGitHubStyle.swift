//
//  DocslothGitHubStyle.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 8/9/2025.
//
import DocslothCore
import DocslothUI
import SwiftUI
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@MainActor public struct DocslothGitHubStyle: DocslothStyle {
    public var label: DSColor = .init(resource: .label)
    public var secondaryLabel: DSColor = .init(resource: .secondaryLabel)
    public var background: DSColor = .init(resource: .background)
    public var border: DSColor = .init(resource: .border)
    public var borderWidth: String = "1px"
    public var soft: DSColor = .init(resource: .softBackground)
    public var link: DSColor = .docslothLink
    public var linkHover: DSColor = .docslothLink
    public var codeBackground: DSColor = .init(resource: .codeBackground)
    public var codeText: DSColor = .init(resource: .label)
    public var quoteBar: DSColor = .init(resource: .quoteBar)
    public var hr: DSColor = .init(resource: .hr)
    public var tableHead: DSColor = .init(resource: .tableHead)
    public var highlight: DSColor = .init(resource: .highlight)
    public var labelWeight: String = {
#if canImport(AppKit)
        "450"
#elseif canImport(UIKit)
        "400"
#endif
    }()

    public var alertNote: DSColor = .init(resource: .alertNote)
    public var alertTip: DSColor = .init(resource: .alertTip)
    public var alertImportant: DSColor = .init(resource: .alertImportant)
    public var alertWarning: DSColor = .init(resource: .alertWarning)
    public var alertCaution: DSColor = .init(resource: .alertCaution)
    
    public init() {}

    public func makeStyleSheet(configuration: DocslothUI.DocslothStyleConfiguration) -> String {
        let url = Bundle.module.url(forResource: "style", withExtension: "css")!

        let styleFileContent: String
        do {
            styleFileContent = try String(contentsOf: url)
        } catch {
            assertionFailure("Failed to load style.css: \(error)")
            styleFileContent = ""
        }

        let labelSize = configuration.dynamicTypeSize.webViewFontSize
        let style = """
        :root { \(styleVariables(for: .light, labelSize: labelSize).styleString) }
        @media (prefers-color-scheme: dark) {
          :root { \(styleVariables(for: .dark, labelSize: labelSize).styleString) }
        }
        \(styleFileContent)
        """

        return style
    }

    private func styleVariables(
        for userInterfaceType: UserInterfaceType,
        labelSize: String
    ) -> [String: String] {
        [
            "--ds-label": label.resolved(in: userInterfaceType).hexString(),
            "--ds-labelSize": labelSize,
            "--ds-labelWeight": labelWeight,
            "--ds-secondaryLabel": secondaryLabel.resolved(in: userInterfaceType).hexString(),
            "--ds-background": background.resolved(in: userInterfaceType).hexString(),
            "--ds-border": border.resolved(in: userInterfaceType).hexString(),
            "--ds-borderWidth": borderWidth,
            "--ds-soft": soft.resolved(in: userInterfaceType).hexString(),
            "--ds-link": link.resolved(in: userInterfaceType).hexString(),
            "--ds-linkHover": linkHover.resolved(in: userInterfaceType).hexString(),
            "--ds-codeBackground": codeBackground.resolved(in: userInterfaceType).hexString(),
            "--ds-codeText": codeText.resolved(in: userInterfaceType).hexString(),
            "--ds-quoteBar": quoteBar.resolved(in: userInterfaceType).hexString(),
            "--ds-hr": hr.resolved(in: userInterfaceType).hexString(),
            "--ds-tableHead": tableHead.resolved(in: userInterfaceType).hexString(),
            "--ds-highlight": highlight.resolved(in: userInterfaceType).hexString(),
            "--ds-alertNote": alertNote.resolved(in: userInterfaceType).hexString(),
            "--ds-alertTip": alertTip.resolved(in: userInterfaceType).hexString(),
            "--ds-alertImportant": alertImportant.resolved(in: userInterfaceType).hexString(),
            "--ds-alertWarning": alertWarning.resolved(in: userInterfaceType).hexString(),
            "--ds-alertCaution": alertCaution.resolved(in: userInterfaceType).hexString(),
        ]
    }
}

private extension DSColor {
    static var docslothLink: DSColor {
#if canImport(AppKit)
        .linkColor
#elseif canImport(UIKit)
        .link
#endif
    }
}

private extension [String: String] {
    var styleString: String {
        self.map { "\($0): \($1)" }.joined(separator: "; ")
    }
}
