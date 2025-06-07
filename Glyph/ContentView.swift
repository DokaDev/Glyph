//
//  ContentView.swift
//  Glyph
//
//  Created by Awesome on 6/7/25.
//

import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
    case shortcuts = "Shortcuts"
    case about = "About"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .shortcuts:
            return "command"
        case .about:
            return "info.circle"
        }
    }
}

struct ContentView: View {
    @State private var selectedItem: SidebarItem = .shortcuts
    @State private var showingAddMenu = false
    @State private var showingDeleteAllAlert = false
    @StateObject private var mainViewModel = MainViewModel()
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
                        List(SidebarItem.allCases, selection: $selectedItem) { item in
                HStack {
                    Image(systemName: item.icon)
                        .foregroundColor(.accentColor)
                        .frame(width: 20)
                    Text(item.rawValue)
                }
                .tag(item)
            }
            .navigationTitle("")
            .frame(minWidth: 200)
        } detail: {
            // Detail View
            Group {
                switch selectedItem {
                case .shortcuts:
                    ShortcutsView(viewModel: mainViewModel)
                        .toolbar(content: {
                            ToolbarItemGroup(placement: .navigation) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.secondary)
                                    
                                    TextField("Search...", text: $mainViewModel.searchText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(minWidth: 250, maxWidth: 500)
                                    
                                    if !mainViewModel.searchText.isEmpty {
                                        Button {
                                            mainViewModel.searchText = ""
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.secondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            
                            ToolbarItemGroup(placement: .primaryAction) {
                                Button {
                                    showingDeleteAllAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .help("Delete All Shortcuts")
                                
                                Button {
                                    showingAddMenu = true
                                } label: {
                                    Image(systemName: "plus")
                                }
                                .help("Add Shortcut")
                            }
                        })
                case .about:
                    AboutView()
                }
            }
            .frame(minWidth: 600, minHeight: 400)
            .navigationTitle("")
        }
        .sheet(isPresented: $showingAddMenu) {
            AddShortcutView { newMenuItem in
                mainViewModel.addMenuItem(newMenuItem)
                showingAddMenu = false
            }
        }
        .alert("Delete All Shortcuts", isPresented: $showingDeleteAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                mainViewModel.deleteAllMenuItems()
            }
        } message: {
            Text("Are you sure you want to delete all shortcuts? This action cannot be undone.")
        }
    }
}

struct ShortcutsView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingAddMenu = false
    @State private var selectedMenuItem: CustomMenuItem?
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            if viewModel.filteredMenuItems.isEmpty {
                // Empty State
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "command.square")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        Text(viewModel.searchText.isEmpty ? "No shortcuts yet" : "No matching shortcuts")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text(viewModel.searchText.isEmpty ? 
                             "Create custom Finder context menu shortcuts to quickly access your favorite tools and commands." :
                             "Try adjusting your search terms or create a new shortcut.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Button {
                        showingAddMenu = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Create Your First Shortcut")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                // Shortcuts List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredMenuItems) { menuItem in
                            ShortcutRow(
                                menuItem: menuItem,
                                onEdit: { selectedMenuItem = menuItem },
                                onToggle: { viewModel.toggleMenuItem(menuItem) },
                                onDelete: { viewModel.deleteMenuItem(menuItem) }
                            )
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .sheet(isPresented: $showingAddMenu) {
            AddShortcutView { newMenuItem in
                viewModel.addMenuItem(newMenuItem)
                showingAddMenu = false
            }
        }
        .sheet(item: $selectedMenuItem) { menuItem in
            AddShortcutView(editingItem: menuItem) { updatedMenuItem in
                viewModel.updateMenuItem(updatedMenuItem)
                selectedMenuItem = nil
            }
        }
        .onAppear {
            viewModel.loadMenuItems()
        }
    }
}

struct ShortcutRow: View {
    let menuItem: CustomMenuItem
    let onEdit: () -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            HStack(spacing: 12) {
                // Icon with background
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 48, height: 48)
                    
                    IconView(icon: menuItem.icon, size: 28)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // Title
                    Text(menuItem.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(menuItem.isEnabled ? .primary : .secondary)
                        .lineLimit(1)
                    
                    // Type with icon
                    HStack(spacing: 4) {
                        Image(systemName: menuItem.executionType.iconName)
                            .font(.caption2)
                            .foregroundColor(.accentColor)
                        
                        Text(menuItem.executionType.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 8) {
                    // Edit Button
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Edit")
                    
                    // Delete Button
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .help("Delete")
                    
                    // Expand/Collapse Button
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .buttonStyle(.plain)
                    .help(isExpanded ? "Collapse" : "Expand")
                    
                    // Toggle with label
                    VStack(spacing: 2) {
                        Text("Enable")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Toggle("", isOn: Binding(
                            get: { menuItem.isEnabled },
                            set: { _ in onToggle() }
                        ))
                        .toggleStyle(SwitchToggleStyle())
                        .help("Enable/Disable")
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }
            
            // Command Section - Expandable
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    HStack {
                        Text("Command")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    Text(commandPreview)
                        .font(.system(.callout, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .opacity(menuItem.isEnabled ? 1.0 : 0.5)
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.separator.opacity(0.3), lineWidth: 0.5)
        }
        .padding(.horizontal, 12)
        .onTapGesture(count: 2) {
            onEdit()
        }
    }
    

    
    private var commandPreview: String {
        switch menuItem.executionType {
        case .shellCommand(let config):
            return config.command
        case .applicationLaunch(let config):
            if config.customParameters.isEmpty {
                return "Launch: \(config.appName)"
            } else {
                return "Launch: \(config.appName), Params: \(config.customParameters)"
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "command.square.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.accentColor)
                
                Text("Glyph")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Custom Finder Context Menu")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Features:")
                    .font(.headline)
                
                FeatureRow(icon: "terminal", text: "Execute shell commands with file context")
                FeatureRow(icon: "app.badge", text: "Launch applications with selected files")
                FeatureRow(icon: "photo", text: "Custom icons and system symbols")
                FeatureRow(icon: "text.variable", text: "Dynamic variables for file paths")
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
            
            VStack(spacing: 8) {
                Text("Version 1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Made with ❤️ using SwiftUI")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(40)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
