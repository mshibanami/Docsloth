//
//  DocslothStyle.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 28/9/2025.
//
import SwiftUI

@MainActor
public protocol DocslothStyle {
    func makeStyleSheet(configuration: DocslothStyleConfiguration) -> String
}

@MainActor
public struct DocslothStyleConfiguration {
    public let dynamicTypeSize: DynamicTypeSize
    
    public init(dynamicTypeSize: DynamicTypeSize) {
        self.dynamicTypeSize = dynamicTypeSize
    }
}

@MainActor
public struct AnyDocslothStyle: DocslothStyle {
    private let _make: (DocslothStyleConfiguration) -> String

    public init<S: DocslothStyle>(_ style: S) {
        self._make = { style.makeStyleSheet(configuration: $0) }
    }

    public func makeStyleSheet(configuration: DocslothStyleConfiguration) -> String {
        _make(configuration)
    }
}

@MainActor
private struct DocslothStyleKey: @MainActor EnvironmentKey {
    static let defaultValue: AnyDocslothStyle = AnyDocslothStyle(PlainDocslothStyle())
}

@MainActor
public extension EnvironmentValues {
    var docslothStyle: AnyDocslothStyle {
        get { self[DocslothStyleKey.self] }
        set { self[DocslothStyleKey.self] = newValue }
    }
}

struct PlainDocslothStyle: DocslothStyle {
    func makeStyleSheet(configuration: DocslothStyleConfiguration) -> String {
        ""
    }
}

public extension View {
    func docslothStyle<Style: DocslothStyle>(_ style: Style) -> some View {
        environment(\.docslothStyle, AnyDocslothStyle(style))
    }
}
