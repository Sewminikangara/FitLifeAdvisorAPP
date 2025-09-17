//
//  LuxuryProfileView.swift
//  FitLifeAdvisorApp
//
//  Luxury Profile View with premium design
//

import SwiftUI

struct LuxuryProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingSettings = false
    @State private var showingPersonalInfo = false
    @State private var showingGoals = false
    @State private var showingPrivacy = false
    @State private var showingHelp = false
    @State private var showingNotifications = false
    @State private var showingAchievements = false
    @State private var animateProfile = false
    @State private var animateStats = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Luxury Background
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Luxury Profile Header
                        luxuryProfileHeader
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.medium)
                        
                        // Premium Health Score
                        premiumHealthScoreSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Achievement Showcase
                        achievementShowcaseSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Premium Stats Overview
                        premiumStatsSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Luxury Menu Sections
                        luxuryMenuSections
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Premium Settings
                        premiumSettingsSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Luxury Sign Out
                        luxurySignOutSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Bottom spacing
                        Color.clear.frame(height: 120)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            startAnimations()
        }
        .sheet(isPresented: $showingSettings) {
            ModernSettingsView()
                .environmentObject(authManager)
                .environmentObject(AppSettings.shared)
        }
        .sheet(isPresented: $showingPersonalInfo) {
            LuxuryPersonalInfoView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingGoals) {
            GoalsPreferencesView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacySecurityView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingHelp) {
            HelpSupportView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingAchievements) {
            LuxuryAchievementsView()
        }
    }
    
    // MARK: - Luxury Profile Header
    private var luxuryProfileHeader: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Profile")
                        .font(LuxuryTheme.Typography.title1)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text("Premium Health Dashboard")
                        .font(LuxuryTheme.Typography.callout)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                }
                
                Spacer()
                
                // Settings Button
                Button(action: { showingSettings = true }) {
                    ZStack {
                        Circle()
                            .fill(LuxuryTheme.Colors.cardBackground)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(LuxuryTheme.Colors.cardBorder, lineWidth: 1)
                            )
                        
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                    }
                    .scaleEffect(animateProfile ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateProfile)
                }
            }
            
            // Premium Profile Card
            VStack(spacing: LuxuryTheme.Spacing.medium) {
                // Profile Avatar and Info
                HStack(spacing: LuxuryTheme.Spacing.medium) {
                    ZStack {
                        Circle()
                            .fill(LuxuryTheme.Gradients.goldGradient)
                            .frame(width: 80, height: 80)
                            .shadow(color: LuxuryTheme.Colors.goldPrimary.opacity(0.3), radius: 15, x: 0, y: 8)
                        
                        Text(String(authManager.currentUser?.name.prefix(1) ?? "U").uppercased())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(animateProfile ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateProfile)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(authManager.currentUser?.name ?? "Health Enthusiast")
                            .font(LuxuryTheme.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(LuxuryTheme.Colors.primaryText)
                        
                        Text(authManager.currentUser?.email ?? "user@fitlife.com")
                            .font(LuxuryTheme.Typography.body)
                            .foregroundColor(LuxuryTheme.Colors.secondaryText)
                        
                        // Premium Badge
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                            
                            Text("PREMIUM MEMBER")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LuxuryTheme.Colors.goldPrimary.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(LuxuryTheme.Colors.goldPrimary.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    
                    Spacer()
                }
                .padding(LuxuryTheme.Spacing.medium)
                .luxuryGlassCard()
            }
        }
    }
    
    // MARK: - Premium Health Score
    private var premiumHealthScoreSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(LuxuryTheme.Colors.aiBlue)
                
                Text("AI Health Score")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
            }
            
            VStack(spacing: LuxuryTheme.Spacing.medium) {
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Overall Health Score")
                            .font(LuxuryTheme.Typography.callout)
                            .foregroundColor(LuxuryTheme.Colors.secondaryText)
                        
                        Text("96/100")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(LuxuryTheme.Colors.aiBlue)
                        
                        Text("Excellent Progress!")
                            .font(LuxuryTheme.Typography.body)
                            .foregroundColor(LuxuryTheme.Colors.scanGreen)
                        
                        Text("You're in the top 5% of users")
                            .font(LuxuryTheme.Typography.caption)
                            .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    // AI Score Ring
                    ZStack {
                        Circle()
                            .stroke(LuxuryTheme.Colors.cardBorder, lineWidth: 8)
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .trim(from: 0, to: animateStats ? 0.96 : 0)
                            .stroke(
                                LinearGradient(
                                    colors: [LuxuryTheme.Colors.aiBlue, LuxuryTheme.Colors.aiBlueSecondary],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 2.0).delay(0.5), value: animateStats)
                        
                        VStack {
                            Text("96")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(LuxuryTheme.Colors.primaryText)
                            Text("%")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(LuxuryTheme.Colors.secondaryText)
                        }
                    }
                }
                .padding(LuxuryTheme.Spacing.medium)
                .luxuryGlassCard()
            }
        }
    }
    
    // MARK: - Achievement Showcase
    private var achievementShowcaseSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                
                Text("Recent Achievements")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
                
                Button("View All") {
                    showingAchievements = true
                }
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.goldPrimary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LuxuryTheme.Spacing.small) {
                    LuxuryAchievementBadge(
                        title: "Diamond Streak",
                        description: "30 days perfect",
                        icon: "crown.fill",
                        colors: [LuxuryTheme.Colors.goldPrimary, LuxuryTheme.Colors.goldSecondary]
                    )
                    
                    LuxuryAchievementBadge(
                        title: "Workout Warrior",
                        description: "100 workouts",
                        icon: "figure.strengthtraining.traditional",
                        colors: [LuxuryTheme.Colors.workoutPurple, LuxuryTheme.Colors.workoutViolet]
                    )
                    
                    LuxuryAchievementBadge(
                        title: "Nutrition Master",
                        description: "500 meals logged",
                        icon: "fork.knife",
                        colors: [LuxuryTheme.Colors.nutritionRed, LuxuryTheme.Colors.nutritionOrange]
                    )
                    
                    LuxuryAchievementBadge(
                        title: "Step Champion",
                        description: "1M steps total",
                        icon: "figure.walk",
                        colors: [LuxuryTheme.Colors.scanTeal, LuxuryTheme.Colors.scanGreen]
                    )
                }
                .padding(.horizontal, LuxuryTheme.Spacing.medium)
            }
        }
    }
    
    // MARK: - Premium Stats
    private var premiumStatsSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("Health Statistics")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: LuxuryTheme.Spacing.small), count: 2), spacing: LuxuryTheme.Spacing.small) {
                LuxuryStatCard(
                    title: "Total Workouts",
                    value: "127",
                    subtitle: "This year",
                    icon: "figure.run",
                    color: LuxuryTheme.Colors.workoutPurple
                )
                
                LuxuryStatCard(
                    title: "Meals Logged",
                    value: "523",
                    subtitle: "This year",
                    icon: "fork.knife",
                    color: LuxuryTheme.Colors.nutritionRed
                )
                
                LuxuryStatCard(
                    title: "Weight Progress",
                    value: "-5.2kg",
                    subtitle: "Since start",
                    icon: "scalemass.fill",
                    color: LuxuryTheme.Colors.nutritionOrange
                )
                
                LuxuryStatCard(
                    title: "Active Days",
                    value: "89%",
                    subtitle: "This month",
                    icon: "calendar",
                    color: LuxuryTheme.Colors.aiBlue
                )
            }
        }
    }
    
    // MARK: - Luxury Menu Sections
    private var luxuryMenuSections: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("Account & Settings")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
            }
            
            VStack(spacing: LuxuryTheme.Spacing.xxxSmall) {
                LuxuryMenuRow(
                    icon: "person.fill",
                    title: "Personal Information",
                    subtitle: "Update your profile details",
                    action: { showingPersonalInfo = true }
                )
                
                LuxuryMenuRow(
                    icon: "target",
                    title: "Goals & Preferences",
                    subtitle: "Set your fitness targets",
                    action: { showingGoals = true }
                )
                
                LuxuryMenuRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Manage your alerts",
                    action: { showingNotifications = true }
                )
                
                LuxuryMenuRow(
                    icon: "lock.fill",
                    title: "Privacy & Security",
                    subtitle: "Protect your data",
                    action: { showingPrivacy = true }
                )
                
                LuxuryMenuRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    subtitle: "Get assistance",
                    action: { showingHelp = true }
                )
            }
        }
    }
    
    // MARK: - Premium Settings
    private var premiumSettingsSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("Premium Features")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
            }
            
            VStack(spacing: LuxuryTheme.Spacing.xxxSmall) {
                LuxuryPremiumFeatureRow(
                    icon: "brain.head.profile",
                    title: "AI Health Coach",
                    subtitle: "Personalized recommendations",
                    isActive: true
                )
                
                LuxuryPremiumFeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Advanced Analytics",
                    subtitle: "Detailed health insights",
                    isActive: true
                )
                
                LuxuryPremiumFeatureRow(
                    icon: "camera.macro",
                    title: "Smart Food Recognition",
                    subtitle: "AI-powered meal analysis",
                    isActive: true
                )
                
                LuxuryPremiumFeatureRow(
                    icon: "crown.fill",
                    title: "Premium Workouts",
                    subtitle: "Exclusive fitness programs",
                    isActive: true
                )
            }
        }
    }
    
    // MARK: - Luxury Sign Out
    private var luxurySignOutSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            Button(action: {
                authManager.signOut()
            }) {
                HStack(spacing: LuxuryTheme.Spacing.small) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(LuxuryTheme.Colors.nutritionRed)
                    
                    Text("Sign Out")
                        .font(LuxuryTheme.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(LuxuryTheme.Colors.nutritionRed)
                    
                    Spacer()
                }
                .padding(LuxuryTheme.Spacing.medium)
                .background(
                    RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.large)
                        .fill(LuxuryTheme.Colors.nutritionRed.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.large)
                                .stroke(LuxuryTheme.Colors.nutritionRed.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PressButtonStyle())
            
            Text("App Version 2.1.0 • Premium Edition")
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.tertiaryText)
                .padding(.bottom, LuxuryTheme.Spacing.medium)
        }
    }
    
    // MARK: - Helper Functions
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
            animateProfile = true
        }
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.3)) {
            animateStats = true
        }
    }
}

