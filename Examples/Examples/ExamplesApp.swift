//
//  ExamplesApp.swift
//  Examples
//
//  Created by Manabu Nakazawa on 20/9/2025.
//

import SwiftUI

@main
struct ExamplesApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    enum Tab: CaseIterable, Identifiable {
        case markdownIt
        case asciidoctor

        var id: Self { self }

        var name: String {
            switch self {
            case .markdownIt:
                "DocslothView (powered by MarkdownItGFMCJKFriendly)"
            case .asciidoctor:
                "DocslothView (powered by Asciidoctor)"
            }
        }
    }

    @State private var selectedTab: Tab?

    var body: some View {
        NavigationSplitView {
            List(Tab.allCases, selection: $selectedTab) {
                Text($0.name)
            }
        } detail: {
            if let selectedTab {
                switch selectedTab {
                case .markdownIt:
                    MarkdownItPreview()
                case .asciidoctor:
                    AsciidoctorPreview()
                }
            } else {
                Text("Select a tab")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    RootView()
}
