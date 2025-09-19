//
//  ContentView.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showFaceIDTest = false
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        ZStack {
            // Background
            LuxuryTheme.Gradients.primaryBackground
                .ignoresSafeArea()
            
            // Tab View
            TabView(selection: $selectedTab) {
                LuxuryDashboardView()
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                                .font(.system(size: 22, weight: selectedTab == 0 ? .semibold : .medium))
                            Text("Home")
                                .font(.system(size: 11, weight: selectedTab == 0 ? .semibold : .medium))
                        }
                    }
                    .tag(0)
                
                LuxuryProgressView()
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTab == 1 ? "chart.line.uptrend.xyaxis.circle.fill" : "chart.line.uptrend.xyaxis.circle")
                                .font(.system(size: 22, weight: selectedTab == 1 ? .semibold : .medium))
                            Text("Progress")
                                .font(.system(size: 11, weight: selectedTab == 1 ? .semibold : .medium))
                        }
                    }
                    .tag(1)
                
                LuxuryLogView()
                    .tabItem {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(
                                        selectedTab == 2 ? 
                                            LuxuryTheme.Gradients.goldGradient :
                                            LinearGradient(colors: [LuxuryTheme.Colors.tertiaryText], startPoint: .top, endPoint: .bottom)
                                    )
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(selectedTab == 2 ? .white : LuxuryTheme.Colors.tertiaryText)
                            }
                            Text("Log")
                                .font(.system(size: 11, weight: selectedTab == 2 ? .semibold : .medium))
                        }
                    }
                    .tag(2)
                
                // Production Workout View with Real GPS & HealthKit
                ProductionWorkoutView()
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTab == 3 ? "figure.run.circle.fill" : "figure.run.circle")
                                .font(.system(size: 22, weight: selectedTab == 3 ? .semibold : .medium))
                            Text("Workouts")
                                .font(.system(size: 11, weight: selectedTab == 3 ? .semibold : .medium))
                        }
                    }
                    .tag(3)
                
                // More Tab with navigation to Plan and Profile
                LuxuryMoreView()
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTab == 4 ? "ellipsis.circle.fill" : "ellipsis.circle")
                                .font(.system(size: 22, weight: selectedTab == 4 ? .semibold : .medium))
                            Text("More")
                                .font(.system(size: 11, weight: selectedTab == 4 ? .semibold : .medium))
                        }
                    }
                    .tag(4)
            }
            .accentColor(LuxuryTheme.Colors.goldPrimary)
            .preferredColorScheme(.dark)
            .environmentObject(authManager)
            
            // Luxury Notification Banner Overlay
            LuxuryNotificationBanner()
        }
        .alert("🔒 Enable Face ID?", isPresented: $authManager.showBiometricSetupAlert) {
            Button("Enable Face ID") {
                authManager.confirmBiometricSetup()
            }
            Button("Not Now", role: .cancel) {
                authManager.skipBiometricSetup()
            }
            Button("Test Face ID") {
                showFaceIDTest = true
                authManager.skipBiometricSetup()
            }
        } message: {
            Text("Use Face ID to quickly and securely access your FitLife Advisor account for the best experience.")
        }
        .sheet(isPresented: $showFaceIDTest) {
            FaceIDTestView()
        }
    }
}

// Notification Banner
struct LuxuryNotificationBanner: View {
    @State private var showBanner = false
    
    var body: some View {
        VStack {
            if showBanner {
                HStack {
                    ZStack {
                        Circle()
                            .fill(LuxuryTheme.Gradients.goldGradient)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Achievement Unlocked! 🎉")
                            .font(LuxuryTheme.Typography.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(LuxuryTheme.Colors.primaryText)
                        
                        Text("Your health score increased to 96/100")
                            .font(LuxuryTheme.Typography.caption)
                            .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showBanner = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(LuxuryTheme.Colors.tertiaryText)
                    }
                }
                .padding(LuxuryTheme.Spacing.small)
                .luxuryGlassCard()
                .padding(.horizontal, LuxuryTheme.Spacing.medium)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showBanner)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showBanner = true
                }
            }
            
            // Auto-hide after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showBanner = false
                }
            }
        }
    }
}

// More View
struct LuxuryMoreView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Luxury Background
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: LuxuryTheme.Spacing.large) {
                        // Header
                        VStack(spacing: LuxuryTheme.Spacing.medium) {
                            Text("More")
                                .font(LuxuryTheme.Typography.title1)
                                .foregroundColor(LuxuryTheme.Colors.primaryText)
                                .padding(.top, LuxuryTheme.Spacing.large)
                            
                            Text("Additional features and settings")
                                .font(LuxuryTheme.Typography.callout)
                                .foregroundColor(LuxuryTheme.Colors.secondaryText)
                        }
                        
                        // Navigation Cards
                        VStack(spacing: LuxuryTheme.Spacing.medium) {
                            // Healthy Places Navigation
                            NavigationLink(destination: HealthyStoreMapView()) {
                                LuxuryMoreCard(
                                    title: "Find Healthy Places",
                                    subtitle: "Discover gyms, organic stores & healthy restaurants",
                                    icon: "map.fill",
                                    color: LuxuryTheme.Colors.scanTeal
                                )
                            }
                            
                            // Plan Navigation
                            NavigationLink(destination: LuxuryPlanView()) {
                                LuxuryMoreCard(
                                    title: "Plan",
                                    subtitle: "Workout planning and scheduling",
                                    icon: "calendar.badge.plus",
                                    color: LuxuryTheme.Colors.goldPrimary
                                )
                            }
                            
                            // Profile Navigation
                            NavigationLink(destination: LuxuryProfileView()) {
                                LuxuryMoreCard(
                                    title: "Profile",
                                    subtitle: "Personal settings and preferences",
                                    icon: "person.crop.circle",
                                    color: LuxuryTheme.Colors.goldPrimary
                                )
                            }
                            
                            // Settings
                            NavigationLink(destination: ModernSettingsView()) {
                                LuxuryMoreCard(
                                    title: "Settings",
                                    subtitle: "App preferences and configuration",
                                    icon: "gearshape",
                                    color: LuxuryTheme.Colors.goldSecondary
                                )
                            }
                            
                            // Help & Support
                            NavigationLink(destination: HelpSupportView()) {
                                LuxuryMoreCard(
                                    title: "Help & Support",
                                    subtitle: "Get help and contact support",
                                    icon: "questionmark.circle",
                                    color: LuxuryTheme.Colors.goldSecondary
                                )
                            }

                            // All Screens (Navigation Hub)
                            NavigationLink(destination: AllScreensView()) {
                                LuxuryMoreCard(
                                    title: "All Screens",
                                    subtitle: "Explore every page quickly",
                                    icon: "square.grid.2x2",
                                    color: LuxuryTheme.Colors.aiBlue
                                )
                            }
                        }
                        .padding(.horizontal, LuxuryTheme.Spacing.medium)
                        
                        // Bottom spacing
                        Color.clear.frame(height: 120)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

//  More Card
struct LuxuryMoreCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: LuxuryTheme.Spacing.medium) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Text(subtitle)
                    .font(LuxuryTheme.Typography.caption)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(LuxuryTheme.Colors.tertiaryText)
        }
        .padding(LuxuryTheme.Spacing.medium)
        .luxuryGlassCard()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
}
