//
//  DocslothWebView.swift
//  Utils
//
//  Created by Manabu Nakazawa on 6/9/2025.
//

import WebKit
#if canImport(AppKit)
import AppKit
#endif

public final class DocslothWebView: WKWebView {
    private var contentHeight: CGFloat = 0 {
        didSet {
            if contentHeight != oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: DSView.noIntrinsicMetric, height: contentHeight)
    }

    func updateContentHeight(_ height: CGFloat) {
        contentHeight = height
    }
    
#if canImport(AppKit)
    override public func scrollWheel(with event: NSEvent) {
        nextResponder?.scrollWheel(with: event)
    }
    
    override public func layout() {
        super.layout()
        Task { @MainActor in
            await updateIntrinsicHeight()
        }
    }
#elseif canImport(UIKit)
    public override func layoutSubviews() {
        super.layoutSubviews()
        Task { @MainActor in
            await updateIntrinsicHeight()
        }
    }
#endif
}
