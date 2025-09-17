//
//  PrivacySecurityView.swift
//  FitLifeAdvisorApp
//
//  Privacy and Security Settings
//

import SwiftUI

struct PrivacySecurityView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var biometricEnabled = true
    @State private var cloudSyncEnabled = true
    @State private var analyticsEnabled = true
    @State private var crashReportingEnabled = true
    @State private var locationServicesEnabled = false
    @State private var showingDataDeletionAlert = false
    @State private var showingExportSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.large) {
                    // Header
                    privacyHeader
                    
                    // Security Section
                    securitySection
                    
                    // Data Privacy Section
                    dataPrivacySection
                    
                    // App Permissions Section
                    permissionsSection
                    
                    // Data Management Section
                    dataManagementSection
                }
                .padding(.bottom, Constants.Spacing.extraLarge)
            }
            .background(Constants.Colors.backgroundGray)
            .navigationTitle("Privacy & Security")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
        .alert("Delete All Data", isPresented: $showingDataDeletionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // TODO: Delete all user data
            }
        } message: {
            Text("This will permanently delete all your data from FitLife. This action cannot be undone.")
        }
        .sheet(isPresented: $showingExportSheet) {
            DataExportView()
        }
    }
    
    private var privacyHeader: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .green.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 4) {
                Text("Privacy & Security")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text("Manage your data privacy and security settings")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, Constants.Spacing.large)
    }
    
    private var securitySection: some View {
        privacySection(
            title: "Security",
            icon: "key.fill",
            color: .blue
        ) {
            PrivacyToggleRow(
                title: "Biometric Authentication",
                subtitle: "Use Face ID or Touch ID to secure your app",
                icon: authManager.checkBiometricAvailability() == .faceID ? "faceid" : "touchid",
                isOn: $biometricEnabled,
                statusText: biometricEnabled ? "Enabled" : "Disabled"
            ) {
                if biometricEnabled {
                    authManager.enableBiometricAuthentication()
                } else {
                    authManager.disableBiometricAuthentication()
                }
            }
            
            PrivacyInfoRow(
                title: "App Lock",
                subtitle: "Automatically lock app when inactive",
                icon: "lock.fill",
                value: "After 5 minutes"
            )
            
            PrivacyInfoRow(
                title: "Data Encryption",
                subtitle: "All your data is encrypted at rest and in transit",
                icon: "checkmark.shield.fill",
                value: "Active"
            )
        }
    }
    
    private var dataPrivacySection: some View {
        privacySection(
            title: "Data Privacy",
            icon: "hand.raised.fill",
            color: .orange
        ) {
            PrivacyToggleRow(
                title: "iCloud Sync",
                subtitle: "Sync your data across all your devices",
                icon: "icloud.fill",
                isOn: $cloudSyncEnabled,
                statusText: cloudSyncEnabled ? "Enabled" : "Disabled"
            )
            
            PrivacyToggleRow(
                title: "Analytics",
                subtitle: "Help improve FitLife with anonymous usage data",
                icon: "chart.bar.fill",
                isOn: $analyticsEnabled,
                statusText: analyticsEnabled ? "Enabled" : "Disabled"
            )
            
            PrivacyToggleRow(
                title: "Crash Reporting",
                subtitle: "Send crash reports to help us fix bugs",
                icon: "exclamationmark.triangle.fill",
                isOn: $crashReportingEnabled,
                statusText: crashReportingEnabled ? "Enabled" : "Disabled"
            )
        }
    }
    
    private var permissionsSection: some View {
        privacySection(
            title: "App Permissions",
            icon: "gear.badge",
            color: .purple
        ) {
            PrivacyInfoRow(
                title: "Camera Access",
                subtitle: "Used for meal photo analysis",
                icon: "camera.fill",
                value: "Allowed"
            )
            
            PrivacyInfoRow(
                title: "Photo Library",
                subtitle: "Access to select photos for meal analysis",
                icon: "photo.fill",
                value: "Allowed"
            )
            
            PrivacyInfoRow(
                title: "Notifications",
                subtitle: "Send meal and workout reminders",
                icon: "bell.fill",
                value: "Allowed"
            )
            
            PrivacyToggleRow(
                title: "Location Services",
                subtitle: "Find nearby healthy restaurants and gyms",
                icon: "location.fill",
                isOn: $locationServicesEnabled,
                statusText: locationServicesEnabled ? "Enabled" : "Disabled"
            )
        }
    }
    
    private var dataManagementSection: some View {
        privacySection(
            title: "Data Management",
            icon: "externaldrive.fill",
            color: .red
        ) {
            PrivacyActionRow(
                title: "Export My Data",
                subtitle: "Download all your FitLife data",
                icon: "square.and.arrow.up.fill",
                buttonText: "Export"
            ) {
                showingExportSheet = true
            }
            
            PrivacyActionRow(
                title: "Data Usage",
                subtitle: "View what data FitLife collects and uses",
                icon: "doc.text.fill",
                buttonText: "View"
            ) {
                // TODO: Show data usage details
            }
            
            PrivacyActionRow(
                title: "Delete All Data",
                subtitle: "Permanently remove all your data from FitLife",
                icon: "trash.fill",
                buttonText: "Delete",
                isDestructive: true
            ) {
                showingDataDeletionAlert = true
            }
        }
    }
    
    private func privacySection<Content: View>(
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

// MARK: - Privacy Row Components
struct PrivacyToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    let statusText: String
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
                
                Text(statusText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isOn ? .green : Constants.Colors.textLight)
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

struct PrivacyInfoRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let value: String
    
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
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.green)
        }
        .padding(Constants.Spacing.medium)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        .padding(.horizontal, Constants.Spacing.large)
    }
}

