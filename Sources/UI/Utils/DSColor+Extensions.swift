//
//  DSColor+Extensions.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 17/9/2025.
//
import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif


@MainActor extension DSColor {
    func hexString(for uiType: UserInterfaceType = .current, alphaIncluded: Bool = false) -> String? {
#if canImport(UIKit)
        let resolved: UIColor
        if #available(iOS 13.0, tvOS 13.0, *) {
            resolved = self.resolvedColor(with: UIScreen.main.traitCollection)
        } else {
            resolved = self
        }

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard resolved.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }
#elseif canImport(AppKit)
        let space = NSColorSpace.extendedSRGB
        guard let rgb = self.usingColorSpace(space) else {
            return nil
        }
        let r = rgb.redComponent
        let g = rgb.greenComponent
        let b = rgb.blueComponent
        let a = rgb.alphaComponent
#endif

        let R = Int(round(max(0, min(1, r)) * 255))
        let G = Int(round(max(0, min(1, g)) * 255))
        let B = Int(round(max(0, min(1, b)) * 255))
        let A = Int(round(max(0, min(1, a)) * 255))

        if alphaIncluded {
            return String(format: "#%02X%02X%02X%02X", R, G, B, A)
        } else {
            return String(format: "#%02X%02X%02X", R, G, B)
        }
    }

    func resolved(in uiType: UserInterfaceType) -> DSColor {
#if canImport(AppKit)
        switch uiType {
        case .light:
            return resolved(in: .aqua)
        case .dark:
            return resolved(in: .darkAqua)
        }
#elseif canImport(UIKit)
        let traitCollection: UITraitCollection
        switch uiType {
        case .light:
            traitCollection = UITraitCollection(userInterfaceStyle: .light)
        case .dark:
            traitCollection = UITraitCollection(userInterfaceStyle: .dark)
        }
        return self.resolvedColor(with: traitCollection)
#endif
    }
}

#if canImport(AppKit)
extension NSColor {
    /// 指定した NSAppearance（例: .darkAqua）で解決した実体色を返す
    func resolved(in appearance: NSAppearance.Name) -> NSColor {
        guard let ap = NSAppearance(named: appearance) else { return self }

        // closure から値を“持ち出す”ための一時ホルダー
        final class Box { var cg: CGColor? }
        let box = Box()

        // このブロック内は指定の appearance で描画/資産解決が行われる
        ap.performAsCurrentDrawingAppearance {
            // `cgColor` の取得時にダイナミックカラーが「解決」される
            box.cg = self.cgColor
        }

        // CGColor → NSColor に戻して返す（ここで得られるのは固定色）
        return box.cg.flatMap(NSColor.init(cgColor:)) ?? self
    }
}
#endif
