//
//  ModernDashboardView.swift
//  FitLifeAdvisorApp
//
//  Modern Dashboard with beautiful UI and enhanced user experience
//

import SwiftUI

struct ModernDashboardView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var mlKitManager = MLKitManager()
    @StateObject private var foodRecognitionService = FoodRecognitionService()
    @State private var selectedTimeframe: TimeFrame = .today
    @State private var showingMealAnalysis = false
    @State private var showingWorkoutLog = false
    @State private var showingHealthyPlaces = false
    @State private var showingQuickFoodScanner = false
    @State private var showingFoodResult = false
    @State private var scannedFoodProduct: FoodProduct?
    @State private var animateStats = false
    
    enum TimeFrame: String, CaseIterable {
        case today = "Today"
        case week = "Week"
        case month = "Month"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: Constants.Spacing.large) {
                    // Modern Header with Greeting
                    modernHeader
                    
                    // Time Frame Selector
                    timeFrameSelector
                    
                    // Quick Stats Overview
                    quickStatsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Find Healthy Places
                    findHealthyPlacesSection
                    
                    // Today's Progress Ring
                    dailyProgressSection
                    
                    // Recent Activity Feed
                    recentActivitySection
                    
                    // Smart Insights
                    smartInsightsSection
                    
                    // Quick Meal Analysis
                    quickMealSection
                }
                .padding(.horizontal, Constants.Spacing.large)
                .padding(.bottom, 100) // Tab bar spacing
            }
            .background(Constants.Colors.backgroundGray)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingMealAnalysis) {
            MealPhotoAnalysisView()
        }
        .sheet(isPresented: $showingQuickFoodScanner) {
            FoodScannerView()
        }
        .sheet(isPresented: $showingFoodResult) {
            if let product = scannedFoodProduct {
                FoodProductResultView(
                    product: product,
                    onAddToLog: { foodProduct in
                        // Add to meal log here
                        showingFoodResult = false
                        scannedFoodProduct = nil
                    },
                    onDismiss: {
                        showingFoodResult = false
                        scannedFoodProduct = nil
                    }
                )
            }
        }
        .sheet(isPresented: $showingWorkoutLog) {
            WorkoutLogView()
        }
        .sheet(isPresented: $showingHealthyPlaces) {
            HealthyStoreMapView()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                animateStats = true
            }
        }
    }
    
    // MARK: - Modern Header
    private var modernHeader: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                    
                    Text(authManager.currentUser?.name ?? "Fitness Enthusiast")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Constants.Colors.textDark)
                }
                
                Spacer()
                
                // Profile Avatar with Notification Badge
                Button(action: {}) {
                    ZStack {
                        AsyncImage(url: nil) { _ in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Constants.Colors.primaryBlue, Constants.Colors.primaryBlue.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(authManager.currentUser?.name.prefix(1) ?? "U"))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        } placeholder: {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Constants.Colors.primaryBlue, Constants.Colors.primaryBlue.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(authManager.currentUser?.name.prefix(1) ?? "U"))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        
                        // Notification Badge
                        Circle()
                            .fill(Constants.Colors.successGreen)
                            .frame(width: 12, height: 12)
                            .offset(x: 18, y: -18)
                    }
                    .shadow(color: Constants.Colors.primaryBlue.opacity(0.3), radius: 12, x: 0, y: 6)
                }
            }
            
            // Motivational Quote
            Text("💪 \"Success is the sum of small efforts repeated day in and day out.\"")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Constants.Colors.textLight)
                .padding(.top, Constants.Spacing.small)
        }
        .padding(.top, Constants.Spacing.medium)
    }
    
    // MARK: - Time Frame Selector
    private var timeFrameSelector: some View {
        HStack(spacing: 0) {
            ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        selectedTimeframe = timeframe
                    }
                }) {
                    Text(timeframe.rawValue)
                        .font(.system(size: 16, weight: selectedTimeframe == timeframe ? .bold : .medium))
                        .foregroundColor(selectedTimeframe == timeframe ? .white : Constants.Colors.textDark)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            selectedTimeframe == timeframe ?
                            LinearGradient(
                                colors: [Constants.Colors.primaryBlue, Constants.Colors.primaryBlue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(colors: [.clear, .clear], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                        .scaleEffect(selectedTimeframe == timeframe ? 1.02 : 1.0)
                }
            }
        }
        .padding(4)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            HStack(spacing: Constants.Spacing.medium) {
                ModernStatsCard(
                    title: "Calories",
                    value: animateStats ? "1,847" : "0",
                    target: "2,200",
                    progress: animateStats ? 0.84 : 0.0,
                    icon: "flame.fill",
                    color: .orange
                )
                
                ModernStatsCard(
                    title: "Steps",
                    value: animateStats ? "8,542" : "0",
                    target: "10,000",
                    progress: animateStats ? 0.85 : 0.0,
                    icon: "figure.walk",
                    color: .green
                )
            }
            
            HStack(spacing: Constants.Spacing.medium) {
                ModernStatsCard(
                    title: "Water",
                    value: animateStats ? "6" : "0",
                    target: "8 glasses",
                    progress: animateStats ? 0.75 : 0.0,
                    icon: "drop.fill",
                    color: .blue
                )
                
                ModernStatsCard(
                    title: "Active",
                    value: animateStats ? "45m" : "0m",
                    target: "60m",
                    progress: animateStats ? 0.75 : 0.0,
                    icon: "timer",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Quick Actions")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
            
            HStack(spacing: Constants.Spacing.medium) {
                ModernQuickActionButton(
                    icon: "camera.fill",
                    title: "Snap Meal",
                    subtitle: "AI Analysis",
                    colors: [.blue, .blue.opacity(0.7)]
                ) {
                    showingMealAnalysis = true
                }
                
                ModernQuickActionButton(
                    icon: "barcode.viewfinder",
                    title: "Quick Scan",
                    subtitle: "Barcode/Label",
                    colors: [.purple, .purple.opacity(0.7)]
                ) {
                    showingQuickFoodScanner = true
                }
            }
            
            HStack(spacing: Constants.Spacing.medium) {
                ModernQuickActionButton(
                    icon: "figure.run",
                    title: "Log Workout",
                    subtitle: "Track Exercise",
                    colors: [.red, .orange]
                ) {
                    showingWorkoutLog = true
                }
                
                ModernQuickActionButton(
                    icon: "drop.fill",
                    title: "Water +1",
                    subtitle: "Stay Hydrated",
                    colors: [.cyan, .blue]
                ) {
                    // Add water logic
                }
                
                ModernQuickActionButton(
                    icon: "map.fill",
                    title: "Find Places",
                    subtitle: "Healthy Food & Gyms",
                    colors: [.green, .green.opacity(0.7)]
                ) {
                    showingHealthyPlaces = true
                }
            }
            
            HStack(spacing: Constants.Spacing.medium) {
                ModernQuickActionButton(
                    icon: "heart.fill",
                    title: "Health Data",
                    subtitle: "Sync Devices",
                    colors: [.pink, .purple]
                ) {
                    // Health sync logic
                }
                
                ModernQuickActionButton(
                    icon: "chart.bar.fill",
                    title: "Progress",
                    subtitle: "View Analytics",
                    colors: [.orange, .yellow]
                ) {
                    // Progress view logic
                }
            }
        }
    }
    
    // MARK: - Find Healthy Places Section
    private var findHealthyPlacesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Find Healthy Places")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
            
            VStack(spacing: Constants.Spacing.small) {
                // Healthy Food Stores Card
                Button(action: { showingHealthyPlaces = true }) {
                    HealthyPlaceCard(
                        icon: "leaf.fill",
                        title: "Healthy Food Stores",
                        subtitle: "Find organic markets, juice bars & healthy restaurants nearby",
                        gradient: LinearGradient(
                            colors: [Constants.Colors.successGreen, Constants.Colors.successGreen.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Gyms & Fitness Centers Card
                Button(action: { showingHealthyPlaces = true }) {
                    HealthyPlaceCard(
                        icon: "dumbbell.fill",
                        title: "Gyms & Fitness Centers",
                        subtitle: "Discover gyms, yoga studios & fitness centers around you",
                        gradient: LinearGradient(
                            colors: [Constants.Colors.primaryBlue, Constants.Colors.primaryBlue.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Daily Progress Section
    private var dailyProgressSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Today's Progress")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
            
            DailyProgressRing()
                .frame(height: 200)
        }
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Recent Activity")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Button("View All") {
                    // View all logic
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            
            VStack(spacing: Constants.Spacing.small) {
                ModernActivityItem(
                    icon: "fork.knife.circle.fill",
                    title: "Breakfast Logged",
                    subtitle: "Greek yogurt with berries • 320 cal",
                    time: "25 mins ago",
                    color: .orange
                )
                
                ModernActivityItem(
                    icon: "figure.run.circle.fill",
                    title: "Morning Run Completed",
                    subtitle: "3.2 km in 22 minutes • 280 cal burned",
                    time: "1 hour ago",
                    color: .red
                )
                
                ModernActivityItem(
                    icon: "drop.circle.fill",
                    title: "Water Goal Achievement",
                    subtitle: "Drank 2 glasses of water",
                    time: "2 hours ago",
                    color: .blue
                )
            }
        }
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Smart Insights Section
    private var smartInsightsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Smart Insights")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
            
            VStack(spacing: Constants.Spacing.small) {
                ModernInsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Great Progress! 📈",
                    subtitle: "You've burned 15% more calories this week compared to last week.",
                    color: .green
                )
                
                ModernInsightCard(
                    icon: "lightbulb.fill",
                    title: "Hydration Reminder 💧",
                    subtitle: "You're 2 glasses behind your daily water goal. Stay hydrated!",
                    color: .blue
                )
            }
        }
    }
    
    // MARK: - Quick Meal Section
    private var quickMealSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Quick Meal Log")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
            
            Button(action: { showingMealAnalysis = true }) {
                VStack(spacing: Constants.Spacing.large) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Constants.Colors.primaryBlue.opacity(0.2), Constants.Colors.primaryBlue.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(Constants.Colors.primaryBlue)
                            
                            Text("Snap & Analyze")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Constants.Colors.primaryBlue)
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text("AI-Powered Meal Analysis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Constants.Colors.textDark)
                        
                        Text("Take a photo of your meal and get instant nutritional insights")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Constants.Colors.textLight)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(Constants.Spacing.extraLarge)
            }
            .background(.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
        }
    }
    
    // MARK: - Helper Properties
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning! ☀️"
        case 12..<17: return "Good afternoon! 🌤️"
        case 17..<21: return "Good evening! 🌅"
        default: return "Good night! 🌙"
        }
    }
}

