//
//  AuthenticationView.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//
import SwiftUI

struct AuthenticationView: View {
    @State private var isSignUp = false
    @State private var showBiometricLogin = false
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: Constants.Spacing.medium) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Constants.Colors.primaryBlue)
                
                Text(isSignUp ? "Create Account" : "Welcome Back")
                    .font(Constants.Typography.largeTitle.weight(.bold))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(isSignUp ? "Join FitLife Advisor today" : "Sign in to continue your health journey")
                    .font(Constants.Typography.body)
                    .foregroundColor(Constants.Colors.textLight)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Constants.Spacing.extraLarge)
            .padding(.horizontal, Constants.Spacing.large)
            
            // Biometric Authentication (only show if not signing up and biometric is available)
            if !isSignUp && authManager.checkBiometricAvailability() != .none && authManager.isBiometricEnabled {
                VStack(spacing: Constants.Spacing.medium) {
                    Button(action: {
                        authManager.authenticateWithBiometrics()
                    }) {
                        HStack {
                            Image(systemName: biometricIcon)
                                .font(.title2)
                            Text("Sign in with \(biometricText)")
                                .font(.body.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.Colors.primaryBlue)
                        .cornerRadius(25)
                    }
                    
                    Text("or")
                        .font(Constants.Typography.caption)
                        .foregroundColor(Constants.Colors.textLight)
                }
                .padding(.horizontal, Constants.Spacing.large)
                .padding(.top, Constants.Spacing.large)
            }
            
            Spacer()
            
            // Auth Form
            if isSignUp {
                SignUpFormView()
            } else {
                LoginFormView()
            }
            
            Spacer()
            
            // Toggle Auth Mode
            HStack {
                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
                
                Button(isSignUp ? "Sign In" : "Sign Up") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSignUp.toggle()
                        authManager.errorMessage = "" // Clear error when switching
                    }
                }
                .font(Constants.Typography.caption.weight(.medium))
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(.bottom, Constants.Spacing.extraLarge)
        }
        .background(Constants.Colors.backgroundGray)
        .onTapGesture {
            hideKeyboard()
        }
        .alert("Authentication Error", isPresented: .constant(authManager.authenticationError != nil)) {
            Button("OK") {
                authManager.authenticationError = nil
            }
        } message: {
            Text(authManager.authenticationError ?? "")
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

struct LoginFormView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: Constants.Spacing.large) {
            VStack(spacing: Constants.Spacing.medium) {
                CustomTextField(
                    title: "Email",
                    text: $email,
                    keyboardType: .emailAddress,
                    placeholder: "Enter your email"
                )
                
                CustomTextField(
                    title: "Password",
                    text: $password,
                    isSecure: true,
                    placeholder: "Enter your password"
                )
            }
            
            // Error Message
            if !authManager.errorMessage.isEmpty {
                Text(authManager.errorMessage)
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.errorRed)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Spacing.large)
            }
            
            VStack(spacing: Constants.Spacing.medium) {
                CustomButton(
                    title: "Sign In",
                    action: {
                        hideKeyboard()
                        authManager.signIn(email: email, password: password)
                    },
                    isLoading: authManager.isLoading,
                    isEnabled: !email.isEmpty && !password.isEmpty
                )
                
                // Passcode authentication option
                if authManager.checkBiometricAvailability() != .none && !authManager.isBiometricEnabled {
                    Button(action: {
                        authManager.authenticateWithPasscode()
                    }) {
                        HStack {
                            Image(systemName: "key")
                            Text("Use Device Passcode")
                        }
                        .font(Constants.Typography.caption)
                        .foregroundColor(Constants.Colors.primaryBlue)
                    }
                }
                
                Button("Forgot Password?") {
                    // TODO: Implement forgot password
                }
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.primaryBlue)
            }
        }
        .padding(.horizontal, Constants.Spacing.large)
    }
}

struct SignUpFormView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @EnvironmentObject var authManager: AuthenticationManager
    
    var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        email.contains("@")
    }
    
    var body: some View {
        VStack(spacing: Constants.Spacing.large) {
            VStack(spacing: Constants.Spacing.medium) {
                CustomTextField(
                    title: "Full Name",
                    text: $name,
                    placeholder: "Enter your full name"
                )
                
                CustomTextField(
                    title: "Email",
                    text: $email,
                    keyboardType: .emailAddress,
                    placeholder: "Enter your email"
                )
                
                CustomTextField(
                    title: "Password",
                    text: $password,
                    isSecure: true,
                    placeholder: "Create a password"
                )
                
                CustomTextField(
                    title: "Confirm Password",
                    text: $confirmPassword,
                    isSecure: true,
                    placeholder: "Confirm your password"
                )
            }
            
            // Password Requirements
            if !password.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    PasswordRequirement(
                        text: "At least 6 characters",
                        isValid: password.count >= 6
                    )
                    PasswordRequirement(
                        text: "Passwords match",
                        isValid: password == confirmPassword && !confirmPassword.isEmpty
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Error Message
            if !authManager.errorMessage.isEmpty {
                Text(authManager.errorMessage)
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.errorRed)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Spacing.large)
            }
            
            CustomButton(
                title: "Create Account",
                action: {
                    hideKeyboard()
                    authManager.signUp(email: email, password: password, name: name)
                },
                isLoading: authManager.isLoading,
                isEnabled: isFormValid
            )
        }
        .padding(.horizontal, Constants.Spacing.large)
    }
}

struct PasswordRequirement: View {
    let text: String
    let isValid: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? Constants.Colors.successGreen : Constants.Colors.textLight)
                .font(.caption)
            
            Text(text)
                .font(Constants.Typography.small)
                .foregroundColor(isValid ? Constants.Colors.successGreen : Constants.Colors.textLight)
        }
    }
}

// Helper extension to hide keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
