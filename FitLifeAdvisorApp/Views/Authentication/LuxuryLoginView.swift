//
//  LuxuryLoginView.swift
//  FitLifeAdvisorApp
//

// Login Screen with premium design


import SwiftUI

struct LuxuryLoginView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegister = false
    @State private var showingForgotPassword = false
    @State private var isPasswordVisible = false
    @State private var animateElements = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Luxury Background
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: LuxuryTheme.Spacing.xLarge) {
                        // Logo and Welcome Section
                        luxuryHeaderSection
                            .scaleEffect(animateElements ? 1.0 : 0.8)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: animateElements)
                        
                        // Login Form
                        luxuryLoginForm
                            .offset(y: animateElements ? 0 : 50)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: animateElements)
                        
                        // Biometric Login (if available)
                        if authManager.checkBiometricAvailability() != .none {
                            luxuryBiometricSection
                                .offset(y: animateElements ? 0 : 30)
                                .opacity(animateElements ? 1.0 : 0.0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: animateElements)
                        }
                        
                        // Register Link
                        luxuryRegisterSection
                            .offset(y: animateElements ? 0 : 20)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: animateElements)
                        
                        // Bottom spacing
                        Color.clear.frame(height: 50)
                    }
                    .padding(.horizontal, LuxuryTheme.Spacing.large)
                    .padding(.vertical, LuxuryTheme.Spacing.xLarge)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            startAnimations()
        }
        .sheet(isPresented: $showingRegister) {
            LuxuryRegisterView()
        }
        .sheet(isPresented: $showingForgotPassword) {
            LuxuryForgotPasswordView()
        }
        .environmentObject(authManager)
    }
    
    // Header Section
    private var luxuryHeaderSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.large) {
            // App Logo/Icon
            ZStack {
                Circle()
                    .fill(LuxuryTheme.Gradients.goldGradient)
                    .frame(width: 120, height: 120)
                    .shadow(color: LuxuryTheme.Colors.goldPrimary.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Welcome Text
            VStack(spacing: LuxuryTheme.Spacing.small) {
                Text("Welcome Back")
                    .font(LuxuryTheme.Typography.title1.weight(.bold))
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Text("Sign in to continue your fitness journey")
                    .font(LuxuryTheme.Typography.body)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    //Login Form
    private var luxuryLoginForm: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            // Email Field
            LuxuryTextField(
                title: "Email",
                text: $email,
                placeholder: "Enter your email",
                icon: "envelope.fill",
                keyboardType: .emailAddress
            )
            
            // Password Field
            LuxuryPasswordField(
                title: "Password",
                password: $password,
                placeholder: "Enter your password",
                isVisible: $isPasswordVisible
            )
            
            // Forgot Password Link
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    showingForgotPassword = true
                }
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.goldPrimary)
            }
            
            // Login Button
            Button(action: loginAction) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                        Text("Sign In")
                            .font(LuxuryTheme.Typography.headline.weight(.semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.large)
                        .fill(LuxuryTheme.Gradients.goldGradient)
                        .shadow(color: LuxuryTheme.Colors.goldPrimary.opacity(0.3), radius: 10, x: 0, y: 4)
                )
            }
            .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
            .buttonStyle(PressButtonStyle())
            
            // Error Message
            if !authManager.errorMessage.isEmpty {
                Text(authManager.errorMessage)
                    .font(LuxuryTheme.Typography.caption)
                    .foregroundColor(LuxuryTheme.Colors.nutritionRed)
                    .padding(.top, LuxuryTheme.Spacing.small)
            }
        }
    }
    
    //  Biometric Section
    private var luxuryBiometricSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            // Divider
            HStack {
                Rectangle()
                    .fill(LuxuryTheme.Colors.cardBorder)
                    .frame(height: 1)
                
                Text("or")
                    .font(LuxuryTheme.Typography.caption)
                    .foregroundColor(LuxuryTheme.Colors.tertiaryText)
                    .padding(.horizontal, LuxuryTheme.Spacing.medium)
                
                Rectangle()
                    .fill(LuxuryTheme.Colors.cardBorder)
                    .frame(height: 1)
            }
            
            // Biometric Login Button
            Button(action: biometricLoginAction) {
                HStack {
                    Image(systemName: getBiometricIcon())
                        .font(.title2)
                    Text("Sign in with \(getBiometricText())")
                        .font(LuxuryTheme.Typography.callout.weight(.medium))
                }
                .foregroundColor(LuxuryTheme.Colors.aiBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.medium)
                        .stroke(LuxuryTheme.Colors.aiBlue, lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.medium)
                                .fill(LuxuryTheme.Colors.aiBlue.opacity(0.1))
                        )
                )
            }
            .buttonStyle(PressButtonStyle())
        }
    }
    
    // Register Section
    private var luxuryRegisterSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            Text("Don't have an account?")
                .font(LuxuryTheme.Typography.body)
                .foregroundColor(LuxuryTheme.Colors.secondaryText)
            
            Button("Create Account") {
                showingRegister = true
            }
            .font(LuxuryTheme.Typography.headline.weight(.semibold))
            .foregroundColor(LuxuryTheme.Colors.goldPrimary)
            .padding(.vertical, LuxuryTheme.Spacing.small)
            .padding(.horizontal, LuxuryTheme.Spacing.large)
            .background(
                RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.medium)
                    .stroke(LuxuryTheme.Colors.goldPrimary, lineWidth: 1.5)
            )
            .buttonStyle(PressButtonStyle())
        }
    }
    
    // Helper Functions
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            animateElements = true
        }
    }
    
    private func loginAction() {
        authManager.signIn(email: email, password: password)
    }
    
    private func biometricLoginAction() {
        authManager.authenticateWithBiometrics()
    }
    
    private func getBiometricIcon() -> String {
        switch authManager.checkBiometricAvailability() {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "lock.fill"
        }
    }
    
    private func getBiometricText() -> String {
        switch authManager.checkBiometricAvailability() {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometric"
        }
    }
}

// Luxury Text Field Components

struct LuxuryTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: LuxuryTheme.Spacing.xxSmall) {
            Text(title)
                .font(LuxuryTheme.Typography.caption.weight(.medium))
                .foregroundColor(LuxuryTheme.Colors.secondaryText)
            
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                    .frame(width: 24)
                
                TextField(placeholder, text: $text)
                    .font(LuxuryTheme.Typography.body)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(LuxuryTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.medium)
                    .fill(LuxuryTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.medium)
                            .stroke(text.isEmpty ? LuxuryTheme.Colors.cardBorder : LuxuryTheme.Colors.goldPrimary, lineWidth: 1)
                    )
            )
        }
    }
}

struct LuxuryPasswordField: View {
    let title: String
    @Binding var password: String
    let placeholder: String
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: LuxuryTheme.Spacing.xxSmall) {
            Text(title)
                .font(LuxuryTheme.Typography.caption.weight(.medium))
                .foregroundColor(LuxuryTheme.Colors.secondaryText)
            
            HStack {
                Image(systemName: "lock.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                    .frame(width: 24)
                
                if isVisible {
                    TextField(placeholder, text: $password)
                        .font(LuxuryTheme.Typography.body)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                } else {
                    SecureField(placeholder, text: $password)
                        .font(LuxuryTheme.Typography.body)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                }
                
                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(LuxuryTheme.Colors.tertiaryText)
                }
            }
            .padding(LuxuryTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.medium)
                    .fill(LuxuryTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.medium)
                            .stroke(password.isEmpty ? LuxuryTheme.Colors.cardBorder : LuxuryTheme.Colors.goldPrimary, lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    LuxuryLoginView()
}
