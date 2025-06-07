//
//  CustomMenuItem.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// File type filter options for menu items
enum FileTypeFilter: String, Codable, CaseIterable {
    case allFiles = "all"
    case specificExtensions = "extensions"
    
    var displayName: String {
        switch self {
        case .allFiles:
            return "All Files"
        case .specificExtensions:
            return "Specific Extensions Only"
        }
    }
}

/// Application scope settings for menu items
struct ApplicationScope: Codable, Equatable {
    /// Whether to show on folders
    let showOnFolders: Bool
    
    /// Whether to show on files
    let showOnFiles: Bool
    
    /// File type filter setting
    let fileTypeFilter: FileTypeFilter
    
    /// Specific file extensions (only used when fileTypeFilter is .specificExtensions)
    /// Extensions should be stored without dots (e.g., "pdf", "jpg", "txt")
    let allowedExtensions: [String]
    
    init(
        showOnFolders: Bool = true,
        showOnFiles: Bool = true,
        fileTypeFilter: FileTypeFilter = .allFiles,
        allowedExtensions: [String] = []
    ) {
        self.showOnFolders = showOnFolders
        self.showOnFiles = showOnFiles
        self.fileTypeFilter = fileTypeFilter
        self.allowedExtensions = allowedExtensions
    }
    
    /// Check if this scope applies to the given file/folder
    func appliesTo(url: URL, isDirectory: Bool) -> Bool {
        if isDirectory {
            return showOnFolders
        } else {
            guard showOnFiles else { return false }
            
            switch fileTypeFilter {
            case .allFiles:
                return true
            case .specificExtensions:
                let fileExtension = url.pathExtension.lowercased()
                return allowedExtensions.contains { $0.lowercased() == fileExtension }
            }
        }
    }
}

/// Represents a custom menu item that appears in Finder's context menu
struct CustomMenuItem: Codable, Equatable, Identifiable {
    /// Unique identifier
    let id: UUID
    
    /// Display name in the context menu
    let name: String
    
    /// Icon for the menu item
    let icon: MenuIcon
    
    /// Type of execution (shell command or app launch)
    let executionType: ExecutionType
    
    /// Whether the menu item is enabled
    let isEnabled: Bool
    
    /// Application scope settings
    let applicationScope: ApplicationScope
    
    /// Order/position in the menu (lower numbers appear first)
    let sortOrder: Int
    
    /// Creation timestamp
    let createdAt: Date
    
    /// Last modification timestamp
    let modifiedAt: Date
    
    /// Optional description/notes
    let description: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: MenuIcon,
        executionType: ExecutionType,
        isEnabled: Bool = true,
        applicationScope: ApplicationScope = ApplicationScope(),
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.executionType = executionType
        self.isEnabled = isEnabled
        self.applicationScope = applicationScope
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.description = description
    }
    
    /// Create a modified copy with updated modification date
    func updating(
        name: String? = nil,
        icon: MenuIcon? = nil,
        executionType: ExecutionType? = nil,
        isEnabled: Bool? = nil,
        applicationScope: ApplicationScope? = nil,
        sortOrder: Int? = nil,
        description: String? = nil
    ) -> CustomMenuItem {
        return CustomMenuItem(
            id: self.id,
            name: name ?? self.name,
            icon: icon ?? self.icon,
            executionType: executionType ?? self.executionType,
            isEnabled: isEnabled ?? self.isEnabled,
            applicationScope: applicationScope ?? self.applicationScope,
            sortOrder: sortOrder ?? self.sortOrder,
            createdAt: self.createdAt,
            modifiedAt: Date(),
            description: description ?? self.description
        )
    }
} 