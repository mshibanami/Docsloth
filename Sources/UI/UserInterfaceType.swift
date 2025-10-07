//
//  UserInterfaceType.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 17/9/2025.
//
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

enum UserInterfaceType {
    case light
    case dark

    @MainActor static var current: Self {
#if canImport(UIKit)
        let style = UITraitCollection.current.userInterfaceStyle
        switch style {
        case .light: return .light
        case .dark: return .dark
        default: return .light
        }
#elseif canImport(AppKit)
        let style = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua])
        switch style {
        case .aqua: return .light
        case .darkAqua: return .dark
        default: return .light
        }
#endif
    }
}