// MARK: - Supporting Luxury Components

struct LuxuryAchievementBadge: View {
    let title: String
    let description: String
    let icon: String
    let colors: [Color]
    
    var body: some View {
        VStack(spacing: LuxuryTheme.Spacing.xxSmall) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                    .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 10, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 80)
    }
}

struct LuxuryStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: LuxuryTheme.Spacing.xxSmall) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(LuxuryTheme.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(LuxuryTheme.Typography.callout)
                .foregroundColor(LuxuryTheme.Colors.primaryText)
            
            Text(subtitle)
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(LuxuryTheme.Spacing.small)
        .luxuryCard()
    }
}

struct LuxuryMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: LuxuryTheme.Spacing.small) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LuxuryTheme.Colors.goldPrimary.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(LuxuryTheme.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text(subtitle)
                        .font(LuxuryTheme.Typography.caption)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(LuxuryTheme.Colors.tertiaryText)
            }
            .padding(LuxuryTheme.Spacing.small)
            .luxuryCard()
        }
        .buttonStyle(PressButtonStyle())
    }
}

struct LuxuryPremiumFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: LuxuryTheme.Spacing.small) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LuxuryTheme.Gradients.goldGradient)
                    .frame(width: 40, height: 40)
                    .shadow(color: LuxuryTheme.Colors.goldPrimary.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(LuxuryTheme.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    if isActive {
                        Text("ACTIVE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(LuxuryTheme.Colors.scanGreen)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LuxuryTheme.Colors.scanGreen.opacity(0.2))
                            )
                    }
                }
                
                Text(subtitle)
                    .font(LuxuryTheme.Typography.caption)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isActive ? LuxuryTheme.Colors.scanGreen : LuxuryTheme.Colors.tertiaryText)
        }
        .padding(LuxuryTheme.Spacing.small)
        .luxuryCard()
    }
}

// MARK: - Placeholder Views

struct LuxurySettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: LuxuryTheme.Spacing.xLarge) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 80))
                        .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                    
                    Text("Luxury Settings")
                        .font(LuxuryTheme.Typography.title1)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text("Coming Soon")
                        .font(LuxuryTheme.Typography.body)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                }
            }
        }
    }
}

struct LuxuryPersonalInfoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: LuxuryTheme.Spacing.xLarge) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 80))
                        .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                    
                    Text("Personal Information")
                        .font(LuxuryTheme.Typography.title1)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text("Coming Soon")
                        .font(LuxuryTheme.Typography.body)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                }
            }
        }
    }
}

struct LuxuryAchievementsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: LuxuryTheme.Spacing.xLarge) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 80))
                        .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                    
                    Text("Achievement Gallery")
                        .font(LuxuryTheme.Typography.title1)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text("Coming Soon")
                        .font(LuxuryTheme.Typography.body)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                }
            }
        }
    }
}

#Preview {
    LuxuryProfileView()
        .environmentObject(AuthenticationManager())
}
