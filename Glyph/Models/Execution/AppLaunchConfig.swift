//
//  AppLaunchConfig.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// Configuration for application launch
struct AppLaunchConfig: Codable, Equatable {
    /// Full path to the application bundle
    let appPath: String
    
    /// Display name of the application
    let appName: String
    
    /// Custom parameters to pass to the application (with variables)
    let customParameters: String
    
    /// Whether to open the selected file/folder with the application
    let openWithFile: Bool
    
    /// Whether to activate the application after launch
    let activateApp: Bool
    
    /// Bundle identifier of the application (for verification)
    let bundleIdentifier: String?
    
    init(
        appPath: String,
        appName: String,
        customParameters: String = "",
        openWithFile: Bool = true,
        activateApp: Bool = true,
        bundleIdentifier: String? = nil
    ) {
        self.appPath = appPath
        self.appName = appName
        self.customParameters = customParameters
        self.openWithFile = openWithFile
        self.activateApp = activateApp
        self.bundleIdentifier = bundleIdentifier
    }
} 