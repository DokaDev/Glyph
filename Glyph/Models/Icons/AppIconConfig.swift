//
//  AppIconConfig.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// Configuration for application icons extracted from .app bundles
struct AppIconConfig: Codable, Equatable {
    /// Full path to the application bundle
    let appPath: String
    
    /// Display name of the application
    let appName: String
    
    /// Bundle identifier for the application
    let bundleIdentifier: String
    
    /// Cached icon data (base64 encoded)
    let iconDataBase64: String?
    
    /// Last modified date of the app bundle (for cache validation)
    let appModifiedDate: Date?
    
    init(
        appPath: String,
        appName: String,
        bundleIdentifier: String,
        iconDataBase64: String? = nil,
        appModifiedDate: Date? = nil
    ) {
        self.appPath = appPath
        self.appName = appName
        self.bundleIdentifier = bundleIdentifier
        self.iconDataBase64 = iconDataBase64
        self.appModifiedDate = appModifiedDate
    }
    
    /// Get icon data from base64 string
    var iconData: Data? {
        guard let base64String = iconDataBase64 else { return nil }
        return Data(base64Encoded: base64String)
    }
} 