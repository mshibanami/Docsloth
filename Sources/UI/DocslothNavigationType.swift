//
//  DocslothNavigationType.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 17/9/2025.
//
import Foundation
#if canImport(UIKit)
import SafariServices
import UIKit
import StoreKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum DocslothNavigationType {
    case open
#if canImport(UIKit)
    case inApp(presentationStyle: UIModalPresentationStyle? = nil, prefersAppStore: Bool = true)
#endif
    case handler(handler: (URL) -> Void)

    @MainActor
    func handle(_ url: URL) {
        switch self {
        case .open:
#if canImport(UIKit)
            UIApplication.shared.open(url)
#elseif canImport(AppKit)
            NSWorkspace.shared.open(url)
#endif
#if canImport(UIKit)
        case let .inApp(presentationStyle, prefersAppStore):
            guard let topController = UIApplication.shared.topViewController() else {
                return
            }
            if prefersAppStore,
               let appStoreID = url.appStoreID {
                let viewController = SKStoreProductViewController()
                viewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: appStoreID])
                topController.present(viewController, animated: true)
            } else {
                let viewController = SFSafariViewController(url: url)
                if let presentationStyle {
                    viewController.modalPresentationStyle = presentationStyle
                }
                topController.present(viewController, animated: true)
            }
#endif
        case let .handler(handler):
            handler(url)
        }
    }
}

private extension URL {
    var appStoreID: String? {
        let pathComponents = self.pathComponents
        for component in pathComponents {
            if component.lowercased().hasPrefix("id") {
                let idPart = String(component.dropFirst(2))
                if !idPart.isEmpty,
                   idPart.range(of: #"^\d+$"#, options: .regularExpression) != nil {
                    return idPart
                }
            }
        }
        return nil
    }
}
