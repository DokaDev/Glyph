//
//  VariableProcessor.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// Handles variable substitution in shell commands and app parameters
class VariableProcessor {
    
    /// Process variables in a string using the provided URL context
    static func processVariables(in text: String, selectedURL: URL) -> String {
        var processedText = text
        
        // Process each variable type
        for variable in MenuVariable.allCases {
            let value = getValue(for: variable, selectedURL: selectedURL)
            processedText = processedText.replacingOccurrences(of: variable.rawValue, with: value)
        }
        
        return processedText
    }
    
    /// Get the actual value for a variable based on the selected URL
    private static func getValue(for variable: MenuVariable, selectedURL: URL) -> String {
        switch variable {
        case .selectedPath:
            return selectedURL.path
            
        case .selectedFileName:
            return selectedURL.lastPathComponent
            
        case .selectedDirectory:
            return selectedURL.deletingLastPathComponent().path
            
        case .selectedFileExtension:
            return selectedURL.pathExtension
        }
    }
    
    /// Check if a string contains any variables
    static func containsVariables(_ text: String) -> Bool {
        return MenuVariable.allCases.contains { variable in
            text.contains(variable.rawValue)
        }
    }
    
    /// Get all variables found in a string
    static func extractVariables(from text: String) -> [MenuVariable] {
        return MenuVariable.allCases.filter { variable in
            text.contains(variable.rawValue)
        }
    }
    
    /// Validate that all variables in a string are supported
    static func validateVariables(in text: String) -> VariableValidationResult {
        let supportedVariables = Set(MenuVariable.allCases.map { $0.rawValue })
        
        // Find all potential variables in the text (anything matching %{...})
        let pattern = "%\\{[^}]+\\}"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text)) ?? []
        
        var unsupportedVariables: [String] = []
        
        for match in matches {
            if let range = Range(match.range, in: text) {
                let variable = String(text[range])
                if !supportedVariables.contains(variable) {
                    unsupportedVariables.append(variable)
                }
            }
        }
        
        return VariableValidationResult(
            isValid: unsupportedVariables.isEmpty,
            unsupportedVariables: unsupportedVariables
        )
    }
}

/// Result of variable validation
struct VariableValidationResult {
    let isValid: Bool
    let unsupportedVariables: [String]
    
    var errorMessage: String? {
        guard !isValid else { return nil }
        
        let variableList = unsupportedVariables.joined(separator: ", ")
        return "Unsupported variables found: \(variableList)"
    }
    
    var koreanErrorMessage: String? {
        guard !isValid else { return nil }
        
        let variableList = unsupportedVariables.joined(separator: ", ")
        return "지원되지 않는 변수: \(variableList)"
    }
} 