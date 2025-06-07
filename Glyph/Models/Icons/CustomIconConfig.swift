//
//  CustomIconConfig.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// Configuration for user-provided custom icons
struct CustomIconConfig: Codable, Equatable {
    /// Unique identifier for the custom icon
    let id: UUID
    
    /// Original filename
    let fileName: String
    
    /// Stored filename in the app container
    let storedFileName: String
    
    /// Display name for the icon
    let displayName: String
    
    /// Icon data (base64 encoded for storage)
    let iconDataBase64: String
    
    /// Original file size in bytes
    let fileSizeBytes: Int
    
    /// Date when the icon was added
    let dateAdded: Date
    
    init(
        id: UUID = UUID(),
        fileName: String,
        storedFileName: String,
        displayName: String,
        iconDataBase64: String,
        fileSizeBytes: Int,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.fileName = fileName
        self.storedFileName = storedFileName
        self.displayName = displayName
        self.iconDataBase64 = iconDataBase64
        self.fileSizeBytes = fileSizeBytes
        self.dateAdded = dateAdded
    }
    
    /// Get icon data from base64 string
    var iconData: Data? {
        return Data(base64Encoded: iconDataBase64)
    }
    
    /// Formatted file size for display
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSizeBytes))
    }
} 