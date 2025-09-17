//
//  ModernSettingsView.swift

import SwiftUI
import UIKit

struct ModernSettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.large) {
                    // Header
                    settingsHeader
                    
                    // Settings Sections
                    VStack(spacing: Constants.Spacing.large) {
                        // Appearance Section
                        settingsSection(
                            title: "Appearance",
                            icon: "paintbrush.fill",
                            color: .purple
                        ) {
                            SettingsToggleRow(
                                title: "Dark Mode",
                                subtitle: "Switch between light and dark themes",
                                icon: "moon.fill",
                                isOn: $appSettings.isDarkMode
                            )
                            
                            SettingsNavigationRow(
                                title: "App Icon",
                                subtitle: "Choose your favorite app icon",
                                icon: "app.fill",
                                action: { /* TODO: App icon selection */ }
                            )
                            
                            SettingsNavigationRow(
                                title: "Dark Mode Test",
                                subtitle: "Test dark mode functionality",
                                icon: "moon.stars",
                                action: { 
                                    // Open dark mode test view
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first,
                                       let root = window.rootViewController {
                                        let hosting = UIHostingController(rootView: DarkModeTestView().environmentObject(appSettings))
                                        root.present(hosting, animated: true, completion: nil)
                                    }
                                }
                            )
                            
                            SettingsNavigationRow(
                                title: "Face ID Simulator Guide",
                                subtitle: "Setup and test Face ID in simulator",
                                icon: "faceid",
                                action: { 
                                    // Open Face ID simulator guide
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first,
                                       let root = window.rootViewController {
                                        let hosting = UIHostingController(rootView: FaceIDSimulatorGuide().environmentObject(authManager))
                                        root.present(hosting, animated: true, completion: nil)
                                    }
                                }
                            )
                            
                            SettingsNavigationRow(
                                title: "Enable Real Emails",
                                subtitle: "Send actual emails to sewminikangara1@gmail.com",
                                icon: "envelope.fill",
                                action: { 
                                    // Open real email setup guide
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first,
                                       let root = window.rootViewController {
                                        let hosting = UIHostingController(rootView: RealEmailSetupGuide())
                                        root.present(hosting, animated: true, completion: nil)
                                    }
                                }
                            )
                            
                            SettingsNavigationRow(
                                title: "Email Integration Guide",
                                subtitle: "Technical documentation",
                                icon: "envelope.badge",
                                action: { 
                                    // Open email integration guide
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first,
                                       let root = window.rootViewController {
                                        let hosting = UIHostingController(rootView: ForgotPasswordIntegrationGuide())
                                        root.present(hosting, animated: true, completion: nil)
                                    }
                                }
                            )
                        }
                        
                        // Privacy & Security Section
                        settingsSection(
                            title: "Privacy & Security",
                            icon: "lock.shield.fill",
                            color: .green
                        ) {
                            SettingsToggleRow(
                                title: "Biometric Authentication",
                                subtitle: "Use Face ID or Touch ID",
                                icon: authManager.checkBiometricAvailability() == .faceID ? "faceid" : "touchid",
                                isOn: $appSettings.biometricEnabled
                            ) {
                                if appSettings.biometricEnabled {
                                    authManager.enableBiometricAuthentication()
                                } else {
                                    authManager.disableBiometricAuthentication()
                                }
                            }
                            
                            SettingsNavigationRow(
                                title: "Data & Privacy",
                                subtitle: "Manage your personal data",
                                icon: "hand.raised.fill",
                                action: { /* TODO: Privacy settings */ }
                            )
                            
                            SettingsToggleRow(
                                title: "Analytics",
                                subtitle: "Help improve FitLife with anonymous data",
                                icon: "chart.bar.fill",
                                isOn: $appSettings.analyticsEnabled
                            )
                        }
                        
                        // Notifications Section
                        settingsSection(
                            title: "Notifications",
                            icon: "bell.fill",
                            color: .orange
                        ) {
                            SettingsToggleRow(
                                title: "Push Notifications",
                                subtitle: "Receive meal and workout reminders",
                                icon: "bell.badge.fill",
                                isOn: $appSettings.notificationsEnabled
                            )
                            
                            SettingsNavigationRow(
                                title: "Notification Settings",
                                subtitle: "Customize your notification preferences",
                                icon: "bell.circle.fill",
                                action: { /* TODO: Navigate to notification settings */ }
                            )
                        }
                        
                        // Data Section
                        settingsSection(
                            title: "Data Management",
                            icon: "externaldrive.fill",
                            color: .blue
                        ) {
                            SettingsNavigationRow(
                                title: "Export Data",
                                subtitle: "Download your fitness data",
                                icon: "square.and.arrow.up.fill",
                                action: { /* TODO: Export data */ }
                            )
                            
                            SettingsNavigationRow(
                                title: "Storage",
                                subtitle: "Manage app storage and cache",
                                icon: "internaldrive.fill",
                                action: { /* TODO: Storage settings */ }
                            )
                        }
                        
                        // Support Section
                        settingsSection(
                            title: "Support",
                            icon: "questionmark.circle.fill",
                            color: .indigo
                        ) {
                            SettingsNavigationRow(
                                title: "Help Center",
                                subtitle: "Get answers to common questions",
                                icon: "book.fill",
                                action: { /* TODO: Help center */ }
                            )
                            
                            SettingsNavigationRow(
                                title: "Contact Support",
                                subtitle: "Get help from our team",
                                icon: "envelope.fill",
                                action: { /* TODO: Contact support */ }
                            )
                            
                            SettingsNavigationRow(
                                title: "Rate FitLife",
                                subtitle: "Leave a review on the App Store",
                                icon: "star.fill",
                                action: { /* TODO: Open App Store */ }
                            )
                        }
                        
                        // About Section
                        aboutSection
                    }
                    .padding(.bottom, Constants.Spacing.extraLarge)
                }
            }
            .background(Constants.Colors.backgroundGray)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authManager.logout()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to sign out of FitLife?")
        }
    }
    
    private var settingsHeader: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Image(systemName: "gearshape.2.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Constants.Colors.primaryBlue, Constants.Colors.primaryBlue.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 4) {
                Text("App Settings")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text("Customize your FitLife experience")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
        }
        .padding(.top, Constants.Spacing.large)
    }
    
    private var aboutSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Text("About FitLife")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Constants.Spacing.large)
            
            VStack(spacing: Constants.Spacing.small) {
                HStack {
                    Text("Version")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
                
                Divider()
                
                HStack {
                    Text("Build")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Spacer()
                    
                    Text("2025.09.10")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
                
                Divider()
                
                Button("Terms of Service") {
                    // TODO: Show terms
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Constants.Colors.primaryBlue)
                
                Button("Privacy Policy") {
                    // TODO: Show privacy policy
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(Constants.Spacing.medium)
            .background(.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
            .padding(.horizontal, Constants.Spacing.large)
            
            // Sign Out Button
            Button(action: {
                showingLogoutAlert = true
            }) {
                HStack {
                    Image(systemName: "arrow.right.square.fill")
                        .font(.title2)
                    
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.red)
                .cornerRadius(12)
            }
            .padding(.horizontal, Constants.Spacing.large)
            .padding(.top, Constants.Spacing.medium)
        }
    }
    
    private func settingsSection<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            VStack(spacing: Constants.Spacing.small) {
                content()
            }
        }
    }
}

// MARK: - Settings Row Components
struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    var action: (() -> Void)?
    
    var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .onChange(of: isOn) { _ in
                    action?()
                }
        }
        .padding(Constants.Spacing.medium)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        .padding(.horizontal, Constants.Spacing.large)
    }
}

struct SettingsNavigationRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.Spacing.medium) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Constants.Colors.textLight)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
            .padding(Constants.Spacing.medium)
            .background(.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, Constants.Spacing.large)
    }
}

#Preview {
    ModernSettingsView()
        .environmentObject(AuthenticationManager())
        .environmentObject(AppSettings.shared)
}
