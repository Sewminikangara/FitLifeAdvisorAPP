//
//  BiometricLoginView.swift
//  FitLifeAdvisorApp
//
//  Created by sewmini 010 on 2025-09-09.
//

import SwiftUI

struct BiometricLoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var showTraditionalLogin = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Constants.Colors.primaryBlue.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("FitLife Advisor")
                        .font(Constants.Typography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your personal fitness companion")
                        .font(Constants.Typography.title3)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    if authManager.checkBiometricAvailability() != .none && authManager.isBiometricEnabled {
                        Button(action: {
                            authManager.authenticateWithBiometrics()
                        }) {
                            HStack {
                                Image(systemName: biometricIcon)
                                    .font(.title2)
                                Text("Sign in with \(biometricText)")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(Constants.Colors.primaryBlue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                    
                    if authManager.checkBiometricAvailability() != .none {
                        Button(action: {
                            authManager.authenticateWithPasscode()
                        }) {
                            HStack {
                                Image(systemName: "key")
                                    .font(.title2)
                                Text("Use Device Passcode")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    
                    Button(action: {
                        showTraditionalLogin = true
                    }) {
                        HStack {
                            Image(systemName: "person.circle")
                                .font(.title2)
                            Text("Sign in with Email")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .alert("Authentication Error", isPresented: .constant(authManager.authenticationError != nil)) {
            Button("OK") {
                authManager.authenticationError = nil
            }
        } message: {
            Text(authManager.authenticationError ?? "")
        }
        .sheet(isPresented: $showTraditionalLogin) {
            AuthenticationView()
                .environmentObject(authManager)
        }
        .onAppear {
            // Auto-trigger biometric authentication when view appears
            if authManager.isBiometricEnabled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    authManager.authenticateWithBiometrics()
                }
            }
        }
    }
    
    private var biometricIcon: String {
        switch authManager.checkBiometricAvailability() {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return "lock"
        }
    }
    
    private var biometricText: String {
        switch authManager.checkBiometricAvailability() {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .none:
            return "Biometrics"
        }
    }
}

#Preview {
    BiometricLoginView()
        .environmentObject(AuthenticationManager())
}
