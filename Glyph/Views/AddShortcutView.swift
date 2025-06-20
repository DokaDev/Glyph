//
//  AddShortcutView.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct AddShortcutView: View {
    let editingItem: CustomMenuItem?
    let onSave: (CustomMenuItem) -> Void
    
    @State private var name: String = ""
    @State private var executionType: ExecutionTypeOption = .shellCommand
    @State private var command: String = ""
    @State private var appPath: String = ""
    @State private var appName: String = ""
    @State private var appParameters: String = ""
    @State private var isEnabled: Bool = true
    @State private var selectedIcon: MenuIcon = .system(SystemIconConfig.defaultIcons[0])
    
    // Application scope states
    @State private var showOnFolders: Bool = true
    @State private var showOnFiles: Bool = true
    @State private var fileTypeFilter: FileTypeFilter = .allFiles
    @State private var allowedExtensions: String = ""
    
    // Icon selection states
    @State private var iconSelectionType: IconSelectionType = .defaultIcon
    @State private var selectedSystemIcon: SystemIconConfig = SystemIconConfig.defaultIcons[0]
    @State private var selectedCustomImage: URL?
    @State private var selectedAppIcon: NSImage?
    @State private var hasFinishedInitialSetup: Bool = false
    
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    
    init(editingItem: CustomMenuItem? = nil, onSave: @escaping (CustomMenuItem) -> Void) {
        self.editingItem = editingItem
        self.onSave = onSave
    }
    
    private var isEditing: Bool {
        editingItem != nil
    }
    
    private var title: String {
        isEditing ? "Edit Shortcut" : "Add Shortcut"
    }
    
    private var isValid: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        switch executionType {
        case .shellCommand:
            return !command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .application:
            return !appPath.isEmpty && !appName.isEmpty
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            contentView
        }
        .frame(minWidth: 450, idealWidth: 450, maxWidth: 600, minHeight: 400, idealHeight: 500, maxHeight: 700)
        .onAppear {
            setupInitialValues()
        }
    }
    
    private var headerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Save") {
                saveShortcut()
            }
            .disabled(!isValid)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var contentView: some View {
        Form {
            basicInfoSection
            applicationScopeSection
            iconSelectionSection
            executionSection
        }
        .formStyle(.grouped)
    }
    
    private var basicInfoSection: some View {
        Section {
            TextField("Shortcut Name", text: $name)
                .focused($focusedField, equals: .name)
            
            Toggle("Enabled", isOn: $isEnabled)
        } header: {
            Text("Basic Info")
        }
    }
    
    private var applicationScopeSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                // Folder toggle
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.accentColor)
                        .frame(width: 20)
                    
                    Text("Show on Folders")
                        .font(.body)
                    
                    Spacer()
                    
                    Toggle("", isOn: $showOnFolders)
                        .toggleStyle(SwitchToggleStyle())
                }
                
                // File toggle
                HStack {
                    Image(systemName: "doc")
                        .foregroundColor(.accentColor)
                        .frame(width: 20)
                    
                    Text("Show on Files")
                        .font(.body)
                    
                    Spacer()
                    
                    Toggle("", isOn: $showOnFiles)
                        .toggleStyle(SwitchToggleStyle())
                }
                
                // File type filter (only shown when showOnFiles is true)
                if showOnFiles {
                    VStack(alignment: .leading, spacing: 12) {
                        Divider()
                            .padding(.horizontal, -16)
                        
                        Text("File Type Filter")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.leading, 20)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            // All Files radio
                            HStack {
                                RadioButton(
                                    isSelected: fileTypeFilter == .allFiles,
                                    action: { fileTypeFilter = .allFiles }
                                )
                                
                                Text("All Files")
                                    .font(.body)
                                
                                Spacer()
                            }
                            .padding(.leading, 20)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                fileTypeFilter = .allFiles
                            }
                            
                            // Specific Extensions radio
                            HStack {
                                RadioButton(
                                    isSelected: fileTypeFilter == .specificExtensions,
                                    action: { fileTypeFilter = .specificExtensions }
                                )
                                
                                Text("Specific Extensions Only")
                                    .font(.body)
                                
                                Spacer()
                            }
                            .padding(.leading, 20)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                fileTypeFilter = .specificExtensions
                            }
                            
                            // Extensions input (only shown when specificExtensions is selected)
                            if fileTypeFilter == .specificExtensions {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("File Extensions (comma-separated):")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 40)
                                    
                                    TextField("e.g., pdf, jpg, txt", text: $allowedExtensions)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.leading, 40)
                                        .help("Enter file extensions without dots, separated by commas")
                                }
                            }
                        }
                    }
                }
            }
        } header: {
            Text("Application Scope")
        }
    }
    
    private var iconSelectionSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                Text("Icon Selection")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                iconRadioButtons
                iconPreview
            }
        } header: {
            Text("Appearance")
        }
    }
    
    private var iconRadioButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            defaultIconRow
            customImageRow
            appIconRow
        }
    }
    
    private var defaultIconRow: some View {
        HStack {
            RadioButton(
                isSelected: iconSelectionType == .defaultIcon,
                action: {
                    iconSelectionType = .defaultIcon
                    
                    // Clear app icon related data when switching to default icon
                    // This prevents stale data from affecting future app icon selections
                    if executionType == .shellCommand {
                        selectedAppIcon = nil
                    }
                    
                    updateSelectedIcon()
                }
            )
            
            Text("Default Icon")
                .font(.body)
            
            Spacer()
            
            if iconSelectionType == .defaultIcon {
                defaultIconPicker
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            iconSelectionType = .defaultIcon
            
            // Clear app icon related data when switching to default icon
            // This prevents stale data from affecting future app icon selections
            if executionType == .shellCommand {
                selectedAppIcon = nil
            }
            
            updateSelectedIcon()
        }
    }
    
    private var defaultIconPicker: some View {
        Picker("", selection: $selectedSystemIcon) {
            ForEach(SystemIconConfig.defaultIcons, id: \.symbolName) { icon in
                HStack {
                    Image(systemName: icon.symbolName)
                        .foregroundColor(.accentColor)
                        .frame(width: 16, height: 16)
                    Text(icon.displayName)
                }
                .tag(icon)
            }
        }
        .pickerStyle(.automatic)
        .frame(width: 220)
        .onChange(of: selectedSystemIcon) {
            updateSelectedIcon()
        }
    }
    
    private var customImageRow: some View {
        HStack {
            RadioButton(
                isSelected: iconSelectionType == .customImage,
                action: {
                    let previousSelectionType = iconSelectionType
                    iconSelectionType = .customImage
                    
                    // Automatically open image selection dialog if no image is selected
                    if selectedCustomImage == nil {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            selectCustomImage(fallbackSelectionType: previousSelectionType)
                        }
                    }
                }
            )
            
            Text("Custom Image")
                .font(.body)
            
            Spacer()
            
            if iconSelectionType == .customImage {
                customImageControls
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            let previousSelectionType = iconSelectionType
            iconSelectionType = .customImage
            
            // Automatically open image selection dialog if no image is selected
            if selectedCustomImage == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectCustomImage(fallbackSelectionType: previousSelectionType)
                }
            }
        }
    }
    
    private var customImageControls: some View {
        HStack {
            if let customImage = selectedCustomImage {
                Text(customImage.lastPathComponent)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            } else {
                Text("No image selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button("Browse...") {
                selectCustomImageFromButton()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
    
    private var appIconRow: some View {
        HStack {
            RadioButton(
                isSelected: iconSelectionType == .appIcon,
                action: {
                    iconSelectionType = .appIcon
                    
                    // For shell command mode, automatically open app selection if no app is selected
                    if executionType == .shellCommand && selectedAppIcon == nil {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            selectAppForIcon()
                        }
                    } else {
                        updateSelectedIcon()
                    }
                }
            )
            
            Text("App Icon")
                .font(.body)
            
            Spacer()
            
            // Show browse button only in Shell Command mode
            if iconSelectionType == .appIcon && executionType == .shellCommand {
                appIconControls
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            iconSelectionType = .appIcon
            
            // For shell command mode, automatically open app selection if no app is selected
            if executionType == .shellCommand && selectedAppIcon == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectAppForIcon()
                }
            } else {
                updateSelectedIcon()
            }
        }
    }
    
    private var appIconControls: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if let appIcon = selectedAppIcon,
                   case .application(let appConfig) = selectedIcon {
                    Text(appConfig.appName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("No app selected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button("Browse...") {
                    selectAppForIcon()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            Text("Select an app to use its icon (icon only, not for execution)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .italic()
        }
    }
    
    private var iconPreview: some View {
        Group {
            if iconSelectionType != .customImage || selectedCustomImage != nil {
                HStack {
                    Text("Preview:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    iconPreviewImage
                        .frame(width: 32, height: 32)
                        .cornerRadius(6)
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
    }
    
    @ViewBuilder
    private var iconPreviewImage: some View {
        switch iconSelectionType {
        case .defaultIcon:
            Image(systemName: selectedSystemIcon.symbolName)
                .font(.title2)
                .foregroundColor(.accentColor)
        case .customImage:
            if let customImage = selectedCustomImage {
                AsyncImage(url: customImage) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
            }
        case .appIcon:
            if let appIcon = selectedAppIcon {
                Image(nsImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
    
    private var executionSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                executionTypePicker
                executionTypeContent
            }
        } header: {
            Text("Execution")
        }
    }
    
    private var executionTypePicker: some View {
        Picker("Type", selection: $executionType) {
            Text("Shell Command").tag(ExecutionTypeOption.shellCommand)
            Text("Application").tag(ExecutionTypeOption.application)
        }
        .pickerStyle(.segmented)
        .onChange(of: executionType) {
            // Only handle changes if we're not in the initial setup phase
            if editingItem == nil || hasFinishedInitialSetup {
                handleExecutionTypeChange(executionType)
            }
        }
    }
    
    @ViewBuilder
    private var executionTypeContent: some View {
        switch executionType {
        case .shellCommand:
            shellCommandContent
        case .application:
            applicationContent
        }
    }
    
    private var shellCommandContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Command")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField("e.g., open -a Terminal %{selectedPath}", text: $command)
                .focused($focusedField, equals: .command)
            
            Text("Available variables: %{selectedPath}, %{selectedFileName}, %{selectedDirectory}")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var applicationContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Application")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                TextField("App Name", text: $appName)
                    .disabled(true)
                
                Button("Browse...") {
                    selectApplication()
                }
                .buttonStyle(.bordered)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Parameters (optional)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("e.g., --new-window %{selectedPath}", text: $appParameters)
                    .focused($focusedField, equals: .appParameters)
                
                Text("Available variables: %{selectedPath}, %{selectedFileName}, %{selectedDirectory}")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func setupInitialValues() {
        if let item = editingItem {
            name = item.name
            isEnabled = item.isEnabled
            selectedIcon = item.icon
            
            // Initialize application scope settings
            showOnFolders = item.applicationScope.showOnFolders
            showOnFiles = item.applicationScope.showOnFiles
            fileTypeFilter = item.applicationScope.fileTypeFilter
            allowedExtensions = item.applicationScope.allowedExtensions.joined(separator: ", ")
            
            // Set icon selection type based on current icon
            print("DEBUG SETUP - Loading item with icon type: \(item.icon)")
            switch item.icon {
            case .system(let config):
                print("DEBUG SETUP - Icon type is SYSTEM: \(config.symbolName)")
                iconSelectionType = .defaultIcon
                selectedSystemIcon = config
            case .application(let appConfig):
                print("DEBUG SETUP - Icon type is APPLICATION: \(appConfig.appName)")
                iconSelectionType = .appIcon
                
                // Load app icon data if available
                if let iconData = appConfig.iconData,
                   let nsImage = NSImage(data: iconData) {
                    selectedAppIcon = nsImage
                } else if !appConfig.appPath.isEmpty {
                    // Try to load icon from app path
                    selectedAppIcon = NSWorkspace.shared.icon(forFile: appConfig.appPath)
                }
            case .custom(let config):
                print("DEBUG SETUP - Icon type is CUSTOM: \(config.fileName), stored: \(config.storedFileName)")
                iconSelectionType = .customImage
                // Load custom image from shared container
                if let iconsDir = SharedDataManager.shared.customIconsDirectoryURL,
                   !config.storedFileName.isEmpty {
                    selectedCustomImage = iconsDir.appendingPathComponent(config.storedFileName)
                    print("DEBUG SETUP - Custom image path: \(selectedCustomImage?.path ?? "nil")")
                }
            }
            
            switch item.executionType {
            case .shellCommand(let config):
                executionType = .shellCommand
                command = config.command
            case .applicationLaunch(let config):
                executionType = .application
                appPath = config.appPath
                appName = config.appName
                appParameters = config.customParameters
                
                // Only load execution app icon if the current icon type is actually app icon AND we're in application mode
                if case .application(let appConfig) = item.icon, executionType == .application {
                    if let iconData = appConfig.iconData,
                       let nsImage = NSImage(data: iconData) {
                        selectedAppIcon = nsImage
                    } else {
                        loadAppIcon(from: config.appPath)
                    }
                }
            }
            
            // Mark initial setup as complete
            hasFinishedInitialSetup = true
        }
    }
    
    private func handleExecutionTypeChange(_ newType: ExecutionTypeOption) {
        if newType == .shellCommand {
            // When switching to shell command from application mode, clean up app icon data
            // This prevents confusion and stale data regardless of current icon selection
            if iconSelectionType == .appIcon {
                iconSelectionType = .defaultIcon
                updateSelectedIcon()
            }
            // Always clear app icon reference when switching to shell command
            // This ensures fresh state for shell command app icon selection
            selectedAppIcon = nil
            
            // Keep custom image as is - no confusion there
        } else if newType == .application {
            // Only open application selection dialog if no app is currently selected
            if appPath.isEmpty {
                // Reset app icon when switching to application mode
                selectedAppIcon = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectApplication()
                }
            } else {
                // App is already selected, reload the icon but DON'T force icon selection type change
                // Only switch to app icon if no explicit icon selection has been made
                loadAppIcon(from: appPath)
                
                // Don't change icon selection type if user has explicitly chosen default icon or custom image
                // Only auto-switch to app icon if currently no specific selection is made
                if iconSelectionType == .appIcon || 
                   (iconSelectionType == .customImage && selectedCustomImage == nil) {
                    iconSelectionType = .appIcon
                }
                updateSelectedIcon()
            }
        }
    }
    
    private func selectApplication() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        
        if panel.runModal() == .OK, let url = panel.url {
            appPath = url.path
            appName = url.deletingPathExtension().lastPathComponent
            
            // Load app icon
            loadAppIcon(from: url.path)

            if iconSelectionType != .customImage || selectedCustomImage == nil {
                iconSelectionType = .appIcon
            }
            
            // Always switch to App Icon when an application is selected
            // Custom image will remain preserved in selectedCustomImage for later use
            // iconSelectionType = .appIcon
            updateSelectedIcon()
        } else {
            // User cancelled - revert to Shell Command if no app was previously selected
            if appPath.isEmpty {
                executionType = .shellCommand
            }
        }
    }
    
    private func selectCustomImage(fallbackSelectionType: IconSelectionType? = nil) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.image]
        panel.directoryURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first
        
        if panel.runModal() == .OK, let url = panel.url {
            // Store the original URL (don't copy yet - will copy on save)
            selectedCustomImage = url
            updateSelectedIcon()
        } else {
            // User cancelled - revert to previous selection type if no custom image was previously selected
            if selectedCustomImage == nil, let fallback = fallbackSelectionType {
                iconSelectionType = fallback
                updateSelectedIcon()
            }
        }
    }
    
    // Convenience method for Browse button
    private func selectCustomImageFromButton() {
        selectCustomImage()
    }
    
    private func selectAppForIcon() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        
        if panel.runModal() == .OK, let url = panel.url {
            // For shell command mode, we only need the app for its icon
            // Don't modify appPath and appName which are used for application execution
            let iconAppPath = url.path
            let iconAppName = url.deletingPathExtension().lastPathComponent
            
            // Load the icon from the selected app
            let iconAppIcon = NSWorkspace.shared.icon(forFile: url.path)
            selectedAppIcon = iconAppIcon
            
            // Create AppIconConfig with the selected app info (separate from execution app)
            var iconDataBase64: String?
            let tiffData = iconAppIcon.tiffRepresentation
            if let tiffData = tiffData,
               let bitmapImageRep = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapImageRep.representation(using: .png, properties: [:]) {
                iconDataBase64 = pngData.base64EncodedString()
            }
            
            let appConfig = AppIconConfig(
                appPath: iconAppPath,
                appName: iconAppName,
                bundleIdentifier: iconAppName, // Simplified
                iconDataBase64: iconDataBase64,
                appModifiedDate: Date()
            )
            selectedIcon = .application(appConfig)
        } else {
            // User cancelled - revert to default icon if no app icon was previously selected
            if selectedAppIcon == nil {
                iconSelectionType = .defaultIcon
                updateSelectedIcon()
            }
        }
    }
    
    private func loadAppIcon(from appPath: String) {
        let url = URL(fileURLWithPath: appPath)
        selectedAppIcon = NSWorkspace.shared.icon(forFile: url.path)
    }
    
    private func updateSelectedIcon() {
        switch iconSelectionType {
        case .defaultIcon:
            selectedIcon = .system(selectedSystemIcon)
        case .customImage:
            if let customImageUrl = selectedCustomImage {
                do {
                    // Load image data and convert to base64 for preview (don't save file yet)
                    let imageData = try Data(contentsOf: customImageUrl)
                    let iconDataBase64 = imageData.base64EncodedString()
                    
                    let customConfig = CustomIconConfig(
                        fileName: customImageUrl.lastPathComponent,
                        storedFileName: "", // Will be set during save
                        displayName: customImageUrl.deletingPathExtension().lastPathComponent,
                        iconDataBase64: iconDataBase64,
                        fileSizeBytes: imageData.count
                    )
                    selectedIcon = .custom(customConfig)
                } catch {
                    print("Failed to load custom image data: \(error)")
                    // If custom image fails to load, fall back to default icon
                    iconSelectionType = .defaultIcon
                    selectedIcon = .system(selectedSystemIcon)
                }
            } else {
                // No custom image selected, fall back to default icon
                iconSelectionType = .defaultIcon
                selectedIcon = .system(selectedSystemIcon)
            }
        case .appIcon:
            if let appIcon = selectedAppIcon {
                // Convert NSImage to base64 data
                var iconDataBase64: String?
                if let tiffData = appIcon.tiffRepresentation,
                   let bitmapImageRep = NSBitmapImageRep(data: tiffData),
                   let pngData = bitmapImageRep.representation(using: .png, properties: [:]) {
                    iconDataBase64 = pngData.base64EncodedString()
                }
                
                // For shell command mode, use the icon app info (separate from execution app)
                // For application mode, use the execution app info
                let (iconAppPath, iconAppName) = if executionType == .shellCommand {
                    if case .application(let existingConfig) = selectedIcon {
                        (existingConfig.appPath, existingConfig.appName)
                    } else {
                        ("", "Unknown App") // Fallback
                    }
                } else {
                    (appPath, appName)
                }
                
                let appConfig = AppIconConfig(
                    appPath: iconAppPath,
                    appName: iconAppName,
                    bundleIdentifier: iconAppName, // Simplified for now
                    iconDataBase64: iconDataBase64,
                    appModifiedDate: Date()
                )
                selectedIcon = .application(appConfig)
            }
        }
    }
    
    private func saveShortcut() {
        // Clean up old custom image file if necessary
        cleanupOldCustomImageIfNeeded()
        
        // Handle custom image file copying at save time
        var finalIcon = selectedIcon
        print("DEBUG SAVE - iconSelectionType: \(iconSelectionType)")
        print("DEBUG SAVE - selectedIcon before processing: \(selectedIcon)")
        
        if iconSelectionType == .customImage, let customImageUrl = selectedCustomImage {
            print("DEBUG SAVE - Processing custom image: \(customImageUrl.path)")
            do {
                let imageData = try Data(contentsOf: customImageUrl)
                let fileName = "\(UUID().uuidString)_\(customImageUrl.lastPathComponent)"
                
                // Save to shared container
                _ = try SharedDataManager.shared.saveCustomIcon(imageData, fileName: fileName)
                
                // Update the final icon with the stored file name
                let customConfig = CustomIconConfig(
                    fileName: customImageUrl.lastPathComponent,
                    storedFileName: fileName,
                    displayName: customImageUrl.deletingPathExtension().lastPathComponent,
                    iconDataBase64: imageData.base64EncodedString(),
                    fileSizeBytes: imageData.count
                )
                finalIcon = .custom(customConfig)
                print("DEBUG SAVE - Final icon set to CUSTOM: \(customConfig.fileName)")
            } catch {
                print("Failed to copy custom image during save: \(error)")
                // Fall back to default icon if file copy fails
                finalIcon = .system(selectedSystemIcon)
                print("DEBUG SAVE - Fallback to SYSTEM icon")
            }
        } else {
            print("DEBUG SAVE - Not custom image, using selectedIcon: \(selectedIcon)")
        }
        
        print("DEBUG SAVE - Final icon type: \(finalIcon)")
        
        let execType: ExecutionType
        
        switch executionType {
        case .shellCommand:
            execType = .shellCommand(ShellCommandConfig(command: command))
        case .application:
            // Debug: Print parameters before saving
            print("DEBUG SAVE - App: \(appName), Parameters: '\(appParameters)'")
            execType = .applicationLaunch(AppLaunchConfig(
                appPath: appPath,
                appName: appName,
                customParameters: appParameters
            ))
        }
        
        // Process allowed extensions
        let processedExtensions = allowedExtensions
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let appScope = ApplicationScope(
            showOnFolders: showOnFolders,
            showOnFiles: showOnFiles,
            fileTypeFilter: fileTypeFilter,
            allowedExtensions: processedExtensions
        )
        
        let shortcut = CustomMenuItem(
            id: editingItem?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: finalIcon,
            executionType: execType,
            isEnabled: isEnabled,
            applicationScope: appScope,
            sortOrder: editingItem?.sortOrder ?? 0,
            createdAt: editingItem?.createdAt ?? Date(),
            modifiedAt: Date()
        )
        
        onSave(shortcut)
    }
    
    /// Clean up old custom image file when icon type changes or custom image is replaced
    private func cleanupOldCustomImageIfNeeded() {
        guard let editingItem = editingItem else { return }
        
        // Check if the old icon was a custom image
        if case .custom(let oldCustomConfig) = editingItem.icon {
            var shouldDeleteOldFile = false
            
            // Case 1: Icon type changed from custom to something else
            if iconSelectionType != .customImage {
                shouldDeleteOldFile = true
            }
            // Case 2: Still custom image but file changed
            else if case .custom(let newCustomConfig) = selectedIcon,
                    oldCustomConfig.storedFileName != newCustomConfig.storedFileName {
                shouldDeleteOldFile = true
            }
            
            if shouldDeleteOldFile {
                do {
                    try SharedDataManager.shared.deleteCustomIcon(fileName: oldCustomConfig.storedFileName)
                    print("Deleted old custom icon: \(oldCustomConfig.storedFileName)")
                } catch {
                    print("Failed to delete old custom icon: \(error)")
                }
            }
        }
    }
    
    /// Clean up current custom image file (used when replacing with new image or changing icon type)
    private func cleanupCurrentCustomImageIfNeeded() {
        // Only clean up if we currently have a custom image selected and it's a new session file
        if iconSelectionType == .customImage,
           let customImageUrl = selectedCustomImage,
           let fileName = customImageUrl.lastPathComponent.isEmpty ? nil : customImageUrl.lastPathComponent {
            
            // Don't delete the original file if we're editing an existing item with the same custom image
            if let editingItem = editingItem,
               case .custom(let existingConfig) = editingItem.icon,
               existingConfig.storedFileName == fileName {
                return // Don't delete the original file
            }
            
            // Delete the temporary file
            do {
                try SharedDataManager.shared.deleteCustomIcon(fileName: fileName)
                print("Deleted current custom icon: \(fileName)")
            } catch {
                print("Failed to delete current custom icon: \(error)")
            }
        }
    }
}

// MARK: - Supporting Views

struct RadioButton: View {
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Enums

enum IconSelectionType: CaseIterable {
    case defaultIcon
    case customImage
    case appIcon
}

enum ExecutionTypeOption: CaseIterable {
    case shellCommand
    case application
}

enum Field: Hashable {
    case name
    case command
    case appParameters
}

#Preview {
    AddShortcutView { _ in }
} 