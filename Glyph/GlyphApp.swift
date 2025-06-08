//
//  GlyphApp.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import SwiftUI

@main
struct GlyphApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    

    
    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
        }
        .windowResizability(.contentSize)
        
        // Add menu bar extra with custom icon
        MenuBarExtra("Glyph", image: "MenuBarIcon") {
            MenuBarMenuView()
        }
        .menuBarExtraStyle(.menu)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    
    override init() {
        super.init()
        AppDelegate.shared = self
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the main window appears on top when app first launches
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.bringMainWindowToFront()
        }
    }
    
    private func bringMainWindowToFront() {
        print("🚀 Bringing main window to front on app launch")
        
        // Find the main content window
        var foundWindow: NSWindow? = nil
        for window in NSApplication.shared.windows {
            if !window.className.contains("StatusBar") && 
               !window.className.contains("MenuBar") && 
               !window.className.contains("PopupMenu") &&
               !window.className.contains("Menu") &&
               !(window is NSPanel) &&
               window.contentView != nil {
                // Include NSWindow or window classes created by SwiftUI
                if window.className == "NSWindow" || 
                   window.className.contains("SwiftUI") ||
                   window.title.contains("Glyph") ||
                   window.contentView?.className.contains("SwiftUI") == true {
                    foundWindow = window
                    print("🎯 Found main window on launch: \(window.className)")
                    break
                }
            }
        }
        
        if let window = foundWindow {
            // Save the current window level
            let originalLevel = window.level
            
            // Temporarily raise the window to the floating level
            window.level = .floating
            
            // Force the window to the front
            window.orderFrontRegardless()
            window.makeKeyAndOrderFront(nil)
            
            // Activate the app itself
            NSApp.activate(ignoringOtherApps: true)
            
            // Restore the window level after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                window.level = originalLevel
                print("✅ Main window brought to front on app launch")
            }
        } else {
            print("⚠️ No main window found on app launch")
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Prevent the app from terminating when the window is closed - only the menu bar remains
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // When the Dock icon is clicked and there is no window, a new window is displayed
        if !flag {
            showMainWindow()
        }
        return true
    }
    
    func showMainWindow() {
        print("🚀 AppDelegate showMainWindow called")
        
        // Force activation policy to regular temporarily to ensure window can be shown
        let currentPolicy = NSApp.activationPolicy()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Look for any main content window
            for window in NSApplication.shared.windows {
                if !window.className.contains("StatusBar") && 
                   !window.className.contains("MenuBar") && 
                   !(window is NSPanel) {
                    print("📱 Found main window, making it visible")
                    window.makeKeyAndOrderFront(nil)
                    window.orderFront(nil)
                    return
                }
            }
            
            print("⚠️ No main window found even after policy change")
            
            // Restore original policy after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if currentPolicy == .accessory {
                    NSApp.setActivationPolicy(.accessory)
                    print("🔄 Restored accessory policy")
                }
            }
        }
    }
}

struct MenuBarMenuView: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack {
            Button("Show Glyph") {
                showMainWindow()
            }
            
            Divider()
            
            Button("Exit") {
                killAllProcesses()
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }
    
    private func showMainWindow() {
        print("🔍 MenuBar: Looking for existing windows...")
        print("🔍 Current app policy: \(NSApp.activationPolicy().rawValue)")
        
        // Debugging all window states
        for (index, window) in NSApplication.shared.windows.enumerated() {
            print("Window \(index): \(window.className), visible: \(window.isVisible), miniaturized: \(window.isMiniaturized)")
        }
        
        // Check policy to ensure window visibility even when Show in Dock is off
        let currentPolicy = NSApp.activationPolicy()
        print("🔄 Current policy: \(currentPolicy == .accessory ? "accessory" : "regular")")
        
        // Attempt to find any main content window (visible or hidden)
        var foundWindow: NSWindow? = nil
        for window in NSApplication.shared.windows {
            // Exclude menu, status bar, popup windows, and find the actual main window
            if !window.className.contains("StatusBar") && 
               !window.className.contains("MenuBar") && 
               !window.className.contains("PopupMenu") &&
               !window.className.contains("Menu") &&
               !(window is NSPanel) &&
               window.contentView != nil {
                // Include NSWindow or window classes created by SwiftUI
                if window.className == "NSWindow" || 
                   window.className.contains("SwiftUI") ||
                   window.title.contains("Glyph") ||
                   window.contentView?.className.contains("SwiftUI") == true {
                    foundWindow = window
                    print("🎯 Found main window: \(window.className), visible: \(window.isVisible), title: '\(window.title)'")
                    break
                }
            }
        }
        
        if let window = foundWindow {
            if window.isVisible {
                print("✅ Window already visible, bringing to front...")
            } else {
                print("✅ Window found but hidden, showing...")
            }
            
            // Save the current window level
            let originalLevel = window.level
            
            // Temporarily raise the window to the floating level to display it above all other windows
            window.level = .floating
            
            // Force the window to the front, ignoring all other windows
            window.orderFrontRegardless()
            window.makeKeyAndOrderFront(nil)
            
            // Activate the app itself
            NSApp.activate(ignoringOtherApps: true)
            
            // After the window receives focus, restore the level to its original state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                window.makeKey()
                // Restore the window level to its original state after a short delay (to allow normal overlap with other apps)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    window.level = originalLevel
                    print("🔄 Window level restored to normal")
                }
            }
            
            print("✅ Existing window brought to front with elevated level")
            return
        }
        
        // No window found, create new one
        print("🆕 No existing window found, creating new one...")
        openWindow(id: "main")
        NSApp.activate(ignoringOtherApps: true)
        
        // Verify after creation and bring to front
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let mainWindows = NSApplication.shared.windows.filter { window in
                !window.className.contains("StatusBar") && 
                !window.className.contains("MenuBar") && 
                !(window is NSPanel)
            }
            
            print("📊 After creation: found \(mainWindows.count) main windows")
            if let newWindow = mainWindows.first {
                // Force the newly created window to the front
                newWindow.orderFrontRegardless()
                newWindow.makeKeyAndOrderFront(nil)
                newWindow.makeKey()
                print("✅ New window created and brought to front successfully")
            } else {
                print("❌ Still no main window - trying AppDelegate backup")
                AppDelegate.shared?.showMainWindow()
            }
        }
    }
    
    private func killAllProcesses() {
        // Kill all related processes including Finder extension
        let processNames = ["GlyphFinderSync", "Glyph"]
        
        for processName in processNames {
            let task = Process()
            task.launchPath = "/usr/bin/killall"
            task.arguments = ["-9", processName]
            
            do {
                try task.run()
                task.waitUntilExit()
            } catch {
                // Ignore errors - process might not be running
            }
        }
        
        // Force terminate
        exit(0)
    }
}
