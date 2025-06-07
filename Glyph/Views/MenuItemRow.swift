//
//  MenuItemRow.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import SwiftUI

/// Row view for displaying a custom menu item in the list
struct MenuItemRow: View {
    let menuItem: CustomMenuItem
    let onEdit: () -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            IconView(icon: menuItem.icon, size: 32)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Name and Status
                HStack {
                    Text(menuItem.name)
                        .font(.headline)
                        .foregroundColor(menuItem.isEnabled ? .primary : .secondary)
                    
                    Spacer()
                    
                    // Execution Type Badge
                    Text(menuItem.executionType.koreanDisplayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(badgeColor.opacity(0.2))
                        .foregroundColor(badgeColor)
                        .cornerRadius(4)
                }
                
                // Description or Command Preview
                Text(commandPreview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            // Toggle Switch
            Toggle("", isOn: .constant(menuItem.isEnabled))
                .toggleStyle(SwitchToggleStyle())
                .scaleEffect(0.8)
                .onTapGesture {
                    onToggle()
                }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .contextMenu {
            Button("편집") {
                onEdit()
            }
            
            Button("복제") {
                // TODO: Implement duplication
            }
            
            Divider()
            
            Button("삭제", role: .destructive) {
                onDelete()
            }
        }
        .onTapGesture(count: 2) {
            onEdit()
        }
    }
    
    private var badgeColor: Color {
        switch menuItem.executionType {
        case .shellCommand:
            return .blue
        case .applicationLaunch:
            return .green
        }
    }
    
    private var commandPreview: String {
        switch menuItem.executionType {
        case .shellCommand(let config):
            return config.command
        case .applicationLaunch(let config):
            // Debug: Print parameters to console
            print("DEBUG - App: \(config.appName), Parameters: '\(config.customParameters)', IsEmpty: \(config.customParameters.isEmpty)")
            
            if config.customParameters.isEmpty {
                return "Launch: \(config.appName)"
            } else {
                return "Launch: \(config.appName), Params: \(config.customParameters)"
            }
        }
    }
}

/// Icon view component that handles different icon types
struct IconView: View {
    let icon: MenuIcon
    let size: CGFloat
    
    var body: some View {
        Group {
            switch icon {
            case .system(let config):
                Image(systemName: config.symbolName)
                    .font(.system(size: size * 0.6))
                    .foregroundColor(.accentColor)
                    .frame(width: size, height: size)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(6)
                
            case .application(let config):
                if let iconData = config.iconData {
                    if let nsImage = NSImage(data: iconData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: size, height: size)
                            .cornerRadius(6)
                    } else {
                        fallbackIcon
                    }
                } else {
                    fallbackIcon
                }
                
            case .custom(let config):
                if let iconData = config.iconData {
                    if let nsImage = NSImage(data: iconData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: size, height: size)
                            .cornerRadius(6)
                    } else {
                        fallbackIcon
                    }
                } else {
                    fallbackIcon
                }
            }
        }
    }
    
    private var fallbackIcon: some View {
        Image(systemName: "app.dashed")
            .font(.system(size: size * 0.6))
            .foregroundColor(.secondary)
            .frame(width: size, height: size)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(6)
    }
}

#Preview {
    let sampleMenuItem = CustomMenuItem(
        name: "터미널에서 열기",
        icon: .system(SystemIconConfig(
            symbolName: "terminal",
            displayName: "터미널",
            category: .development
        )),
        executionType: .shellCommand(ShellCommandConfig(
            command: "open -a Terminal %{selectedPath}"
        ))
    )
    
    return MenuItemRow(
        menuItem: sampleMenuItem,
        onEdit: {},
        onToggle: {},
        onDelete: {}
    )
    .padding()
} 