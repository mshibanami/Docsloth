//
//  Alias.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 9/9/2025.
//

import SwiftUI

#if canImport(UIKit)
public typealias DSColor = UIColor
public typealias DSView = UIView
public typealias DSViewRepresentable = UIViewRepresentable
#elseif canImport(AppKit)
public typealias DSColor = NSColor
public typealias DSView = NSView
public typealias DSViewRepresentable = NSViewRepresentable
#endif
