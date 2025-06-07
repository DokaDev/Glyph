//
//  IconCategory.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// Categories for organizing system icons
enum IconCategory: String, CaseIterable, Codable, Hashable {
    case file = "파일"
    case development = "개발"
    case utility = "유틸리티"
    case media = "미디어"
    case system = "시스템"
    case custom = "기타"
    
    /// English name for system use
    var englishName: String {
        switch self {
        case .file:
            return "File"
        case .development:
            return "Development"
        case .utility:
            return "Utility"
        case .media:
            return "Media"
        case .system:
            return "System"
        case .custom:
            return "Custom"
        }
    }
    
    /// SF Symbol name for the category icon
    var symbolName: String {
        switch self {
        case .file:
            return "doc"
        case .development:
            return "hammer"
        case .utility:
            return "wrench.and.screwdriver"
        case .media:
            return "play.rectangle"
        case .system:
            return "gear"
        case .custom:
            return "star"
        }
    }
} 