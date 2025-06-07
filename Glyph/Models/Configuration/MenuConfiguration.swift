//
//  MenuConfiguration.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// Main configuration container for all custom menu items and app settings
struct MenuConfiguration: Codable {
    /// Version of the configuration format
    let version: String
    
    /// List of all custom menu items
    var menuItems: [CustomMenuItem]
    
    /// Global settings
    let settings: GlobalSettings
    
    /// Last modification timestamp
    let lastModified: Date
    
    init(
        version: String = "1.0",
        menuItems: [CustomMenuItem] = [],
        settings: GlobalSettings = GlobalSettings(),
        lastModified: Date = Date()
    ) {
        self.version = version
        self.menuItems = menuItems
        self.settings = settings
        self.lastModified = lastModified
    }
    
    /// Add a new menu item
    mutating func addMenuItem(_ item: CustomMenuItem) {
        menuItems.append(item)
    }
    
    /// Remove a menu item by ID
    mutating func removeMenuItem(withId id: UUID) {
        menuItems.removeAll { $0.id == id }
    }
    
    /// Update an existing menu item
    mutating func updateMenuItem(_ updatedItem: CustomMenuItem) {
        if let index = menuItems.firstIndex(where: { $0.id == updatedItem.id }) {
            menuItems[index] = updatedItem
        }
    }
    
    /// Get enabled menu items sorted by sort order
    var enabledMenuItems: [CustomMenuItem] {
        return menuItems
            .filter { $0.isEnabled }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
}

/// Global application settings
struct GlobalSettings: Codable {
    /// Whether to show icons in context menu
    let showIcons: Bool
    
    /// Maximum number of menu items to display
    let maxMenuItems: Int
    
    /// Whether to show keyboard shortcuts
    let showKeyboardShortcuts: Bool
    
    /// Default execution timeout in seconds
    let defaultTimeoutSeconds: Double
    
    init(
        showIcons: Bool = true,
        maxMenuItems: Int = 20,
        showKeyboardShortcuts: Bool = false,
        defaultTimeoutSeconds: Double = 30.0
    ) {
        self.showIcons = showIcons
        self.maxMenuItems = maxMenuItems
        self.showKeyboardShortcuts = showKeyboardShortcuts
        self.defaultTimeoutSeconds = defaultTimeoutSeconds
    }
} 