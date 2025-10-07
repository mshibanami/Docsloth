//
//  DocslothView.swift
//  Utils
//
//  Created by Manabu Nakazawa on 6/9/2025.
//

import DocslothCore
import Foundation
import SwiftUI
import WebKit

let contentElementId = "content_\(UUID().uuidString)"

public struct DocslothView<Converter: DocslothHTMLConvertible>: DSViewRepresentable {
    @Environment(\.docslothStyle) private var style
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var text: String
    var converter: Converter
#if canImport(AppKit)
    var navigation: DocslothNavigationType = .open
#elseif canImport(UIKit)
    var navigation: DocslothNavigationType = .inApp()
#endif
    let docslothMessageHandlerName: String = "docsloth_\(UUID().uuidString)"

    public init(text: String, converter: Converter) {
        self.text = text
        self.converter = converter
    }

#if canImport(AppKit)
    public func makeNSView(context: Context) -> DocslothWebView {
        return makeView(context: context)
    }

#elseif canImport(UIKit)
    public func makeUIView(context: Context) -> DocslothWebView {
        return makeView(context: context)
    }
#endif

    private func makeView(context: Context) -> DocslothWebView {
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: docslothMessageHandlerName)
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        let webView = DocslothWebView(frame: .zero, configuration: config)

#if canImport(AppKit)
        if let scrollView = webView.subviews.first(where: { $0 is NSScrollView }) as? NSScrollView {
            scrollView.drawsBackground = false
        }
        webView.enclosingScrollView?.hasVerticalScroller = false
        webView.enclosingScrollView?.hasHorizontalScroller = false
        webView.enclosingScrollView?.verticalScrollElasticity = .none
        webView.enclosingScrollView?.horizontalScrollElasticity = .none
        webView.setValue(false, forKey: "drawsBackground")
#elseif canImport(UIKit)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
#endif
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
#if DEBUG
        if #available(iOS 16.4, macOS 13.3, *) {
            webView.isInspectable = true
        }
#endif
        webView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        webView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        webView.reloadSkeleton()
        return webView
    }

#if canImport(AppKit)
    public func updateNSView(_ nsView: DocslothWebView, context: Context) {
        updateView(nsView, context: context)
    }

#elseif canImport(UIKit)
    public func updateUIView(_ uiView: DocslothWebView, context: Context) {
        updateView(uiView, context: context)
    }
#endif

    private func updateView(_ webView: DocslothWebView, context: Context) {
        Task { @MainActor in
            let styleSheet = style.makeStyleSheet(configuration: .init(dynamicTypeSize: dynamicTypeSize))
            await webView.updateText(
                converter: converter,
                text: text,
                styleSheet: styleSheet,
            )
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: DocslothView
        private var isNavigatable = false
        
        init(_ parent: DocslothView) {
            self.parent = parent
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isNavigatable = true
            guard let webView = webView as? DocslothWebView else {
                return
            }
            logger.debug("WebView didFinish navigation")
            Task { @MainActor in
                let styleSheet = parent.style.makeStyleSheet(configuration: .init(dynamicTypeSize: parent.dynamicTypeSize))
                await webView.updateText(
                    converter: parent.converter,
                    text: parent.text,
                    styleSheet: styleSheet,
                )
            }
        }

        public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            logger.info("WebView content process did terminate; reloading...")
            if isNavigatable || hasNetworkClientEntitlement {
                webView.reloadSkeleton()
            } else {
                logger.error("Skipping reload due to lack of network client entitlement.")
            }
        }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            switch navigationAction.navigationType {
            case .linkActivated:
                guard let url = navigationAction.request.url else {
                    return .cancel
                }
                parent.navigation.handle(url)
                return .cancel
            case .reload:
                webView.reloadSkeleton()
                return .cancel
            case .formSubmitted, .backForward, .formResubmitted:
                return .cancel
            case .other:
                fallthrough
            @unknown default:
                return .allow
            }
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == parent.docslothMessageHandlerName,
                  let body = message.body as? String,
                  body == "updateHeight",
                  let webView = message.webView as? DocslothWebView else {
                return
            }
            Task { @MainActor in
                await webView.updateIntrinsicHeight()
            }
        }
    }
}

public extension DocslothView {
    func navigation(_ navigation: DocslothNavigationType) -> Self {
        var copy = self
        copy.navigation = navigation
        return copy
    }
}

extension String {
    var javaScriptEncoded: String {
        return (try? JSONEncoder().encode(self))
            .flatMap { String(data: $0, encoding: .utf8) }
            ?? "\"\""
    }
}

extension DocslothWebView {
    func updateIntrinsicHeight() async {
        let js = """
        (function() {
          const content = document.getElementById('\(contentElementId)');
          const rect = content.getBoundingClientRect();
          const height = rect.height;
          return Math.max(0, height);
        })();
        """
        do {
            let result = try await evaluateJavaScript(js)
            logger.debug("Content Height JS Result: \(result ?? "<nil>")")
            if let h = result as? Double {
                let height = ceil(CGFloat(h))
                updateContentHeight(height)
            }
        } catch {
            logger.error("JS Error: \(error)")
        }
    }

    func updateText(converter: some DocslothHTMLConvertible, text: String, styleSheet: String) async {
        do {
            let convertedHTML = try await converter.convertToHTML(text)
            let setHTMLJS = """
            (function() {
                if (!document?.getElementById('\(contentElementId)')) {
                    return false;
                }
                document.getElementById('\(contentElementId)').innerHTML = \(convertedHTML.javaScriptEncoded);
                return true;
            })();
            """
            let success = try await evaluateJavaScript(setHTMLJS)
            if let success = success as? Bool, !success {
                // DOM hasn't been ready yet.
                return
            }

            await updateStyle(styleSheet)
            await updateIntrinsicHeight()
        } catch {
            logger.error(error.localizedDescription)
        }
    }

    func updateStyle(_ style: String) async {
        let setStyleJS = """
        (function() {
            if (!document?.getElementById('style')) {
                return false;
            }
            document.getElementById('style').innerHTML = \(style.javaScriptEncoded);
            return true;
        })();
        """
        let success = try? await evaluateJavaScript(setStyleJS)
        if let success = success as? Bool, !success {
            logger.error("JS Error: 'style' element not found")
            return
        }
        await updateIntrinsicHeight()
    }
}

extension WKWebView {
    func reloadSkeleton() {
        loadHTMLString(skeletonHTML, baseURL: nil)
    }
    
    private var skeletonHTML: String {
        return """
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no viewport-fit=cover">
          <meta charset="utf-8">
          <style id="style"></style>
        </head>
        <body><div id='\(contentElementId)'></div></body>
        <script>
            const observer = new ResizeObserver(entries => {
                window.webkit.messageHandlers.docsloth.postMessage("updateHeight");
            });
            const content = document.getElementById('\(contentElementId)');
            if (content) {
                observer.observe(content);
            }
        </script>
        </html>
        """
    }
}
