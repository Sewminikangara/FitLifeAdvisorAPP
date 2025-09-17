//
//  LuxuryLogView.swift
//  FitLifeAdvisorApp
//
//  Luxury Logging View with premium design
//

import SwiftUI
import HealthKit
import UIKit

struct LuxuryLogView: View {
    @State private var showingSmartCamera = false
    @State private var showingWorkoutLogger = false
    @State private var showingWeightLogger = false
    @State private var showingWaterLogger = false
    @State private var showingMoodLogger = false
    @State private var showingHealthyPlaces = false
    @State private var showingWorkoutQuickStart = false
    @State private var quickStartType: HKWorkoutActivityType = .running
    @State private var animateCards = false
    @StateObject private var mealAnalysisManager = MealAnalysisManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Luxury Background
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Premium Header
                        luxuryHeaderSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.medium)
                        
                        // AI-Powered Smart Logging
                        aiSmartLoggingSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Premium Quick Actions
                        premiumQuickActionsSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Today's Luxury Summary
                        if !mealAnalysisManager.getMealsForToday().isEmpty {
                            luxuryTodaysSummarySection
                                .padding(.horizontal, LuxuryTheme.Spacing.medium)
                                .padding(.top, LuxuryTheme.Spacing.xLarge)
                        }
                        
                        // Smart Insights
                        smartInsightsSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Recent Activities
                        if !mealAnalysisManager.getMealsForToday().isEmpty {
                            luxuryRecentActivitiesSection
                                .padding(.horizontal, LuxuryTheme.Spacing.medium)
                                .padding(.top, LuxuryTheme.Spacing.xLarge)
                        }
                        
                        // Bottom spacing (reduced to fit smaller screens)
                        Color.clear.frame(height: 60)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            startAnimations()
        }
        .fullScreenCover(isPresented: $showingSmartCamera) {
            MealCameraView()
        }
        .sheet(isPresented: $showingWorkoutLogger) {
            LuxuryWorkoutLoggerView()
        }
        .fullScreenCover(isPresented: $showingWorkoutQuickStart) {
            ProductionWorkoutView(initialWorkoutType: quickStartType, autoStart: true)
        }
        .sheet(isPresented: $showingWeightLogger) {
            LuxuryWeightLoggerView()
        }
        .sheet(isPresented: $showingWaterLogger) {
            LuxuryWaterLoggerView()
        }
        .sheet(isPresented: $showingMoodLogger) {
            LuxuryMoodLoggerView()
        }
        .fullScreenCover(isPresented: $showingHealthyPlaces) {
            HealthyStoreMapView()
        }
    }
    
    // MARK: - Luxury Header
    private var luxuryHeaderSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(" Logging")
                        .font(LuxuryTheme.Typography.title1)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text("AI-powered health tracking")
                        .font(LuxuryTheme.Typography.callout)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                }
                
                Spacer()
                
                // Notification Bell
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(LuxuryTheme.Gradients.goldGradient)
                            .frame(width: 50, height: 50)
                            .shadow(color: LuxuryTheme.Colors.goldPrimary.opacity(0.3), radius: 10, x: 0, y: 4)
                        
                        Image(systemName: "bell.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Notification badge
                        Circle()
                            .fill(LuxuryTheme.Colors.nutritionRed)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Text("3")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 18, y: -18)
                    }
                    .scaleEffect(animateCards ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateCards)
                }
            }
        }
    }
    
    // MARK: - AI Smart Logging Section
    private var aiSmartLoggingSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(LuxuryTheme.Colors.aiBlue)
                
                Text("AI-Powered Logging")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
            }
            
            // Main Smart Camera Action
            Button(action: { showingSmartCamera = true }) {
                VStack(spacing: LuxuryTheme.Spacing.medium) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.macro")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                Text("Snap & Analyze")
                                    .font(LuxuryTheme.Typography.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Text("AI-powered meal analysis with instant nutrition facts")
                                .font(LuxuryTheme.Typography.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Feature highlights
                    HStack(spacing: LuxuryTheme.Spacing.medium) {
                        LuxuryFeatureTag(text: "Instant Recognition", icon: "eye.fill")
                        LuxuryFeatureTag(text: "Nutrition Facts", icon: "chart.bar.fill")
                        LuxuryFeatureTag(text: "Calorie Count", icon: "flame.fill")
                    }
                }
                .padding(LuxuryTheme.Spacing.medium)
                .background(
                    RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.xLarge)
                        .fill(LuxuryTheme.Gradients.nutritionGradient)
                        .shadow(color: LuxuryTheme.Colors.nutritionRed.opacity(0.3), radius: 15, x: 0, y: 8)
                )
            }
            .buttonStyle(PressButtonStyle())
            .scaleEffect(animateCards ? 1.0 : 0.95)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateCards)
        }
    }
    
    // MARK: - Premium Quick Actions
    private var premiumQuickActionsSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("Quick Actions")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: LuxuryTheme.Spacing.small), count: 2), spacing: LuxuryTheme.Spacing.small) {
                // Run quick start
                LuxuryQuickActionCard(
                    title: "Run",
                    subtitle: "Start now",
                    icon: "figure.run",
                    colors: [LuxuryTheme.Colors.workoutPurple, LuxuryTheme.Colors.workoutViolet],
                    action: {
                        quickStartType = .running
                        showingWorkoutQuickStart = true
                    }
                )

                // Walk quick start
                LuxuryQuickActionCard(
                    title: "Walk",
                    subtitle: "Start now",
                    icon: "figure.walk",
                    colors: [LuxuryTheme.Colors.scanTeal, LuxuryTheme.Colors.scanGreen],
                    action: {
                        quickStartType = .walking
                        showingWorkoutQuickStart = true
                    }
                )

                // Cycle quick start
                LuxuryQuickActionCard(
                    title: "Cycle",
                    subtitle: "Start now",
                    icon: "bicycle",
                    colors: [Color(hex: "03A9F4"), Color(hex: "0288D1")],
                    action: {
                        quickStartType = .cycling
                        showingWorkoutQuickStart = true
                    }
                )

                LuxuryQuickActionCard(
                    title: "Workout",
                    subtitle: "Log Exercise",
                    icon: "figure.strengthtraining.traditional",
                    colors: [LuxuryTheme.Colors.workoutPurple, LuxuryTheme.Colors.workoutViolet],
                    action: { showingWorkoutLogger = true }
                )
                
                LuxuryQuickActionCard(
                    title: "Weight",
                    subtitle: "Track Progress",
                    icon: "scalemass.fill",
                    colors: [LuxuryTheme.Colors.nutritionOrange, Color(hex: "FF9800")],
                    action: { showingWeightLogger = true }
                )
                
                LuxuryQuickActionCard(
                    title: "Hydration",
                    subtitle: "Log Water",
                    icon: "drop.fill",
                    colors: [LuxuryTheme.Colors.aiBlue, LuxuryTheme.Colors.aiBlueSecondary],
                    action: { showingWaterLogger = true }
                )
                
                LuxuryQuickActionCard(
                    title: "Mood",
                    subtitle: "Track Wellness",
                    icon: "brain.head.profile",
                    colors: [Color(hex: "9C27B0"), Color(hex: "673AB7")],
                    action: { showingMoodLogger = true }
                )
                
                LuxuryQuickActionCard(
                    title: "Find Places",
                    subtitle: "Healthy Stores",
                    icon: "map.fill",
                    colors: [LuxuryTheme.Colors.scanTeal, LuxuryTheme.Colors.scanGreen],
                    action: { showingHealthyPlaces = true }
                )
                
                LuxuryQuickActionCard(
                    title: "More",
                    subtitle: "All Features",
                    icon: "ellipsis.circle.fill",
                    colors: [LuxuryTheme.Colors.goldPrimary, LuxuryTheme.Colors.goldSecondary],
                    action: { 
                        // Navigate to All Screens hub
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let root = window.rootViewController {
                            let hosting = UIHostingController(rootView: AllScreensView())
                            root.present(hosting, animated: true, completion: nil)
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Today's Summary
    private var luxuryTodaysSummarySection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("Today's Summary")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
                
                Text(formatDate(Date()))
                    .font(LuxuryTheme.Typography.caption)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LuxuryTheme.Colors.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(LuxuryTheme.Colors.cardBorder, lineWidth: 1)
                            )
                    )
            }
            
            let todaysNutrition = mealAnalysisManager.getTotalNutritionForToday()
            
            VStack(spacing: LuxuryTheme.Spacing.small) {
                // Macro Summary Cards
                HStack(spacing: LuxuryTheme.Spacing.small) {
                    LuxuryMacroCard(
                        title: "Calories",
                        value: "\(Int(todaysNutrition.calories))",
                        unit: "kcal",
                        target: 2200,
                        current: todaysNutrition.calories,
                        color: LuxuryTheme.Colors.nutritionRed
                    )
                    
                    LuxuryMacroCard(
                        title: "Protein",
                        value: "\(Int(todaysNutrition.protein))",
                        unit: "g",
                        target: 150,
                        current: todaysNutrition.protein,
                        color: LuxuryTheme.Colors.workoutPurple
                    )
                }
                
                HStack(spacing: LuxuryTheme.Spacing.small) {
                    LuxuryMacroCard(
                        title: "Carbs",
                        value: "\(Int(todaysNutrition.carbs))",
                        unit: "g",
                        target: 250,
                        current: todaysNutrition.carbs,
                        color: LuxuryTheme.Colors.scanTeal
                    )
                    
                    LuxuryMacroCard(
                        title: "Fat",
                        value: "\(Int(todaysNutrition.fat))",
                        unit: "g",
                        target: 80,
                        current: todaysNutrition.fat,
                        color: LuxuryTheme.Colors.goldPrimary
                    )
                }
            }
        }
    }
    
    // MARK: - Smart Insights
    private var smartInsightsSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                
                Text("Smart Insights")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
            }
            
            VStack(spacing: LuxuryTheme.Spacing.small) {
                LuxuryInsightCard(
                    icon: "target",
                    title: "On Track!",
                    description: "You're 85% towards your daily calorie goal. Perfect progress!",
                    colors: [LuxuryTheme.Colors.scanTeal, LuxuryTheme.Colors.scanGreen]
                )
                
                LuxuryInsightCard(
                    icon: "drop.fill",
                    title: "Hydration Reminder",
                    description: "You've had 5 glasses of water. Try to reach 8 glasses today.",
                    colors: [LuxuryTheme.Colors.aiBlue, LuxuryTheme.Colors.aiBlueSecondary]
                )
                
                LuxuryInsightCard(
                    icon: "brain.head.profile",
                    title: "AI Suggestion",
                    description: "Consider adding a protein-rich snack for optimal muscle recovery.",
                    colors: [LuxuryTheme.Colors.workoutPurple, LuxuryTheme.Colors.workoutViolet]
                )
            }
        }
    }
    
    // MARK: - Recent Activities
    private var luxuryRecentActivitiesSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("Recent Activities")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
                
                Button("View All") {
                    // TODO: Navigate to full activity log
                }
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.goldPrimary)
            }
            
            VStack(spacing: LuxuryTheme.Spacing.xxSmall) {
                ForEach(mealAnalysisManager.getMealsForToday().prefix(3), id: \.id) { meal in
                    LuxuryActivityRow(
                        title: meal.name,
                        subtitle: "\(Int(meal.totalNutrition.calories)) kcal",
                        time: formatTime(meal.timestamp),
                        icon: "fork.knife",
                        color: LuxuryTheme.Colors.nutritionRed
                    )
                }
                
                // Mock recent activities
                LuxuryActivityRow(
                    title: "Morning Run",
                    subtitle: "30 min • 320 kcal burned",
                    time: "8:30 AM",
                    icon: "figure.run",
                    color: LuxuryTheme.Colors.workoutPurple
                )
                
                LuxuryActivityRow(
                    title: "Water Intake",
                    subtitle: "500ml",
                    time: "10:15 AM",
                    icon: "drop.fill",
                    color: LuxuryTheme.Colors.aiBlue
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
            animateCards = true
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Luxury Components

struct LuxuryFeatureTag: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
            
            Text(text)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.white.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct LuxuryQuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: LuxuryTheme.Spacing.small) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                        .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 10, x: 0, y: 4)
                    
  Image(systemName: icon)                                 
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(LuxuryTheme.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text(subtitle)
                        .font(LuxuryTheme.Typography.caption)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .padding(LuxuryTheme.Spacing.small)
            .luxuryCard()
        }
        .buttonStyle(PressButtonStyle())
    }
}

