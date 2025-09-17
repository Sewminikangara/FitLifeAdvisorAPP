//
//  WelcomeScreensView.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import SwiftUI

struct WelcomeScreensView: View {
    @State private var currentPage = 0
    @State private var showAuthScreen = false
    @EnvironmentObject var authManager: AuthenticationManager
    
    private let welcomePages = [
        WelcomePage(
            title: "Welcome to FitLife Advisor",
            subtitle: "Your personal health and fitness companion",
            imageName: "heart.fill",
            description: "Track your meals, monitor your fitness, and achieve your health goals with AI-powered insights."
        ),
        WelcomePage(
            title: "Smart Meal Analysis",
            subtitle: "AI-powered food recognition",
            imageName: "camera.fill",
            description: "Simply take a photo of your meal and get instant nutrition analysis with our advanced AI technology."
        ),
        WelcomePage(
            title: "Fitness Integration",
            subtitle: "Connect with HealthKit",
            imageName: "figure.run",
            description: "Seamlessly sync your workouts and health data for comprehensive fitness tracking."
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Page Content
            TabView(selection: $currentPage) {
                ForEach(0..<welcomePages.count, id: \.self) { index in
                    WelcomePageView(page: welcomePages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<welcomePages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Constants.Colors.primaryBlue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.bottom, Constants.Spacing.large)
            
            // Action Buttons
            VStack(spacing: Constants.Spacing.medium) {
                if currentPage == welcomePages.count - 1 {
                    CustomButton(title: "Get Started", action: {
                        showAuthScreen = true
                    })
                    
                    Button("Already have an account? Sign In") {
                        showAuthScreen = true
                    }
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.primaryBlue)
                } else {
                    HStack {
                        Button("Skip") {
                            showAuthScreen = true
                        }
                        .font(Constants.Typography.body)
                        .foregroundColor(Constants.Colors.textLight)
                        
                        Spacer()
                        
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .font(Constants.Typography.body)
                        .foregroundColor(Constants.Colors.primaryBlue)
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.large)
            .padding(.bottom, Constants.Spacing.extraLarge)
        }
        .background(Constants.Colors.backgroundGray)
        .fullScreenCover(isPresented: $showAuthScreen) {
            // Show biometric login if user has it enabled, otherwise show traditional auth
            if authManager.isBiometricEnabled || authManager.checkBiometricAvailability() != .none {
                BiometricLoginView()
                    .environmentObject(authManager)
            } else {
                AuthenticationView()
                    .environmentObject(authManager)
            }
        }
    }
}

struct WelcomePage {
    let title: String
    let subtitle: String
    let imageName: String
    let description: String
}

struct WelcomePageView: View {
    let page: WelcomePage
    
    var body: some View {
        VStack(spacing: Constants.Spacing.large) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80))
                .foregroundColor(Constants.Colors.primaryBlue)
                .padding(.bottom, Constants.Spacing.medium)
            
            // Title
            Text(page.title)
                .font(Constants.Typography.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.textDark)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.Spacing.large)
            
            // Subtitle
            Text(page.subtitle)
                .font(Constants.Typography.headline)
                .foregroundColor(Constants.Colors.primaryBlue)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.Spacing.large)
            
            // Description
            Text(page.description)
                .font(Constants.Typography.body)
                .foregroundColor(Constants.Colors.textLight)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .padding(.horizontal, Constants.Spacing.extraLarge)
            
            Spacer()
        }
    }
}
#Preview {
    WelcomeScreensView()
}
