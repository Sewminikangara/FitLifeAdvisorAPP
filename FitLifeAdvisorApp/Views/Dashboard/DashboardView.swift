//
//  DashboardView.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var mealAnalysisManager = MealAnalysisManager.shared
    @State private var showingProfileSettings = false
    @State private var currentDate = Date()
    @State private var refreshing = false
    
    // Sample data - would come from ViewModels in real app
    @State private var dailyStats = DashboardStats(
        calories: DashboardStat(current: 1847, target: 2200, unit: "kcal"),
        steps: DashboardStat(current: 8432, target: 10000, unit: ""),
        protein: DashboardStat(current: 78, target: 120, unit: "g"),
        water: DashboardStat(current: 6, target: 8, unit: "glasses")
    )
    
    var body: some View {
        // Use the modern dashboard with enhanced UI
        ModernDashboardView()
            .environmentObject(authManager)
    }
    
    private var headerSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            // Top header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingMessage())
                        .font(Constants.Typography.body)
                        .foregroundColor(Constants.Colors.textLight)
                    
                    Text(authManager.currentUser?.name ?? "User")
                        .font(Constants.Typography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.textDark)
                }
                
                Spacer()
                
                // Profile Image Button with notification badge
                ZStack(alignment: .topTrailing) {
                    Button(action: {
                        showingProfileSettings = true
                    }) {
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
                            .frame(width: 55, height: 55)
                            .overlay(
                                Text(String(authManager.currentUser?.name.prefix(1) ?? "U"))
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Constants.Colors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    // Notification badge
                    Circle()
                        .fill(Constants.Colors.errorRed)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Text("3")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 4, y: -4)
                }
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            // Date and weather info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(DateFormatter.dayMonthFormatter.string(from: currentDate))
                        .font(Constants.Typography.body)
                        .foregroundColor(Constants.Colors.textDark)
                        .fontWeight(.medium)
                    
                    Text("Partly Cloudy • 22°C")
                        .font(Constants.Typography.caption)
                        .foregroundColor(Constants.Colors.textLight)
                }
                
                Spacer()
                
                // Streak counter
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(Constants.Colors.warningOrange)
                        .font(.caption)
                    
                    Text("7 day streak")
                        .font(Constants.Typography.caption)
                        .foregroundColor(Constants.Colors.textDark)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Constants.Colors.warningOrange.opacity(0.1))
                .cornerRadius(16)
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    private var dailyStatsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Constants.Spacing.medium) {
            EnhancedStatCard(
                title: "Calories",
                value: "\(Int(dailyStats.calories.current))",
                target: "\(Int(dailyStats.calories.target))",
                icon: "flame.fill",
                color: Constants.Colors.warningOrange,
                progress: dailyStats.calories.progress,
                trend: .up("84%")
            )
            
            EnhancedStatCard(
                title: "Steps",
                value: "\(Int(dailyStats.steps.current))",
                target: "\(Int(dailyStats.steps.target))",
                icon: "figure.walk",
                color: Constants.Colors.successGreen,
                progress: dailyStats.steps.progress,
                trend: .up("84%")
            )
            
            EnhancedStatCard(
                title: "Protein",
                value: "\(Int(dailyStats.protein.current))g",
                target: "\(Int(dailyStats.protein.target))g",
                icon: "bolt.fill",
                color: Constants.Colors.primaryBlue,
                progress: dailyStats.protein.progress,
                trend: .down("65%")
            )
            
            EnhancedStatCard(
                title: "Water",
                value: "\(Int(dailyStats.water.current))",
                target: "\(Int(dailyStats.water.target))",
                icon: "drop.fill",
                color: Constants.Colors.primaryBlue,
                progress: dailyStats.water.progress,
                trend: .neutral("75%")
            )
        }
        .padding(.horizontal, Constants.Spacing.large)
    }
    
    private var smartMealSummarySection: some View {
        let todaysNutrition = mealAnalysisManager.getTotalNutritionForToday()
        let todaysMeals = mealAnalysisManager.getMealsForToday()
        
        return VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                HStack(spacing: Constants.Spacing.small) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(Constants.Colors.successGreen)
                        .font(.title3)
                    
                    Text("Smart Meal Analysis")
                        .font(Constants.Typography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.textDark)
                }
                
                Spacer()
                
                Text("\(todaysMeals.count) meals")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.medium) {
                    ForEach(todaysMeals.prefix(4)) { meal in
                        SmartMealCard(meal: meal)
                    }
                    
                    if todaysMeals.count > 4 {
                        Button(action: {
                            // Navigate to full meal history
                        }) {
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(Constants.Colors.primaryBlue.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundColor(Constants.Colors.primaryBlue)
                                }
                                
                                Text("View All")
                                    .font(Constants.Typography.caption)
                                    .foregroundColor(Constants.Colors.primaryBlue)
                                    .fontWeight(.medium)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 80)
                    }
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
    
    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Today's Nutrition")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Button("View Details") {
                    // TODO: Navigate to detailed nutrition view
                }
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: Constants.Spacing.medium) {
                NutritionProgressCard(
                    title: "Carbs",
                    current: 198,
                    target: 275,
                    unit: "g",
                    color: Constants.Colors.warningOrange,
                    icon: "leaf.fill"
                )
                
                NutritionProgressCard(
                    title: "Fat",
                    current: 65,
                    target: 73,
                    unit: "g",
                    color: Constants.Colors.errorRed,
                    icon: "circle.fill"
                )
                
                NutritionProgressCard(
                    title: "Fiber",
                    current: 18,
                    target: 25,
                    unit: "g",
                    color: Constants.Colors.successGreen,
                    icon: "leaf.arrow.circlepath"
                )
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Quick Actions")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                Spacer()
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.medium) {
                    EnhancedQuickActionButton(
                        title: "Log Meal",
                        subtitle: "Camera",
                        icon: "camera.fill",
                        color: Constants.Colors.successGreen,
                        action: {}
                    )
                    
                    EnhancedQuickActionButton(
                        title: "Start Workout",
                        subtitle: "Track",
                        icon: "figure.run",
                        color: Constants.Colors.primaryBlue,
                        action: {}
                    )
                    
                    EnhancedQuickActionButton(
                        title: "Log Weight",
                        subtitle: "Scale",
                        icon: "scalemass.fill",
                        color: Constants.Colors.warningOrange,
                        action: {}
                    )
                    
                    EnhancedQuickActionButton(
                        title: "View Progress",
                        subtitle: "Charts",
                        icon: "chart.line.uptrend.xyaxis",
                        color: Constants.Colors.primaryBlue,
                        action: {}
                    )
                    
                    EnhancedQuickActionButton(
                        title: "Find Recipe",
                        subtitle: "Browse",
                        icon: "book.fill",
                        color: Constants.Colors.successGreen,
                        action: {}
                    )
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Recent Activity")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Button("View All") {
                    // TODO: Navigate to activity view
                }
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            VStack(spacing: Constants.Spacing.small) {
                ActivityCard(
                    title: "Greek Yogurt Bowl",
                    subtitle: "Breakfast • High Protein",
                    time: "8:30 AM",
                    icon: "fork.knife",
                    color: Constants.Colors.successGreen,
                    calories: "320 kcal"
                )
                
                ActivityCard(
                    title: "Morning Run",
                    subtitle: "Cardio • 5.2 km",
                    time: "7:00 AM",
                    icon: "figure.run",
                    color: Constants.Colors.primaryBlue,
                    calories: "285 kcal"
                )
                
                ActivityCard(
                    title: "Weight Check-in",
                    subtitle: "Progress • -0.3 kg",
                    time: "6:45 AM",
                    icon: "scalemass",
                    color: Constants.Colors.warningOrange,
                    calories: nil
                )
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    private var weeklySummarySection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("This Week")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Text("5 days active")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            VStack(spacing: Constants.Spacing.small) {
                WeeklySummaryRow(
                    title: "Average Calories",
                    value: "2,045",
                    target: "2,200",
                    progress: 0.93,
                    color: Constants.Colors.warningOrange
                )
                
                WeeklySummaryRow(
                    title: "Total Workouts",
                    value: "4",
                    target: "5",
                    progress: 0.8,
                    color: Constants.Colors.primaryBlue
                )
                
                WeeklySummaryRow(
                    title: "Weight Change",
                    value: "-0.8 kg",
                    target: "-1.0 kg",
                    progress: 0.8,
                    color: Constants.Colors.successGreen
                )
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    private func greetingMessage() -> String {
        let hour = Calendar.current.component(.hour, from: currentDate)
        switch hour {
        case 0..<12:
            return "Good morning,"
        case 12..<17:
            return "Good afternoon,"
        default:
            return "Good evening,"
        }
    }
    
    private func refreshDashboard() async {
        refreshing = true
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Check for goal achievements and trigger notifications
        checkGoalAchievements()
        
        refreshing = false
    }
    
    private func checkGoalAchievements() {
        // Check if any goals are achieved and trigger notifications
        if dailyStats.calories.progress >= 1.0 {
            notificationManager.scheduleGoalAchievementNotification(
                goalType: "daily calories",
                progress: dailyStats.calories.progress
            )
        }
        
        if dailyStats.steps.progress >= 1.0 {
            notificationManager.scheduleGoalAchievementNotification(
                goalType: "daily steps", 
                progress: dailyStats.steps.progress
            )
        }
        
        if dailyStats.protein.progress >= 1.0 {
            notificationManager.scheduleGoalAchievementNotification(
                goalType: "protein intake",
                progress: dailyStats.protein.progress
            )
        }
        
        if dailyStats.water.progress >= 1.0 {
            notificationManager.scheduleGoalAchievementNotification(
                goalType: "water intake",
                progress: dailyStats.water.progress  
            )
        }
        
        // Check for milestone achievements
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        // Evening check for low activity
        if currentHour == 18 && dailyStats.steps.progress < 0.5 {
            notificationManager.scheduleMotivationalNotification(
                title: "🚶‍♀️ Evening Walk Time!",
                body: "You've walked \(Int(dailyStats.steps.current)) steps today. How about a refreshing evening walk to reach your goal?",
                delay: 300 // 5 minutes
            )
        }
        
        // Mid-day hydration reminder
        if currentHour == 14 && dailyStats.water.progress < 0.6 {
            notificationManager.scheduleMotivationalNotification(
                title: "💧 Hydration Check",
                body: "You've had \(Int(dailyStats.water.current)) glasses of water. Stay hydrated for better energy!",
                delay: 600 // 10 minutes
            )
        }
        
        // Streak celebrations
        let streakDays = 7 // This would come from actual data
        if streakDays > 0 && streakDays % 7 == 0 {
            notificationManager.scheduleStreakCelebrationNotification(streakDays: streakDays)
        }
    }
    
    private func updateStatsWithMealData() {
        let todaysNutrition = mealAnalysisManager.getTotalNutritionForToday()
        
        // Update calories stat with real meal data
        dailyStats.calories = DashboardStat(
            current: todaysNutrition.calories,
            target: dailyStats.calories.target,
            unit: dailyStats.calories.unit
        )
        
        // Update protein stat with real meal data  
        dailyStats.protein = DashboardStat(
            current: todaysNutrition.protein,
            target: dailyStats.protein.target,
            unit: dailyStats.protein.unit
        )
    }
}
struct DashboardStats {
    var calories: DashboardStat
    var steps: DashboardStat
    var protein: DashboardStat
    var water: DashboardStat
}

struct DashboardStat {
    let current: Double
    let target: Double
    let unit: String
    
    var progress: Double {
        target > 0 ? min(current / target, 1.0) : 0.0
    }
}

struct EnhancedQuickActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Constants.Spacing.small) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.2), color.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 55, height: 55)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textDark)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(Constants.Typography.small)
                    .foregroundColor(Constants.Colors.textLight)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 85)
    }
}

