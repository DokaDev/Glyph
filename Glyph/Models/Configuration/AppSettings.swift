import Foundation

// MARK: - App Settings Model
struct AppSettings: Codable, Identifiable {
    var id = UUID()
    var showDebugInfo: Bool
    var appearanceMode: String // "System", "Light", "Dark"
    var launchAtStartup: Bool
    var showInDock: Bool
    var lastSelectedPage: String // "Shortcuts", "Settings", "About"
    
    // Default settings
    static let defaultSettings = AppSettings(
        showDebugInfo: false,
        appearanceMode: "System",
        launchAtStartup: false,
        showInDock: false,
        lastSelectedPage: "Shortcuts"
    )
    
    // Helper methods for appearance mode
    func getAppearanceMode() -> String {
        return appearanceMode
    }
    
    mutating func setAppearanceMode(_ mode: String) {
        appearanceMode = mode
    }
} 