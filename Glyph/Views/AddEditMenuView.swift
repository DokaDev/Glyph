//
//  AddEditMenuView.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import SwiftUI

/// View for adding or editing a custom menu item
struct AddEditMenuView: View {
    let menuItem: CustomMenuItem?
    let onSave: (CustomMenuItem) -> Void
    
    @State private var name: String = ""
    @State private var selectedIcon: MenuIcon = .system(SystemIconConfig.defaultIcons[0])
    @State private var executionType: ExecutionType = .shellCommand(ShellCommandConfig(command: ""))
    @State private var isEnabled: Bool = true
    @State private var description: String = ""
    
    @State private var showingIconPicker = false
    @Environment(\.dismiss) private var dismiss
    
    private var isEditing: Bool {
        menuItem != nil
    }
    
    private var title: String {
        isEditing ? "메뉴 편집" : "새 메뉴 추가"
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isExecutionTypeValid
    }
    
    private var isExecutionTypeValid: Bool {
        switch executionType {
        case .shellCommand(let config):
            return !config.command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .applicationLaunch(let config):
            return !config.appPath.isEmpty && !config.appName.isEmpty
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Info Section
                Section {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("메뉴 이름")
                            .font(.headline)
                        TextField("예: 터미널에서 열기", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("설명 (선택사항)")
                            .font(.headline)
                        TextField("메뉴에 대한 간단한 설명", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Enabled Toggle
                    Toggle("메뉴 활성화", isOn: $isEnabled)
                        .font(.headline)
                } header: {
                    Text("기본 정보")
                }
                
                // Icon Section
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("아이콘")
                                .font(.headline)
                            Text(selectedIcon.typeDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        IconView(icon: selectedIcon, size: 40)
                        
                        Button {
                            showingIconPicker = true
                        } label: {
                            Text("변경")
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("아이콘")
                }
                
                // Execution Type Section
                Section {
                    ExecutionTypeEditor(executionType: $executionType)
                } header: {
                    Text("실행 방식")
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveMenuItem()
                    }
                    .disabled(!isValid)
                }
            }
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon)
        }
        .onAppear {
            setupInitialValues()
        }
    }
    
    private func setupInitialValues() {
        if let menuItem = menuItem {
            name = menuItem.name
            selectedIcon = menuItem.icon
            executionType = menuItem.executionType
            isEnabled = menuItem.isEnabled
            description = menuItem.description ?? ""
        }
    }
    
    private func saveMenuItem() {
        let newMenuItem = CustomMenuItem(
            id: menuItem?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: selectedIcon,
            executionType: executionType,
            isEnabled: isEnabled,
            sortOrder: menuItem?.sortOrder ?? 0,
            createdAt: menuItem?.createdAt ?? Date(),
            modifiedAt: Date(),
            description: description.isEmpty ? nil : description
        )
        
        onSave(newMenuItem)
    }
}

/// Editor for execution type (shell command or app launch)
struct ExecutionTypeEditor: View {
    @Binding var executionType: ExecutionType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Type Picker
            Picker("실행 방식", selection: .constant(executionTypeIndex)) {
                Text("셸 명령어").tag(0)
                Text("앱 실행").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: executionTypeIndex) {
                switchExecutionType(to: executionTypeIndex)
            }
            
            // Type-specific editors
            switch executionType {
            case .shellCommand(let config):
                ShellCommandEditor(config: .constant(config)) { updatedConfig in
                    executionType = .shellCommand(updatedConfig)
                }
                
            case .applicationLaunch(let config):
                AppLaunchEditor(config: .constant(config)) { updatedConfig in
                    executionType = .applicationLaunch(updatedConfig)
                }
            }
        }
    }
    
    private var executionTypeIndex: Int {
        switch executionType {
        case .shellCommand:
            return 0
        case .applicationLaunch:
            return 1
        }
    }
    
    private func switchExecutionType(to index: Int) {
        switch index {
        case 0:
            executionType = .shellCommand(ShellCommandConfig(command: ""))
        case 1:
            executionType = .applicationLaunch(AppLaunchConfig(
                appPath: "",
                appName: ""
            ))
        default:
            break
        }
    }
}

/// Editor for shell command configuration
struct ShellCommandEditor: View {
    @Binding var config: ShellCommandConfig
    let onChange: (ShellCommandConfig) -> Void
    
    @State private var command: String = ""
    @State private var workingDirectory: String = ""
    @State private var runInBackground: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("명령어")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("예: open -a Terminal %{selectedPath}", text: $command)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: command) {
                        updateConfig()
                    }
                
                Text("사용 가능한 변수: %{selectedPath}, %{selectedFileName}, %{selectedDirectory}, %{selectedFileExtension}")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("작업 디렉토리 (선택사항)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("예: /Users/username", text: $workingDirectory)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: workingDirectory) {
                        updateConfig()
                    }
            }
            
            Toggle("백그라운드에서 실행", isOn: $runInBackground)
                .onChange(of: runInBackground) {
                    updateConfig()
                }
        }
        .onAppear {
            setupInitialValues()
        }
    }
    
    private func setupInitialValues() {
        command = config.command
        workingDirectory = config.workingDirectory ?? ""
        runInBackground = config.runInBackground
    }
    
    private func updateConfig() {
        let updatedConfig = ShellCommandConfig(
            command: command,
            workingDirectory: workingDirectory.isEmpty ? nil : workingDirectory,
            runInBackground: runInBackground
        )
        onChange(updatedConfig)
    }
}

/// Editor for app launch configuration
struct AppLaunchEditor: View {
    @Binding var config: AppLaunchConfig
    let onChange: (AppLaunchConfig) -> Void
    
    @State private var appPath: String = ""
    @State private var appName: String = ""
    @State private var customParameters: String = ""
    @State private var openWithFile: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                selectApplication()
            } label: {
                HStack {
                    Image(systemName: "app.badge")
                    Text(appName.isEmpty ? "앱 선택..." : appName)
                        .foregroundColor(appName.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("추가 파라미터 (선택사항)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("예: --new-window %{selectedPath}", text: $customParameters)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: customParameters) {
                        updateConfig()
                    }
                
                Text("변수 사용 가능: %{selectedPath}, %{selectedFileName} 등")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Toggle("선택된 파일과 함께 열기", isOn: $openWithFile)
                .onChange(of: openWithFile) {
                    updateConfig()
                }
        }
        .onAppear {
            setupInitialValues()
        }
    }
    
    private func setupInitialValues() {
        appPath = config.appPath
        appName = config.appName
        customParameters = config.customParameters
        openWithFile = config.openWithFile
    }
    
    private func selectApplication() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [.application]
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")
        
        if openPanel.runModal() == .OK,
           let selectedURL = openPanel.url {
            
            appPath = selectedURL.path
            appName = selectedURL.deletingPathExtension().lastPathComponent
            updateConfig()
        }
    }
    
    private func updateConfig() {
        let updatedConfig = AppLaunchConfig(
            appPath: appPath,
            appName: appName,
            customParameters: customParameters,
            openWithFile: openWithFile
        )
        onChange(updatedConfig)
    }
}

/// Placeholder for icon picker view
struct IconPickerView: View {
    @Binding var selectedIcon: MenuIcon
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("아이콘 선택기")
                    .font(.title)
                Text("여기서 아이콘을 선택할 수 있습니다")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("아이콘 선택")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddEditMenuView(menuItem: nil) { _ in }
} 