struct WeeklySummaryRow: View {
    let title: String
    let value: String
    let target: String
    let progress: Double
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Constants.Typography.body)
                    .foregroundColor(Constants.Colors.textDark)
                
                Text("\(value) / \(target)")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Spacer()
            
            // Mini progress ring
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 4)
                    .frame(width: 30, height: 30)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 30, height: 30)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(color)
            }
        }
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Smart Meal Card Component
struct SmartMealCard: View {
    let meal: SavedMeal
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            // Meal image or placeholder
            if let imageData = meal.image, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 60)
                    .cornerRadius(8)
                    .clipped()
                    .overlay(
                        // AI badge
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "brain.head.profile")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Constants.Colors.successGreen)
                                    .clipShape(Circle())
                                Spacer()
                            }
                        }
                        .padding(4)
                    )
            } else {
                Rectangle()
                    .fill(meal.mealType.color.opacity(0.2))
                    .frame(width: 80, height: 60)
                    .cornerRadius(8)
                    .overlay(
                        VStack {
                            Image(systemName: meal.mealType.icon)
                                .foregroundColor(meal.mealType.color)
                                .font(.title3)
                            Image(systemName: "brain.head.profile")
                                .font(.caption2)
                                .foregroundColor(Constants.Colors.successGreen)
                        }
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.name)
                    .font(Constants.Typography.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textDark)
                    .lineLimit(1)
                
                Text("\(Int(meal.totalNutrition.calories)) cal")
                    .font(Constants.Typography.small)
                    .foregroundColor(Constants.Colors.warningOrange)
                    .fontWeight(.semibold)
                
                Text(meal.mealType.rawValue)
                    .font(Constants.Typography.small)
                    .foregroundColor(meal.mealType.color)
                
                // AI confidence indicator
                HStack(spacing: 2) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 8))
                        .foregroundColor(Constants.Colors.successGreen)
                    
                    Text("AI Analyzed")
                        .font(.system(size: 8))
                        .foregroundColor(Constants.Colors.successGreen)
                        .fontWeight(.medium)
                }
            }
        }
        .frame(width: 80)
        .padding(Constants.Spacing.small)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
