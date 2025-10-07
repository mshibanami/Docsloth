//
//  UXColor+Extensions.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 15/9/2025.
//

import DocslothUI
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension DSColor {
    // MARK: - Public

    func hexString(alphaIncluded: Bool = true) -> String {
        guard let rgba = normalizedRGBA() else {
            return alphaIncluded ? "#FFFFFFFF" : "#FFFFFF"
        }
        return formatHexString(r: rgba.r, g: rgba.g, b: rgba.b, a: rgba.a, alphaIncluded: alphaIncluded)
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
        let tc: UITraitCollection = {
            switch uiType {
            case .light:
                return UITraitCollection(userInterfaceStyle: .light)
            case .dark:
                return UITraitCollection(userInterfaceStyle: .dark)
            }
        }()
        return self.resolvedColor(with: tc)
#endif
    }

    private func normalizedRGBA() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
#if canImport(UIKit)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r, g, b, a)
        }
        return rgbaFromCGColor(cgColor)
#elseif canImport(AppKit)
        if let rgb = self.usingColorSpace(.extendedSRGB) ?? self.usingColorSpace(.sRGB) {
            return (rgb.redComponent, rgb.greenComponent, rgb.blueComponent, rgb.alphaComponent)
        }
        return rgbaFromCGColor(self.cgColor)
#endif
    }

    private func rgbaFromCGColor(_ cg: CGColor) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
        guard let comps = cg.components, !comps.isEmpty else { return nil }

        switch cg.colorSpace?.model {
        case .monochrome?:
            let gray = comps[0]
            let a: CGFloat = comps.count > 1 ? comps[1] : 1.0
            return (gray, gray, gray, a)

        case .rgb?:
            let r = comps[safe: 0] ?? 0
            let g = comps[safe: 1] ?? 0
            let b = comps[safe: 2] ?? 0
            let a = comps.count > 3 ? comps[3] : 1.0
            return (r, g, b, a)

        default:
#if canImport(UIKit)
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            if getRed(&r, green: &g, blue: &b, alpha: &a) {
                return (r, g, b, a)
            }
#endif
            return nil
        }
    }

    /// 0...1 の CGFloat を 0...255 の整数に丸めて16進文字列化
    private func formatHexString(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat, alphaIncluded: Bool) -> String {
        func to255(_ v: CGFloat) -> Int {
            let clamped = max(0, min(1, v))
            return Int(lround(clamped * 255))
        }

        let red = to255(r)
        let green = to255(g)
        let blue = to255(b)
        let alpha = to255(a)

        return alphaIncluded
            ? String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
            : String(format: "#%02X%02X%02X", red, green, blue)
    }
}

private extension Array where Element == CGFloat {
    subscript(safe index: Int) -> CGFloat? {
        indices.contains(index) ? self[index] : nil
    }
}

#if canImport(AppKit)
extension NSColor {
    func resolved(in appearance: NSAppearance.Name) -> NSColor {
        guard let ap = NSAppearance(named: appearance) else { return self }

        final class Box { var cg: CGColor? }
        let box = Box()

        ap.performAsCurrentDrawingAppearance {
            box.cg = self.cgColor
        }

        return box.cg.flatMap(NSColor.init(cgColor:)) ?? self
    }
}
#endif