// MARK: - Modern Quick Action Button
struct ModernQuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let colors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Constants.Spacing.small) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.Spacing.large)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(ModernButtonStyle())
    }
}

// MARK: - Daily Progress Ring
struct DailyProgressRing: View {
    var body: some View {
        HStack(spacing: Constants.Spacing.extraLarge) {
            // Progress Rings
            ZStack {
                // Background rings
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            Color.gray.opacity(0.2),
                            lineWidth: 8
                        )
                        .frame(width: CGFloat(120 - index * 20), height: CGFloat(120 - index * 20))
                }
                
                // Progress rings
                Circle()
                    .trim(from: 0, to: 0.84) // Calories
                    .stroke(
                        LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.5).delay(0.2), value: true)
                
                Circle()
                    .trim(from: 0, to: 0.75) // Activity
                    .stroke(
                        LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.5).delay(0.4), value: true)
                
                Circle()
                    .trim(from: 0, to: 0.65) // Standing
                    .stroke(
                        LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.5).delay(0.6), value: true)
                
                // Center text
                VStack(spacing: 2) {
                    Text("84%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text("Daily Goal")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
            }
            
            // Legend
            VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                ProgressLegendItem(color: .orange, title: "Calories", value: "1,847 / 2,200")
                ProgressLegendItem(color: .green, title: "Active", value: "45 / 60 min")
                ProgressLegendItem(color: .blue, title: "Standing", value: "8 / 12 hours")
            }
        }
    }
}

// MARK: - Progress Legend Item
struct ProgressLegendItem: View {
    let color: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: Constants.Spacing.small) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(value)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
        }
    }
}

// MARK: - Modern Activity Item
struct ModernActivityItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(time)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Constants.Colors.textLight)
        }
        .padding(.vertical, Constants.Spacing.small)
    }
}

// MARK: - Modern Insight Card
struct ModernInsightCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Supporting Views for Sheets
struct WorkoutLogView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Workout Log")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            .navigationTitle("Log Workout")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Healthy Place Card Component
struct HealthyPlaceCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            // Icon
            ZStack {
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(Constants.Spacing.medium)
        .background(gradient)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ModernDashboardView()
        .environmentObject(AuthenticationManager())
}