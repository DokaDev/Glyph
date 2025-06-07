//
//  SharedDataManager.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// Manages data persistence and sharing between main app and Finder extension
class SharedDataManager {
    
    static let shared = SharedDataManager()
    
    /// App Group identifier for data sharing
    private let appGroupIdentifier = "group.com.dokalab.Glyph"
    
    /// Configuration file name
    private let configFileName = "menu_configuration.json"
    
    /// Custom icons directory name
    private let iconsDirectoryName = "custom_icons"
    
    private init() {}
    
    /// Get the shared container URL
    var sharedContainerURL: URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }
    
    /// Get the configuration file URL
    var configurationFileURL: URL? {
        return sharedContainerURL?.appendingPathComponent(configFileName)
    }
    
    /// Get the custom icons directory URL
    var customIconsDirectoryURL: URL? {
        guard let containerURL = sharedContainerURL else { return nil }
        let iconsURL = containerURL.appendingPathComponent(iconsDirectoryName)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: iconsURL.path) {
            try? FileManager.default.createDirectory(at: iconsURL, withIntermediateDirectories: true)
        }
        
        return iconsURL
    }
    
    /// Save configuration to shared container
    func saveConfiguration(_ configuration: MenuConfiguration) throws {
        guard let fileURL = configurationFileURL else {
            throw SharedDataError.containerNotFound
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(configuration)
        try data.write(to: fileURL)
    }
    
    /// Load configuration from shared container
    func loadConfiguration() throws -> MenuConfiguration {
        guard let fileURL = configurationFileURL else {
            throw SharedDataError.containerNotFound
        }
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Return default configuration if file doesn't exist
            return MenuConfiguration()
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(MenuConfiguration.self, from: data)
    }
    
    /// Save custom icon to shared container
    func saveCustomIcon(_ iconData: Data, fileName: String) throws -> String {
        guard let iconsDirectory = customIconsDirectoryURL else {
            throw SharedDataError.containerNotFound
        }
        
        let fileURL = iconsDirectory.appendingPathComponent(fileName)
        try iconData.write(to: fileURL)
        
        return fileName
    }
    
    /// Load custom icon from shared container
    func loadCustomIcon(fileName: String) throws -> Data {
        guard let iconsDirectory = customIconsDirectoryURL else {
            throw SharedDataError.containerNotFound
        }
        
        let fileURL = iconsDirectory.appendingPathComponent(fileName)
        return try Data(contentsOf: fileURL)
    }
    
    /// Delete custom icon from shared container
    func deleteCustomIcon(fileName: String) throws {
        guard let iconsDirectory = customIconsDirectoryURL else {
            throw SharedDataError.containerNotFound
        }
        
        let fileURL = iconsDirectory.appendingPathComponent(fileName)
        try FileManager.default.removeItem(at: fileURL)
    }
    
    /// Debug method to print all storage paths
    func printStoragePaths() {
        print("=== Glyph Storage Paths ===")
        print("App Group ID: \(appGroupIdentifier)")
        
        if let containerURL = sharedContainerURL {
            print("Shared Container: \(containerURL.path)")
        } else {
            print("Shared Container: ❌ NOT FOUND")
        }
        
        if let configURL = configurationFileURL {
            print("Config File: \(configURL.path)")
            print("Config Exists: \(FileManager.default.fileExists(atPath: configURL.path) ? "✅" : "❌")")
        } else {
            print("Config File: ❌ NOT FOUND")
        }
        
        if let iconsURL = customIconsDirectoryURL {
            print("Icons Directory: \(iconsURL.path)")
            print("Icons Dir Exists: \(FileManager.default.fileExists(atPath: iconsURL.path) ? "✅" : "❌")")
            
            // List custom icons
            do {
                let iconFiles = try FileManager.default.contentsOfDirectory(atPath: iconsURL.path)
                print("Custom Icons Count: \(iconFiles.count)")
                for file in iconFiles {
                    print("  - \(file)")
                }
            } catch {
                print("Custom Icons: ❌ Cannot list files")
            }
        } else {
            print("Icons Directory: ❌ NOT FOUND")
        }
        print("===========================")
    }
}

/// Errors that can occur during shared data operations
enum SharedDataError: LocalizedError {
    case containerNotFound
    case fileNotFound
    case encodingFailed
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .containerNotFound:
            return "App Group container not found"
        case .fileNotFound:
            return "Configuration file not found"
        case .encodingFailed:
            return "Failed to encode configuration data"
        case .decodingFailed:
            return "Failed to decode configuration data"
        }
    }
} 