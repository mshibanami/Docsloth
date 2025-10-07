//
//  DynamicTypeSize+Extensions.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 9/9/2025.
//
import SwiftUI

extension DynamicTypeSize {
    var webViewFontSize: String {
        let fontSize: CGFloat
#if canImport(UIKit)
        fontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
#elseif canImport(AppKit)
        let baseFontSize = NSFont.systemFontSize
        switch self {
        case .xSmall: fontSize = baseFontSize * 0.76
        case .small: fontSize = baseFontSize * 0.88
        case .medium: fontSize = baseFontSize * 0.90
        case .xLarge: fontSize = baseFontSize * 1.23
        case .xxLarge: fontSize = baseFontSize * 1.54
        case .xxxLarge: fontSize = baseFontSize * 1.83
        case .accessibility1: fontSize = baseFontSize * 2.13
        case .accessibility2: fontSize = baseFontSize * 2.63
        case .accessibility3: fontSize = baseFontSize * 3.16
        case .accessibility4: fontSize = baseFontSize * 3.68
        case .accessibility5: fontSize = baseFontSize * 4.21
        case .large: fallthrough
        @unknown default:
            fontSize = NSFont.systemFontSize * 0.9885
        }
#endif
        return "\(fontSize)px"
    }
}

#if canImport(UIKit)
extension UIContentSizeCategory {
    var webViewFontSize: String {
        return toDynamicTypeSize.webViewFontSize
    }

    var toDynamicTypeSize: DynamicTypeSize {
        switch self {
        case .extraSmall:
            return .xSmall
        case .small:
            return .small
        case .medium:
            return .medium
        case .extraLarge:
            return .xLarge
        case .extraExtraLarge:
            return .xxLarge
        case .extraExtraExtraLarge:
            return .xxxLarge
        case .accessibilityMedium:
            return .accessibility1
        case .accessibilityLarge:
            return .accessibility2
        case .accessibilityExtraLarge:
            return .accessibility3
        case .accessibilityExtraExtraLarge:
            return .accessibility4
        case .accessibilityExtraExtraExtraLarge:
            return .accessibility5
        case .large:
            return .large
        default:
            return .large
        }
    }
}
#endif
