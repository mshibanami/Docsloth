//
//  Entitlement.swift
//  Docsloth
//
//  Created by Manabu Nakazawa on 20/9/2025.
//

import Security

let hasNetworkClientEntitlement: Bool = {
#if canImport(AppKit)
    guard let task = SecTaskCreateFromSelf(kCFAllocatorDefault) else {
        return false
    }
    var cfError: Unmanaged<CFError>?
    guard let value = SecTaskCopyValueForEntitlement(task, "com.apple.security.network.client" as CFString, &cfError) else {
        return false
    }
    return (value as? Bool) ?? false
#elseif canImport(UIKit)
    return true
#endif
}()
