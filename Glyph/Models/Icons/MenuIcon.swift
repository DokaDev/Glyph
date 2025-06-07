//
//  MenuIcon.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// Represents different types of icons that can be used for menu items
enum MenuIcon: Codable, Equatable {
    case system(SystemIconConfig)
    case application(AppIconConfig)
    case custom(CustomIconConfig)
    
    /// Display name for the icon
    var displayName: String {
        switch self {
        case .system(let config):
            return config.displayName
        case .application(let config):
            return config.appName
        case .custom(let config):
            return config.displayName
        }
    }
    
    /// Type description for UI
    var typeDescription: String {
        switch self {
        case .system:
            return "시스템 아이콘"
        case .application:
            return "앱 아이콘"
        case .custom:
            return "커스텀 아이콘"
        }
    }
    
    /// Icon data for display (if available)
    var iconData: Data? {
        switch self {
        case .system:
            return nil // SF Symbols don't need data
        case .application(let config):
            return config.iconData
        case .custom(let config):
            return config.iconData
        }
    }
    
    /// SF Symbol name (for system icons)
    var symbolName: String? {
        switch self {
        case .system(let config):
            return config.symbolName
        case .application, .custom:
            return nil
        }
    }
} 