//
//  MainViewModel.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation
import SwiftUI

/// ViewModel for the main menu management screen
@MainActor
class MainViewModel: ObservableObject {
    @Published var menuItems: [CustomMenuItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let dataManager = SharedDataManager.shared
    
    init() {
        loadMenuItems()
    }
    
    /// Load menu items from shared storage
    func loadMenuItems() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let configuration = try dataManager.loadConfiguration()
                self.menuItems = configuration.menuItems // 모든 항목을 로드 (enabled/disabled 모두)
                self.isLoading = false
            } catch {
                self.errorMessage = "메뉴 로딩 실패: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    /// Add a new menu item
    func addMenuItem(_ menuItem: CustomMenuItem) {
        Task {
            do {
                var configuration = try dataManager.loadConfiguration()
                configuration.addMenuItem(menuItem)
                try dataManager.saveConfiguration(configuration)
                
                await MainActor.run {
                    self.menuItems.append(menuItem)
                    self.sortMenuItems()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "메뉴 추가 실패: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Update an existing menu item
    func updateMenuItem(_ updatedMenuItem: CustomMenuItem) {
        Task {
            do {
                // Clean up old custom image file if it changed
                if let existingItem = menuItems.first(where: { $0.id == updatedMenuItem.id }) {
                    cleanupOldCustomImageIfChanged(oldItem: existingItem, newItem: updatedMenuItem)
                }
                
                var configuration = try dataManager.loadConfiguration()
                configuration.updateMenuItem(updatedMenuItem)
                try dataManager.saveConfiguration(configuration)
                
                await MainActor.run {
                    if let index = self.menuItems.firstIndex(where: { $0.id == updatedMenuItem.id }) {
                        self.menuItems[index] = updatedMenuItem
                    }
                    self.sortMenuItems()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "메뉴 업데이트 실패: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Clean up old custom image file when icon changes during update
    private func cleanupOldCustomImageIfChanged(oldItem: CustomMenuItem, newItem: CustomMenuItem) {
        // Check if the old icon was a custom image
        if case .custom(let oldCustomConfig) = oldItem.icon {
            var shouldDeleteOldFile = false
            
            // Case 1: Icon type changed from custom to something else
            if case .custom = newItem.icon {
                // Still custom image, check if file changed
                if case .custom(let newCustomConfig) = newItem.icon,
                   oldCustomConfig.storedFileName != newCustomConfig.storedFileName {
                    shouldDeleteOldFile = true
                }
            } else {
                // Changed to non-custom icon
                shouldDeleteOldFile = true
            }
            
            if shouldDeleteOldFile {
                do {
                    try dataManager.deleteCustomIcon(fileName: oldCustomConfig.storedFileName)
                    print("Deleted old custom icon during update: \(oldCustomConfig.storedFileName)")
                } catch {
                    print("Failed to delete old custom icon during update: \(error)")
                }
            }
        }
    }
    
    /// Delete a menu item
    func deleteMenuItem(_ menuItem: CustomMenuItem) {
        Task {
            do {
                // Clean up custom image file if it exists
                if case .custom(let customConfig) = menuItem.icon {
                    try? dataManager.deleteCustomIcon(fileName: customConfig.storedFileName)
                }
                
                var configuration = try dataManager.loadConfiguration()
                configuration.removeMenuItem(withId: menuItem.id)
                try dataManager.saveConfiguration(configuration)
                
                await MainActor.run {
                    self.menuItems.removeAll { $0.id == menuItem.id }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "메뉴 삭제 실패: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Toggle menu item enabled state
    func toggleMenuItem(_ menuItem: CustomMenuItem) {
        let updatedMenuItem = menuItem.updating(isEnabled: !menuItem.isEnabled)
        updateMenuItem(updatedMenuItem)
    }
    
    /// Delete all menu items
    func deleteAllMenuItems() {
        Task {
            do {
                // Clean up all custom image files
                for menuItem in menuItems {
                    if case .custom(let customConfig) = menuItem.icon {
                        try? dataManager.deleteCustomIcon(fileName: customConfig.storedFileName)
                    }
                }
                
                // Clear configuration
                var configuration = try dataManager.loadConfiguration()
                configuration.menuItems = []
                try dataManager.saveConfiguration(configuration)
                
                await MainActor.run {
                    self.menuItems = []
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "전체 삭제 실패: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Move menu items (reorder)
    func moveMenuItems(from source: IndexSet, to destination: Int) {
        var updatedItems = menuItems
        updatedItems.move(fromOffsets: source, toOffset: destination)
        
        // Update sort order
        for (index, item) in updatedItems.enumerated() {
            updatedItems[index] = item.updating(sortOrder: index)
        }
        
        menuItems = updatedItems
        
        // Save to storage
        Task {
            do {
                var configuration = try dataManager.loadConfiguration()
                configuration.menuItems = updatedItems
                try dataManager.saveConfiguration(configuration)
            } catch {
                await MainActor.run {
                    self.errorMessage = "순서 변경 저장 실패: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Refresh Finder extension
    func refreshExtension() {
        // This would typically trigger the Finder extension to reload
        // For now, just reload our data
        loadMenuItems()
    }
    
    /// Sort menu items by sort order
    private func sortMenuItems() {
        menuItems.sort { $0.sortOrder < $1.sortOrder }
    }
    
    /// Get filtered menu items based on search text
    var filteredMenuItems: [CustomMenuItem] {
        if searchText.isEmpty {
            return menuItems
        } else {
            return menuItems.filter { menuItem in
                menuItem.name.localizedCaseInsensitiveContains(searchText) ||
                (menuItem.description?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                commandText(for: menuItem).localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    /// Helper function to get command text for searching
    private func commandText(for menuItem: CustomMenuItem) -> String {
        switch menuItem.executionType {
        case .shellCommand(let config):
            return config.command
        case .applicationLaunch(let config):
            return "\(config.appName) \(config.customParameters)"
        }
    }
} 