struct PrivacyActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let buttonText: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isDestructive ? .red : Constants.Colors.primaryBlue)
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
            
            Button(buttonText, action: action)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isDestructive ? .red : Constants.Colors.primaryBlue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background((isDestructive ? Color.red : Constants.Colors.primaryBlue).opacity(0.1))
                .cornerRadius(8)
        }
        .padding(Constants.Spacing.medium)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        .padding(.horizontal, Constants.Spacing.large)
    }
}

// MARK: - Data Export View
struct DataExportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var exportProgress: Double = 0
    @State private var isExporting = false
    @State private var exportCompleted = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: Constants.Spacing.large) {
                Spacer()
                
                VStack(spacing: Constants.Spacing.medium) {
                    Image(systemName: exportCompleted ? "checkmark.circle.fill" : "square.and.arrow.up.fill")
                        .font(.system(size: 60))
                        .foregroundColor(exportCompleted ? .green : Constants.Colors.primaryBlue)
                    
                    Text(exportCompleted ? "Export Complete!" : "Export Your Data")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text(exportCompleted ? 
                         "Your data has been exported successfully" :
                         "We'll create a file containing all your FitLife data")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                        .multilineTextAlignment(.center)
                }
                
                if isExporting {
                    VStack(spacing: Constants.Spacing.medium) {
                        // Custom Progress Bar
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(Constants.Colors.primaryBlue)
                                .frame(width: CGFloat(exportProgress) * UIScreen.main.bounds.width * 0.8, height: 8)
                                .cornerRadius(4)
                                .animation(.easeInOut(duration: 0.3), value: exportProgress)
                        }
                        .frame(maxWidth: .infinity)
                        .scaleEffect(y: 2)
                        
                        Text("Exporting your data...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Constants.Colors.textLight)
                    }
                    .padding(.horizontal, Constants.Spacing.large)
                }
                
                Spacer()
                
                VStack(spacing: Constants.Spacing.medium) {
                    if !exportCompleted {
                        Button(action: startExport) {
                            Text(isExporting ? "Exporting..." : "Start Export")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Constants.Colors.primaryBlue)
                                .cornerRadius(12)
                        }
                        .disabled(isExporting)
                        .opacity(isExporting ? 0.6 : 1.0)
                    } else {
                        Button(action: {
                            // TODO: Share exported file
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Export File")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.green)
                            .cornerRadius(12)
                        }
                    }
                    
                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                }
                .padding(.horizontal, Constants.Spacing.large)
                .padding(.bottom, Constants.Spacing.large)
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func startExport() {
        isExporting = true
        exportProgress = 0
        
        // Simulate export progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            exportProgress += 0.05
            
            if exportProgress >= 1.0 {
                timer.invalidate()
                isExporting = false
                exportCompleted = true
            }
        }
    }
}

#Preview {
    PrivacySecurityView()
        .environmentObject(AuthenticationManager())
}
