//
//  MenuVariable.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// Available variables that can be used in shell commands and app parameters
enum MenuVariable: String, CaseIterable {
    case selectedPath = "%{selectedPath}"
    case selectedFileName = "%{selectedFileName}"
    case selectedDirectory = "%{selectedDirectory}"
    case selectedFileExtension = "%{selectedFileExtension}"
    
    /// Human-readable description for UI display
    var description: String {
        switch self {
        case .selectedPath:
            return "Selected file or folder's full path"
        case .selectedFileName:
            return "Selected file or folder's name"
        case .selectedDirectory:
            return "Directory containing the selected item"
        case .selectedFileExtension:
            return "File extension of the selected item"
        }
    }
    
    /// Korean description for UI display
    var koreanDescription: String {
        switch self {
        case .selectedPath:
            return "선택된 파일/폴더의 전체 경로"
        case .selectedFileName:
            return "선택된 파일/폴더의 이름"
        case .selectedDirectory:
            return "선택된 항목이 있는 디렉토리"
        case .selectedFileExtension:
            return "선택된 파일의 확장자"
        }
    }
    
    /// Example value for UI preview
    var exampleValue: String {
        switch self {
        case .selectedPath:
            return "/Users/awesome/Documents/example.txt"
        case .selectedFileName:
            return "example.txt"
        case .selectedDirectory:
            return "/Users/awesome/Documents"
        case .selectedFileExtension:
            return "txt"
        }
    }
} 