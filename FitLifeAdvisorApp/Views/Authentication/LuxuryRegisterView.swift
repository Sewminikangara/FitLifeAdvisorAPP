//
//  LuxuryRegisterView.swift
//  FitLifeAdvisorApp
//
//   Registration Screen with premium design
//

import SwiftUI

struct LuxuryRegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthenticationManager()
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var agreeToTerms = false
    @State private var animateElements = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Luxury Background
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: LuxuryTheme.Spacing.large) {
                        // Header
                        luxuryHeaderSection
                            .scaleEffect(animateElements ? 1.0 : 0.8)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: animateElements)
                        
                        // Registration Form
                        luxuryRegistrationForm
                            .offset(y: animateElements ? 0 : 50)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: animateElements)
                        
                        // Login Link
                        luxuryLoginSection
                            .offset(y: animateElements ? 0 : 20)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: animateElements)
                        
                        // Bottom spacing
                        Color.clear.frame(height: 50)
                    }
                    .padding(.horizontal, LuxuryTheme.Spacing.large)
                    .padding(.vertical, LuxuryTheme.Spacing.large)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(LuxuryTheme.Colors.tertiaryText)
                    }
                }
            }
        }
        .onAppear {
            startAnimations()
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
                    .frame(width: 100, height: 100)
                    .shadow(color: LuxuryTheme.Colors.goldPrimary.opacity(0.4), radius: 15, x: 0, y: 8)
                
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Welcome Text
            VStack(spacing: LuxuryTheme.Spacing.small) {
                Text("Create Account")
                    .font(LuxuryTheme.Typography.title1.weight(.bold))
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Text("Join FitLife Advisor and start your fitness journey")
                    .font(LuxuryTheme.Typography.body)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // Registration Form
    private var luxuryRegistrationForm: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            // Full Name Field
            LuxuryTextField(
                title: "Full Name",
                text: $fullName,
                placeholder: "Enter your full name",
                icon: "person.fill"
            )
            
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
                placeholder: "Create a password",
                isVisible: $isPasswordVisible
            )
            
            // Confirm Password Field
            LuxuryPasswordField(
                title: "Confirm Password",
                password: $confirmPassword,
                placeholder: "Confirm your password",
                isVisible: $isConfirmPasswordVisible
            )
            
            // Password Requirements
            VStack(alignment: .leading, spacing: LuxuryTheme.Spacing.xxSmall) {
                Text("Password Requirements:")
                    .font(LuxuryTheme.Typography.caption.weight(.medium))
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                
                HStack {
                    Image(systemName: password.count >= 8 ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(password.count >= 8 ? LuxuryTheme.Colors.scanGreen : LuxuryTheme.Colors.tertiaryText)
                    Text("At least 8 characters")
                        .font(LuxuryTheme.Typography.caption)
                        .foregroundColor(LuxuryTheme.Colors.tertiaryText)
                }
                
                HStack {
                    Image(systemName: password == confirmPassword && !password.isEmpty ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(password == confirmPassword && !password.isEmpty ? LuxuryTheme.Colors.scanGreen : LuxuryTheme.Colors.tertiaryText)
                    Text("Passwords match")
                        .font(LuxuryTheme.Typography.caption)
                        .foregroundColor(LuxuryTheme.Colors.tertiaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Terms and Conditions
            HStack(alignment: .top, spacing: LuxuryTheme.Spacing.small) {
                Button(action: { agreeToTerms.toggle() }) {
                    Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(agreeToTerms ? LuxuryTheme.Colors.goldPrimary : LuxuryTheme.Colors.tertiaryText)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("I agree to the Terms of Service and Privacy Policy")
                        .font(LuxuryTheme.Typography.caption)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    
                    HStack {
                        Button("Terms of Service") {
                            // TODO: Show Terms of Service
                        }
                        .font(LuxuryTheme.Typography.caption)
                        .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                        
                        Text("and")
                            .font(LuxuryTheme.Typography.caption)
                            .foregroundColor(LuxuryTheme.Colors.tertiaryText)
                        
                        Button("Privacy Policy") {
                            // TODO: Show Privacy Policy
                        }
                        .font(LuxuryTheme.Typography.caption)
                        .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Register Button
            Button(action: registerAction) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.title2)
                        Text("Create Account")
                            .font(LuxuryTheme.Typography.headline.weight(.semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.large)
                        .fill(isFormValid ? LuxuryTheme.Gradients.goldGradient : LinearGradient(colors: [LuxuryTheme.Colors.tertiaryText], startPoint: .leading, endPoint: .trailing))
                        .shadow(color: isFormValid ? LuxuryTheme.Colors.goldPrimary.opacity(0.3) : .clear, radius: 10, x: 0, y: 4)
                )
            }
            .disabled(!isFormValid || authManager.isLoading)
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
    
    // Login Section
    private var luxuryLoginSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            Text("Already have an account?")
                .font(LuxuryTheme.Typography.body)
                .foregroundColor(LuxuryTheme.Colors.secondaryText)
            
            Button("Sign In") {
                dismiss()
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
    
    // Computed Properties
    private var isFormValid: Bool {
        return !fullName.isEmpty &&
               email.contains("@") &&
               password.count >= 8 &&
               password == confirmPassword &&
               agreeToTerms
    }
    
    // Helper Functions
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            animateElements = true
        }
    }
    
    private func registerAction() {
        authManager.signUp(fullName: fullName, email: email, password: password)
    }
}

#Preview {
    LuxuryRegisterView()
}
