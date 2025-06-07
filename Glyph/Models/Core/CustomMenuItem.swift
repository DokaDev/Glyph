//
//  CustomMenuItem.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

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
        sortOrder: Int? = nil,
        description: String? = nil
    ) -> CustomMenuItem {
        return CustomMenuItem(
            id: self.id,
            name: name ?? self.name,
            icon: icon ?? self.icon,
            executionType: executionType ?? self.executionType,
            isEnabled: isEnabled ?? self.isEnabled,
            sortOrder: sortOrder ?? self.sortOrder,
            createdAt: self.createdAt,
            modifiedAt: Date(),
            description: description ?? self.description
        )
    }
} 