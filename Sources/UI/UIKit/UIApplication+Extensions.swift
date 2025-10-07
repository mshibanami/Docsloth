//
//  UIApplication+Extensions.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 17/9/2025.
//

#if canImport(UIKit)
import UIKit

@MainActor
extension UIApplication {
    var activeKeyWindow: UIWindow? {
        if let win = connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .filter({ $0.activationState == .foregroundActive })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            return win
        }
        return connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }

    func topViewController(from base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? activeKeyWindow?.rootViewController
        guard let base else {
            return nil
        }
        if let presented = base.presentedViewController {
            return topViewController(from: presented)
        }
        if let nav = base as? UINavigationController {
            return topViewController(from: nav.visibleViewController ?? nav.topViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(from: tab.selectedViewController ?? tab)
        }
        return base
    }
}
#endif
