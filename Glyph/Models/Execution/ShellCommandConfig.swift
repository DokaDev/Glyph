//
//  ShellCommandConfig.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import Foundation

/// Configuration for shell command execution
struct ShellCommandConfig: Codable, Equatable {
    /// The shell command with variables (e.g., "open -a iTerm %{selectedPath}")
    let command: String
    
    /// Working directory for command execution (optional)
    let workingDirectory: String?
    
    /// Whether to run the command in background
    let runInBackground: Bool
    
    /// Timeout for command execution in seconds
    let timeoutSeconds: Double
    
    init(
        command: String,
        workingDirectory: String? = nil,
        runInBackground: Bool = false,
        timeoutSeconds: Double = 30.0
    ) {
        self.command = command
        self.workingDirectory = workingDirectory
        self.runInBackground = runInBackground
        self.timeoutSeconds = timeoutSeconds
    }
} 