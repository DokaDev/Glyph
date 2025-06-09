//
//  FinderSync.swift
//  GlyphFsync
//
//  Created by Awesome on 6/7/25.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    
    /// App Group identifier for data sharing
    private let appGroupIdentifier = "group.com.dokalab.Glyph"
    
    override init() {
        super.init()
        
        NSLog("🚀 Glyph FinderSync Extension launched from %@", Bundle.main.bundlePath as NSString)
        
        // Enable for all directories (remove the restriction to specific folder)
        FIFinderSyncController.default().directoryURLs = Set([URL(fileURLWithPath: "/")])
        
        // Test shared container access
        testSharedContainerAccess()
    }
    
    private func testSharedContainerAccess() {
        NSLog("🔍 Testing shared container access...")
        
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            NSLog("✅ Shared container URL: %@", containerURL.path)
            
            let configFileURL = containerURL.appendingPathComponent("menu_configuration.json")
            if FileManager.default.fileExists(atPath: configFileURL.path) {
                NSLog("✅ Configuration file found")
            } else {
                NSLog("⚠️ Configuration file not found, will create test data")
            }
        } else {
            NSLog("❌ Shared container URL not found")
        }
    }
    
    // MARK: - Primary Finder Sync protocol methods
    
    override func beginObservingDirectory(at url: URL) {
        NSLog("📁 Begin observing directory: %@", url.path as NSString)
    }
    
    override func endObservingDirectory(at url: URL) {
        NSLog("📁 End observing directory: %@", url.path as NSString)
    }
    
    // MARK: - Menu support
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        NSLog("🔍 Creating menu for kind: %d", menuKind.rawValue)
        
        let menu = NSMenu(title: "")
        
        // Add test menu item
        let testItem = NSMenuItem(title: "🧪 Glyph Test Menu", action: #selector(testMenuAction(_:)), keyEquivalent: "")
        testItem.target = self
        menu.addItem(testItem)
        
        // Add hardcoded test menu items for Phase 1
        let testMenuItems = [
            ("🚀 Open in Terminal", 1001),
            ("📝 Open in VS Code", 1002),
            ("📱 Test Action", 1003)
        ]
        
        for (title, tag) in testMenuItems {
            let item = NSMenuItem(title: title, action: #selector(configMenuAction(_:)), keyEquivalent: "")
            item.target = self
            item.tag = tag
            NSLog("🔧 Setting menu item: %@ with tag: %d", title, tag)
            menu.addItem(item)
        }
        
        // Try to check if config file exists
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            let configFileURL = containerURL.appendingPathComponent("menu_configuration.json")
            if FileManager.default.fileExists(atPath: configFileURL.path) {
                let statusItem = NSMenuItem(title: "✅ Config file found", action: nil, keyEquivalent: "")
                statusItem.isEnabled = false
                menu.addItem(statusItem)
            } else {
                let statusItem = NSMenuItem(title: "⚠️ Config file missing", action: nil, keyEquivalent: "")
                statusItem.isEnabled = false
                menu.addItem(statusItem)
            }
        }
        
        NSLog("✅ Created menu with %d items", menu.items.count)
        return menu
    }
    
    @objc func testMenuAction(_ sender: NSMenuItem) {
        let targetURL = FIFinderSyncController.default().targetedURL()
        let selectedURLs = FIFinderSyncController.default().selectedItemURLs()
        
        NSLog("🧪 Test menu clicked!")
        NSLog("   Target URL: %@", targetURL?.path ?? "None")
        NSLog("   Selected URLs count: %d", selectedURLs?.count ?? 0)
        
        if let urls = selectedURLs {
            for (index, url) in urls.enumerated() {
                NSLog("   Selected[%d]: %@", index, url.path)
            }
        }
    }
    
    @objc func configMenuAction(_ sender: NSMenuItem) {
        NSLog("🔍 Config menu action called")
        NSLog("   Menu title: %@", sender.title)
        NSLog("   Menu tag: %d", sender.tag)
        
        let menuId: String
        switch sender.tag {
        case 1001:
            menuId = "terminal_test"
        case 1002:
            menuId = "vscode_test"
        case 1003:
            menuId = "test_action"
        default:
            NSLog("❌ No menu ID found for tag: %d", sender.tag)
            return
        }
        
        NSLog("📋 Config menu clicked with ID: %@", menuId)
        
        let targetURL = FIFinderSyncController.default().targetedURL()
        let selectedURLs = FIFinderSyncController.default().selectedItemURLs()
        
        NSLog("   Target URL: %@", targetURL?.path ?? "None")
        NSLog("   Selected URLs count: %d", selectedURLs?.count ?? 0)
        
        if let urls = selectedURLs {
            for (index, url) in urls.enumerated() {
                NSLog("   Selected[%d]: %@", index, url.path)
            }
        }
        
        // TODO: Execute actual command in later phases
    }

}

