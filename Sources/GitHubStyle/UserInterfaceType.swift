//
//  UserInterfaceType.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 15/9/2025.
//
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
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
