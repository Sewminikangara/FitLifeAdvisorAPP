//
//  ProfileSettingsView.swift
//  FitLifeAdvisorApp
//
//  Created by AI Assistant on 2025-09-09.
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Constants.Colors.primaryBlue.opacity(0.8),
                                        Constants.Colors.primaryBlue
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(String(authManager.currentUser?.name.prefix(1) ?? "U"))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authManager.currentUser?.name ?? "User")
                                .font(Constants.Typography.headline)
                                .foregroundColor(Constants.Colors.textDark)
                            
                            Text(authManager.currentUser?.email ?? "user@example.com")
                                .font(Constants.Typography.caption)
                                .foregroundColor(Constants.Colors.textLight)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, Constants.Spacing.small)
                }
                
                // Security Section
                Section("Security") {
                    HStack {
                        Image(systemName: authManager.checkBiometricAvailability() == .faceID ? "faceid" : "touchid")
                            .font(.title2)
                            .foregroundColor(Constants.Colors.primaryBlue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Biometric Authentication")
                                .font(Constants.Typography.body)
                                .foregroundColor(Constants.Colors.textDark)
                            
                            Text(authManager.isBiometricEnabled ? "Enabled" : "Disabled")
                                .font(Constants.Typography.caption)
                                .foregroundColor(Constants.Colors.textLight)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: .init(
                            get: { authManager.isBiometricEnabled },
                            set: { newValue in
                                if newValue {
                                    authManager.enableBiometricAuthentication()
                                } else {
                                    authManager.disableBiometricAuthentication()
                                }
                            }
                        ))
                        .disabled(authManager.checkBiometricAvailability() == .none)
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Image(systemName: "bell")
                                .font(.title2)
                                .foregroundColor(Constants.Colors.primaryBlue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Push Notifications")
                                    .font(Constants.Typography.body)
                                    .foregroundColor(Constants.Colors.textDark)
                                
                                Text("Manage your notification preferences")
                                    .font(Constants.Typography.caption)
                                    .foregroundColor(Constants.Colors.textLight)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(Constants.Colors.textLight)
                        }
                    }
                }
                
                // Account Section
                Section("Account") {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .font(.title2)
                                .foregroundColor(Constants.Colors.errorRed)
                            
                            Text("Sign Out")
                                .font(Constants.Typography.body)
                                .foregroundColor(Constants.Colors.errorRed)
                            
                            Spacer()
                        }
                    }
                }
            }
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
            Text("Are you sure you want to sign out?")
        }
    }
}

#Preview {
    ProfileSettingsView()
        .environmentObject(AuthenticationManager())
}
