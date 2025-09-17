//
//  LuxuryForgotPasswordView.swift
//  FitLifeAdvisorApp
//

import SwiftUI

struct LuxuryForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccessMessage = false
    @State private var errorMessage = ""
    @State private var animateElements = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Luxury Background
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: LuxuryTheme.Spacing.xLarge) {
                        // Header
                        luxuryHeaderSection
                            .scaleEffect(animateElements ? 1.0 : 0.8)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: animateElements)
                        
                        if showSuccessMessage {
                            // Success Message
                            luxurySuccessSection
                                .scaleEffect(animateElements ? 1.0 : 0.9)
                                .opacity(animateElements ? 1.0 : 0.0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: animateElements)
                        } else {
                            // Reset Password Form
                            luxuryResetForm
                                .offset(y: animateElements ? 0 : 50)
                                .opacity(animateElements ? 1.0 : 0.0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: animateElements)
                        }
                        
                        // Back to Login
                        luxuryBackSection
                            .offset(y: animateElements ? 0 : 20)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: animateElements)
                        
                        // Bottom spacing
                        Color.clear.frame(height: 50)
                    }
                    .padding(.horizontal, LuxuryTheme.Spacing.large)
                    .padding(.vertical, LuxuryTheme.Spacing.xLarge)
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
    }
    
    // MARK: - Header Section
    private var luxuryHeaderSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.large) {
            // Lock Icon
            ZStack {
                Circle()
                    .fill(LuxuryTheme.Gradients.goldGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: LuxuryTheme.Colors.goldPrimary.opacity(0.4), radius: 15, x: 0, y: 8)
                
                Image(systemName: showSuccessMessage ? "checkmark.shield.fill" : "lock.rotation")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Title and Description
            VStack(spacing: LuxuryTheme.Spacing.small) {
                Text(showSuccessMessage ? "Check Your Email" : "Forgot Password?")
                    .font(LuxuryTheme.Typography.title1.weight(.bold))
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Text(showSuccessMessage ? 
                     "We've sent a password reset link to your email address." :
                     "Don't worry, we'll send you reset instructions.")
                    .font(LuxuryTheme.Typography.body)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Reset Form
    private var luxuryResetForm: some View {
        VStack(spacing: LuxuryTheme.Spacing.large) {
            // Instructions
            VStack(spacing: LuxuryTheme.Spacing.small) {
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(LuxuryTheme.Typography.callout)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, LuxuryTheme.Spacing.medium)
            
            // Email Field
            LuxuryTextField(
                title: "Email Address",
                text: $email,
                placeholder: "Enter your email",
                icon: "envelope.fill",
                keyboardType: .emailAddress
            )
            
            // Send Reset Link Button
            Button(action: sendResetLinkAction) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                        Text("Send Reset Link")
                            .font(LuxuryTheme.Typography.headline.weight(.semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.large)
                        .fill(email.contains("@") ? LuxuryTheme.Gradients.goldGradient : LinearGradient(colors: [LuxuryTheme.Colors.tertiaryText], startPoint: .leading, endPoint: .trailing))
                        .shadow(color: email.contains("@") ? LuxuryTheme.Colors.goldPrimary.opacity(0.3) : .clear, radius: 10, x: 0, y: 4)
                )
            }
            .disabled(!email.contains("@") || isLoading)
            .buttonStyle(PressButtonStyle())
            
            // Error Message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(LuxuryTheme.Typography.caption)
                    .foregroundColor(LuxuryTheme.Colors.nutritionRed)
                    .padding(.top, LuxuryTheme.Spacing.small)
            }
        }
    }
    
    // MARK: - Success Section
    private var luxurySuccessSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.large) {
            // Success Message Card
            VStack(spacing: LuxuryTheme.Spacing.medium) {
                Text("Reset link sent!")
                    .font(LuxuryTheme.Typography.title2.weight(.bold))
                    .foregroundColor(LuxuryTheme.Colors.scanGreen)
                
                Text("We've sent a password reset link to:")
                    .font(LuxuryTheme.Typography.callout)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                
                Text(email)
                    .font(LuxuryTheme.Typography.callout.weight(.semibold))
                    .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                    .padding(.horizontal, LuxuryTheme.Spacing.medium)
                    .padding(.vertical, LuxuryTheme.Spacing.small)
                    .background(
                        RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.small)
                            .fill(LuxuryTheme.Colors.goldPrimary.opacity(0.1))
                    )
                
                Text("Check your email and follow the instructions to reset your password.")
                    .font(LuxuryTheme.Typography.body)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(LuxuryTheme.Spacing.large)
            .luxuryGlassCard()
            
            // Resend Button
            Button("Didn't receive the email? Resend") {
                sendResetLinkAction()
            }
            .font(LuxuryTheme.Typography.callout)
            .foregroundColor(LuxuryTheme.Colors.goldPrimary)
            .buttonStyle(PressButtonStyle())
        }
    }
    
    // MARK: - Back Section
    private var luxuryBackSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            Text(showSuccessMessage ? "Remember your password?" : "Remember your password?")
                .font(LuxuryTheme.Typography.body)
                .foregroundColor(LuxuryTheme.Colors.secondaryText)
            
            Button("Back to Sign In") {
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
    
    // MARK: - Helper Functions
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            animateElements = true
        }
    }
    
    private func sendResetLinkAction() {
        isLoading = true
        errorMessage = ""
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isLoading = false
            
            // Simulate success (replace with real API call)
            if email.contains("@") {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showSuccessMessage = true
                }
            } else {
                errorMessage = "Please enter a valid email address"
            }
        }
    }
}

#Preview {
    LuxuryForgotPasswordView()
}