struct LuxuryMacroCard: View {
    let title: String
    let value: String
    let unit: String
    let target: Double
    let current: Double
    let color: Color
    
    private var progress: Double {
        target > 0 ? min(current / target, 1.0) : 0.0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: LuxuryTheme.Spacing.xxSmall) {
            HStack {
                Text(title)
                    .font(LuxuryTheme.Typography.caption)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(LuxuryTheme.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(color) +
            Text(" " + unit)
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.tertiaryText)
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(LuxuryTheme.Colors.cardBorder)
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .animation(.easeInOut(duration: 1.0), value: progress)
                }
            }
            .frame(height: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(LuxuryTheme.Spacing.small)
        .luxuryCard()
    }
}

struct LuxuryActivityRow: View {
    let title: String
    let subtitle: String
    let time: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: LuxuryTheme.Spacing.small) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LuxuryTheme.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Text(subtitle)
                    .font(LuxuryTheme.Typography.caption)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
            }
            
            Spacer()
            
            Text(time)
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.tertiaryText)
        }
        .padding(LuxuryTheme.Spacing.small)
        .luxuryCard()
    }
}

// MARK: - Placeholder Logger Views

struct LuxuryWorkoutLoggerView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: LuxuryTheme.Spacing.xLarge) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 80))
                        .foregroundColor(LuxuryTheme.Colors.workoutPurple)
                    
                    Text("Workout Logger")
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

struct LuxuryWeightLoggerView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: LuxuryTheme.Spacing.xLarge) {
                    Image(systemName: "scalemass.fill")
                        .font(.system(size: 80))
                        .foregroundColor(LuxuryTheme.Colors.nutritionOrange)
                    
                    Text("Weight Logger")
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

struct LuxuryWaterLoggerView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: LuxuryTheme.Spacing.xLarge) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 80))
                        .foregroundColor(LuxuryTheme.Colors.aiBlue)
                    
                    Text("Hydration Logger")
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

struct LuxuryMoodLoggerView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: LuxuryTheme.Spacing.xLarge) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundColor(Color(hex: "9C27B0"))
                    
                    Text("Mood Logger")
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
    LuxuryLogView()
}
