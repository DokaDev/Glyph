import Foundation

// MARK: - App Settings Model
struct AppSettings: Codable, Identifiable {
    let id = UUID()
    var showDebugInfo: Bool
    var appearanceMode: String // "System", "Light", "Dark"
    var launchAtStartup: Bool
    var showInDock: Bool
    
    // Default settings
    static let defaultSettings = AppSettings(
        showDebugInfo: false,
        appearanceMode: "System",
        launchAtStartup: false,
        showInDock: true
    )
    
    // Helper methods for appearance mode
    func getAppearanceMode() -> String {
        return appearanceMode
    }
    
    mutating func setAppearanceMode(_ mode: String) {
        appearanceMode = mode
    }
} 