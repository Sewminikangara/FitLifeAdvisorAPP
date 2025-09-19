//
//  DarkModeTestView.swift
//  FitLifeAdvisorApp
//
//  Test view to demonstrate dark mode functionality


import SwiftUI

struct DarkModeTestView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.colorScheme) var systemColorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "moon.stars")
                            .font(.system(size: 60))
                            .foregroundColor(.primary)
                        
                        Text("Dark Mode Test")
                            .font(.title.bold())
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 20)
                    
                    // Current Status
                    VStack(spacing: 16) {
                        StatusCard(
                            title: "App Color Scheme",
                            value: appSettings.colorScheme.displayName,
                            systemValue: systemColorScheme == .dark ? "Dark" : "Light"
                        )
                        
                        StatusCard(
                            title: "Settings Toggle",
                            value: appSettings.isDarkMode ? "Dark" : "Light",
                            systemValue: "Toggle works: \(appSettings.isDarkMode ? "✅" : "☀️")"
                        )
                    }
                    
                    // Color Scheme Controls
                    VStack(spacing: 16) {
                        Text("Quick Toggle")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            ColorSchemeButton(
                                scheme: .light,
                                currentScheme: appSettings.colorScheme,
                                action: { appSettings.colorScheme = .light }
                            )
                            
                            ColorSchemeButton(
                                scheme: .system,
                                currentScheme: appSettings.colorScheme,
                                action: { appSettings.colorScheme = .system }
                            )
                            
                            ColorSchemeButton(
                                scheme: .dark,
                                currentScheme: appSettings.colorScheme,
                                action: { appSettings.colorScheme = .dark }
                            )
                        }
                        
                        Toggle("Dark Mode (Simple)", isOn: $appSettings.isDarkMode)
                            .padding(.horizontal, 20)
                    }
                    
                    // Visual Elements
                    VStack(spacing: 16) {
                        Text("Visual Elements")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ColorShowcaseView()
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Dark Mode Test")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StatusCard: View {
    let title: String
    let value: String
    let systemValue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.secondary)
            
            HStack {
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(systemValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ColorSchemeButton: View {
    let scheme: AppColorScheme
    let currentScheme: AppColorScheme
    let action: () -> Void
    
    private var isSelected: Bool {
        scheme == currentScheme
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: scheme.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(scheme.displayName)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension AppColorScheme {
    var icon: String {
        switch self {
        case .system: return "gear"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}

struct ColorShowcaseView: View {
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
            ColorSwatch(color: .primary, name: "Primary")
            ColorSwatch(color: .secondary, name: "Secondary")
            ColorSwatch(color: Color(.systemBackground), name: "Background")
            ColorSwatch(color: Color(.secondarySystemBackground), name: "Secondary BG")
            ColorSwatch(color: .blue, name: "Blue")
            ColorSwatch(color: .green, name: "Green")
        }
    }
}

struct ColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separator), lineWidth: 1)
                )
            
            Text(name)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    DarkModeTestView()
        .environmentObject(AppSettings.shared)
}
