//
//  SystemIconConfig.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// Configuration for system-provided SF Symbol icons
struct SystemIconConfig: Codable, Equatable, Hashable {
    /// SF Symbol name (e.g., "folder", "terminal")
    let symbolName: String
    
    /// Display name for the icon
    let displayName: String
    
    /// Category for organization
    let category: IconCategory
    
    /// Color configuration (optional)
    let colorHex: String?
    
    init(
        symbolName: String,
        displayName: String,
        category: IconCategory,
        colorHex: String? = nil
    ) {
        self.symbolName = symbolName
        self.displayName = displayName
        self.category = category
        self.colorHex = colorHex
    }
    
    /// Predefined system icons
    static let defaultIcons: [SystemIconConfig] = [
        // File category
        SystemIconConfig(symbolName: "folder", displayName: "Folder", category: .file),
        SystemIconConfig(symbolName: "doc", displayName: "Document", category: .file),
        SystemIconConfig(symbolName: "archivebox", displayName: "Archive", category: .file),
        
        // Development category
        SystemIconConfig(symbolName: "terminal", displayName: "Terminal", category: .development),
        SystemIconConfig(symbolName: "hammer", displayName: "Build", category: .development),
        SystemIconConfig(symbolName: "gearshape.2", displayName: "Settings", category: .development),
        
        // Utility category
        SystemIconConfig(symbolName: "trash", displayName: "Trash", category: .utility),
        SystemIconConfig(symbolName: "scissors", displayName: "Cut", category: .utility),
        SystemIconConfig(symbolName: "doc.on.clipboard", displayName: "Copy", category: .utility),
        
        // Media category
        SystemIconConfig(symbolName: "play.rectangle", displayName: "Play", category: .media),
        SystemIconConfig(symbolName: "photo", displayName: "Image", category: .media),
        SystemIconConfig(symbolName: "music.note", displayName: "Music", category: .media),
        
        // System category
        SystemIconConfig(symbolName: "gear", displayName: "System", category: .system),
        SystemIconConfig(symbolName: "info.circle", displayName: "Info", category: .system),
        SystemIconConfig(symbolName: "lock", displayName: "Security", category: .system)
    ]
} 