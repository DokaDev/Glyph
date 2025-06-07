//
//  ExecutionType.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// Type of execution for a custom menu item
enum ExecutionType: Codable, Equatable {
    case shellCommand(ShellCommandConfig)
    case applicationLaunch(AppLaunchConfig)
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .shellCommand:
            return "Shell Command"
        case .applicationLaunch:
            return "Application Launch"
        }
    }
    
    /// Korean display name for UI
    var koreanDisplayName: String {
        switch self {
        case .shellCommand:
            return "셸 명령어"
        case .applicationLaunch:
            return "앱 실행"
        }
    }
    
    /// Icon name for UI representation
    var iconName: String {
        switch self {
        case .shellCommand:
            return "terminal"
        case .applicationLaunch:
            return "app.badge"
        }
    }
    
    /// Get the underlying configuration for editing
    var config: Any {
        switch self {
        case .shellCommand(let config):
            return config
        case .applicationLaunch(let config):
            return config
        }
    }
} 