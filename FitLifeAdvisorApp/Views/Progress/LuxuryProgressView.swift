//
//  LuxuryProgressView.swift
//  FitLifeAdvisorApp
//
//   Progress View with premium design


import SwiftUI

struct LuxuryProgressView: View {
    @State private var selectedTimeframe: Timeframe = .week
    @State private var selectedMetric: ProgressMetric = .weight
    @State private var showingDetailedView = false
    @State private var animateCharts = false
    @State private var animateStats = false
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var emoji: String {
            switch self {
            case .week: return "📊"
            case .month: return "📈"
            case .year: return "📅"
            }
        }
        
        var dateRange: String {
            switch self {
            case .week: return "This Week"
            case .month: return "This Month"
            case .year: return "This Year"
            }
        }
    }
    
    enum ProgressMetric: String, CaseIterable {
        case weight = "Weight"
        case calories = "Calories"
        case steps = "Steps"
        case workouts = "Workouts"
        case water = "Water"
        case sleep = "Sleep"
        
        var icon: String {
            switch self {
            case .weight: return "scalemass.fill"
            case .calories: return "flame.fill"
            case .steps: return "figure.walk"
            case .workouts: return "figure.run"
            case .water: return "drop.fill"
            case .sleep: return "bed.double.fill"
            }
        }
        
        var colors: [Color] {
            switch self {
            case .weight: return [LuxuryTheme.Colors.nutritionOrange, Color(hex: "FF9800")]
            case .calories: return [LuxuryTheme.Colors.nutritionRed, LuxuryTheme.Colors.nutritionOrange]
            case .steps: return [LuxuryTheme.Colors.scanTeal, LuxuryTheme.Colors.scanGreen]
            case .workouts: return [LuxuryTheme.Colors.workoutPurple, LuxuryTheme.Colors.workoutViolet]
            case .water: return [LuxuryTheme.Colors.aiBlue, LuxuryTheme.Colors.aiBlueSecondary]
            case .sleep: return [Color(hex: "9C27B0"), Color(hex: "673AB7")]
            }
        }
        
        var unit: String {
            switch self {
            case .weight: return "kg"
            case .calories: return "kcal"
            case .steps: return "steps"
            case .workouts: return "sessions"
            case .water: return "glasses"
            case .sleep: return "hours"
            }
        }
    }
    
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
                        
                        // AI Health Insights
                        aiInsightsSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Time Range & Metric Selector
                        selectorSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Advanced Chart Section
                        luxuryChartSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Premium Analytics Cards
                        premiumAnalyticsSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Achievement Gallery
                        achievementGallerySection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // AI Recommendations
                        aiRecommendationsSection
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
        .sheet(isPresented: $showingDetailedView) {
            LuxuryDetailedProgressView(metric: selectedMetric)
        }
    }
    
    // Header
    private var luxuryHeaderSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Progress Analytics")
                        .font(LuxuryTheme.Typography.title1)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text("AI-powered health insights")
                        .font(LuxuryTheme.Typography.callout)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                }
                
                Spacer()
                
                Button(action: { showingDetailedView = true }) {
                    ZStack {
                        Circle()
                            .fill(LuxuryTheme.Gradients.goldGradient)
                            .frame(width: 50, height: 50)
                            .shadow(color: LuxuryTheme.Colors.goldPrimary.opacity(0.3), radius: 10, x: 0, y: 4)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(animateStats ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateStats)
                }
            }
        }
    }
    
    // MARK: - AI Insights Section
    private var aiInsightsSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(LuxuryTheme.Colors.aiBlue)
                
                Text("AI Health Insights")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
            }
            
            VStack(spacing: LuxuryTheme.Spacing.small) {
                LuxuryInsightCard(
                    icon: "trophy.fill",
                    title: "Excellent Progress",
                    description: "Your fitness journey is 23% ahead of target this month",
                    colors: [LuxuryTheme.Colors.goldPrimary, LuxuryTheme.Colors.goldSecondary]
                )
                
                LuxuryInsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Consistency Streak",
                    description: "You've maintained a 15-day streak of reaching daily goals",
                    colors: [LuxuryTheme.Colors.scanTeal, LuxuryTheme.Colors.scanGreen]
                )
                
                LuxuryInsightCard(
                    icon: "lightbulb.fill",
                    title: "Smart Recommendation",
                    description: "Consider increasing water intake by 10% for optimal performance",
                    colors: [LuxuryTheme.Colors.aiBlue, LuxuryTheme.Colors.aiBlueSecondary]
                )
            }
        }
    }
    
    // Selector Section
    private var selectorSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            // Time Frame Selector
            luxuryTimeFrameSelector
            
            // Metric Selector
            luxuryMetricSelector
        }
    }
    
    private var luxuryTimeFrameSelector: some View {
        HStack(spacing: 0) {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTimeframe = timeframe
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(timeframe.emoji)
                            .font(.system(size: 16))
                        
                        Text(timeframe.rawValue)
                            .font(LuxuryTheme.Typography.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedTimeframe == timeframe ? .white : LuxuryTheme.Colors.tertiaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                selectedTimeframe == timeframe 
                                ? LuxuryTheme.Gradients.goldGradient
                                : LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedTimeframe == timeframe 
                                        ? Color.clear
                                        : LuxuryTheme.Colors.cardBorder,
                                        lineWidth: 1
                                    )
                            )
                    )
                }
            }
        }
        .padding(4)
        .luxuryCard()
    }
    
    private var luxuryMetricSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LuxuryTheme.Spacing.small) {
                ForEach(ProgressMetric.allCases, id: \.self) { metric in
                    LuxuryMetricButton(
                        metric: metric,
                        isSelected: selectedMetric == metric,
                        action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                selectedMetric = metric
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, LuxuryTheme.Spacing.medium)
        }
    }
    
    // MARK: - Luxury Chart Section
    private var luxuryChartSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(selectedMetric.rawValue) Analytics")
                        .font(LuxuryTheme.Typography.headline)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text("Advanced AI-powered insights")
                        .font(LuxuryTheme.Typography.caption)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                }
                
                Spacer()
                
                Button(action: { showingDetailedView = true }) {
                    HStack(spacing: 4) {
                        Text("Details")
                            .font(LuxuryTheme.Typography.caption)
                        Image(systemName: "arrow.up.right")
                            .font(.caption2)
                    }
                    .foregroundColor(selectedMetric.colors.first ?? LuxuryTheme.Colors.goldPrimary)
                }
            }
            
            // Premium Chart Container
            VStack(spacing: LuxuryTheme.Spacing.medium) {
                VStack(spacing: 12) {
                    // Current Value Display
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current")
                                .font(LuxuryTheme.Typography.caption)
                                .foregroundColor(LuxuryTheme.Colors.secondaryText)
                            
                            Text(getCurrentValue())
                                .font(LuxuryTheme.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(selectedMetric.colors.first ?? LuxuryTheme.Colors.goldPrimary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("vs Last \(selectedTimeframe.rawValue)")
                                .font(LuxuryTheme.Typography.caption)
                                .foregroundColor(LuxuryTheme.Colors.secondaryText)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(LuxuryTheme.Colors.scanGreen)
                                
                                Text("+5.2%")
                                    .font(LuxuryTheme.Typography.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(LuxuryTheme.Colors.scanGreen)
                            }
                        }
                    }
                    
                    // Luxury Chart Visualization
                    luxuryChartView
                }
                .padding(LuxuryTheme.Spacing.medium)
                .luxuryGlassCard()
            }
        }
    }
    
    private var luxuryChartView: some View {
        VStack(spacing: LuxuryTheme.Spacing.small) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: selectedMetric.colors,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 20, height: animateCharts ? CGFloat.random(in: 40...100) : 5)
                            .animation(.easeInOut(duration: 0.8).delay(Double(index) * 0.1), value: animateCharts)
                            .shadow(color: selectedMetric.colors.first?.opacity(0.3) ?? .clear, radius: 4, x: 0, y: 2)
                        
                        Text(getDayLabel(index))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(LuxuryTheme.Colors.tertiaryText)
                    }
                }
            }
            .frame(height: 120)
        }
    }
    
    // MARK: - Premium Analytics Section
    private var premiumAnalyticsSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("Performance Metrics")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: LuxuryTheme.Spacing.small), count: 2), spacing: LuxuryTheme.Spacing.small) {
                LuxuryAnalyticsCard(
                    title: "This \(selectedTimeframe.rawValue)",
                    value: getTrendValue(),
                    change: "+12%",
                    isPositive: true,
                    colors: selectedMetric.colors
                )
                
                LuxuryAnalyticsCard(
                    title: "Peak Performance",
                    value: getBestDay(),
                    change: "Tuesday",
                    isPositive: true,
                    colors: [LuxuryTheme.Colors.scanTeal, LuxuryTheme.Colors.scanGreen]
                )
                
                LuxuryAnalyticsCard(
                    title: "Consistency Score",
                    value: "94%",
                    change: "Excellent",
                    isPositive: true,
                    colors: [LuxuryTheme.Colors.goldPrimary, LuxuryTheme.Colors.goldSecondary]
                )
                
                LuxuryAnalyticsCard(
                    title: "Goal Achievement",
                    value: getGoalAchievement(),
                    change: "On Track",
                    isPositive: true,
                    colors: [LuxuryTheme.Colors.workoutPurple, LuxuryTheme.Colors.workoutViolet]
                )
            }
        }
    }
    
    // MARK: - Achievement Gallery
    private var achievementGallerySection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("Achievement Gallery")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
                
                Button("View All") {
                    // TODO: Navigate to achievements
                }
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.goldPrimary)
            }
            
            VStack(spacing: LuxuryTheme.Spacing.small) {
                LuxuryAchievementCard(
                    title: "Diamond Streak",
                    description: "Completed 30-day fitness challenge with perfect score!",
                    icon: "crown.fill",
                    colors: [LuxuryTheme.Colors.goldPrimary, LuxuryTheme.Colors.goldSecondary],
                    isNew: true
                )
                
                LuxuryAchievementCard(
                    title: "Step Champion",
                    description: "Reached 10,000 steps for 21 consecutive days",
                    icon: "figure.walk",
                    colors: [LuxuryTheme.Colors.scanTeal, LuxuryTheme.Colors.scanGreen],
                    isNew: false
                )
                
                LuxuryAchievementCard(
                    title: "Hydration Master",
                    description: "Maintained optimal hydration for 2 weeks straight",
                    icon: "drop.fill",
                    colors: [LuxuryTheme.Colors.aiBlue, LuxuryTheme.Colors.aiBlueSecondary],
                    isNew: false
                )
            }
        }
    }
    
    // MARK: - AI Recommendations
    private var aiRecommendationsSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(LuxuryTheme.Colors.aiBlue)
                
                Text("AI Recommendations")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
            }
            
            VStack(spacing: LuxuryTheme.Spacing.small) {
                LuxuryProgressRecommendationCard(
                    title: "Optimize Rest Days",
                    description: "Based on your workout intensity, consider adding one more rest day per week for better recovery.",
                    actionTitle: "Learn More",
                    colors: [LuxuryTheme.Colors.workoutPurple, LuxuryTheme.Colors.workoutViolet]
                )
                
                LuxuryProgressRecommendationCard(
                    title: "Nutrition Timing",
                    description: "Your meal timing could be optimized. Try eating your largest meal 4 hours before bedtime.",
                    actionTitle: "Set Reminder",
                    colors: [LuxuryTheme.Colors.nutritionRed, LuxuryTheme.Colors.nutritionOrange]
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
            animateStats = true
        }
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.5)) {
            animateCharts = true
        }
    }
    
    private func getCurrentValue() -> String {
        switch selectedMetric {
        case .weight: return "72.5 kg"
        case .calories: return "2,150"
        case .steps: return "8,947"
        case .workouts: return "5"
        case .water: return "7"
        case .sleep: return "7.5h"
        }
    }
    
    private func getTrendValue() -> String {
        switch selectedMetric {
        case .weight: return "71.2 kg"
        case .calories: return "2,180"
        case .steps: return "9,234"
        case .workouts: return "6"
        case .water: return "8"
        case .sleep: return "7.8h"
        }
    }
    
    private func getBestDay() -> String {
        switch selectedMetric {
        case .weight: return "Monday"
        case .calories: return "Wednesday"
        case .steps: return "Saturday"
        case .workouts: return "Tuesday"
        case .water: return "Thursday"
        case .sleep: return "Sunday"
        }
    }
    
    private func getGoalAchievement() -> String {
        switch selectedMetric {
        case .weight: return "95%"
        case .calories: return "87%"
        case .steps: return "78%"
        case .workouts: return "100%"
        case .water: return "82%"
        case .sleep: return "90%"
        }
    }
    
    private func getDayLabel(_ index: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        return days[index]
    }
}

// MARK: - Supporting Luxury Components

struct LuxuryInsightCard: View {
    let icon: String
    let title: String
    let description: String
    let colors: [Color]
    
    var body: some View {
        HStack(spacing: LuxuryTheme.Spacing.small) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LuxuryTheme.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Text(description)
                    .font(LuxuryTheme.Typography.caption)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(LuxuryTheme.Spacing.small)
        .luxuryCard()
    }
}

struct LuxuryMetricButton: View {
    let metric: LuxuryProgressView.ProgressMetric
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: LuxuryTheme.Spacing.xxSmall) {
                Image(systemName: metric.icon)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(metric.rawValue)
                    .font(LuxuryTheme.Typography.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, LuxuryTheme.Spacing.small)
            .padding(.vertical, LuxuryTheme.Spacing.xxSmall)
            .background(
                RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.small)
                    .fill(
                        isSelected ?
                        LinearGradient(colors: metric.colors, startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LuxuryTheme.Gradients.cardGradient
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.small)
                            .stroke(
                                isSelected ? Color.clear : LuxuryTheme.Colors.cardBorder,
                                lineWidth: 1
                            )
                    )
            )
            .foregroundColor(isSelected ? .white : LuxuryTheme.Colors.primaryText)
            .shadow(color: isSelected ? metric.colors.first?.opacity(0.3) ?? .clear : .clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LuxuryAnalyticsCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let colors: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: LuxuryTheme.Spacing.xxSmall) {
            Text(title)
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.secondaryText)
                .lineLimit(1)
            
            Text(value)
                .font(LuxuryTheme.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(colors.first ?? LuxuryTheme.Colors.goldPrimary)
            
            HStack(spacing: 4) {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption2)
                    .foregroundColor(isPositive ? LuxuryTheme.Colors.scanGreen : LuxuryTheme.Colors.nutritionRed)
                
                Text(change)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isPositive ? LuxuryTheme.Colors.scanGreen : LuxuryTheme.Colors.nutritionRed)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(LuxuryTheme.Spacing.small)
        .luxuryCard()
    }
}

struct LuxuryAchievementCard: View {
    let title: String
    let description: String
    let icon: String
    let colors: [Color]
    let isNew: Bool
    
    var body: some View {
        HStack(spacing: LuxuryTheme.Spacing.small) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 50, height: 50)
                    .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                if isNew {
                    Circle()
                        .fill(LuxuryTheme.Colors.nutritionRed)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Text("NEW")
                                .font(.system(size: 6, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 20, y: -20)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LuxuryTheme.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Text(description)
                    .font(LuxuryTheme.Typography.caption)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            if isNew {
                Text("🎉")
                    .font(.title2)
            } else {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundColor(LuxuryTheme.Colors.scanGreen)
            }
        }
        .padding(LuxuryTheme.Spacing.small)
        .luxuryGlassCard()
    }
}

struct LuxuryProgressRecommendationCard: View {
    let title: String
    let description: String
    let actionTitle: String
    let colors: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: LuxuryTheme.Spacing.small) {
            HStack(alignment: .top, spacing: LuxuryTheme.Spacing.small) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(LuxuryTheme.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text(description)
                        .font(LuxuryTheme.Typography.caption)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Button(action: {}) {
                Text(actionTitle)
                    .font(LuxuryTheme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(colors.first ?? LuxuryTheme.Colors.goldPrimary)
                    .padding(.horizontal, LuxuryTheme.Spacing.small)
                    .padding(.vertical, LuxuryTheme.Spacing.xxxSmall)
                    .background(
                        RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.small)
                            .fill((colors.first ?? LuxuryTheme.Colors.goldPrimary).opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.small)
                                    .stroke((colors.first ?? LuxuryTheme.Colors.goldPrimary).opacity(0.3), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(LuxuryTheme.Spacing.small)
        .luxuryCard()
    }
}

struct LuxuryDetailedProgressView: View {
    let metric: LuxuryProgressView.ProgressMetric
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: LuxuryTheme.Spacing.xLarge) {
                        // Header
                        VStack(spacing: LuxuryTheme.Spacing.medium) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: metric.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 80, height: 80)
                                    .shadow(color: metric.colors.first?.opacity(0.3) ?? .clear, radius: 15, x: 0, y: 8)
                                
                                Image(systemName: metric.icon)
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("\(metric.rawValue) Deep Analytics")
                                .font(LuxuryTheme.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(LuxuryTheme.Colors.primaryText)
                        }
                        .padding(.top, LuxuryTheme.Spacing.large)
                        
                        // Coming Soon Section
                        VStack(spacing: LuxuryTheme.Spacing.medium) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 60))
                                .foregroundColor(LuxuryTheme.Colors.aiBlue)
                            
                            Text("Advanced AI Analytics Coming Soon")
                                .font(LuxuryTheme.Typography.headline)
                                .foregroundColor(LuxuryTheme.Colors.primaryText)
                                .multilineTextAlignment(.center)
                            
                            Text("We're developing advanced machine learning algorithms to provide you with deeper insights into your \(metric.rawValue.lowercased()) patterns, personalized recommendations, and predictive analytics.")
                                .font(LuxuryTheme.Typography.body)
                                .foregroundColor(LuxuryTheme.Colors.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, LuxuryTheme.Spacing.medium)
                        }
                        .padding(LuxuryTheme.Spacing.large)
                        .luxuryGlassCard()
                        .padding(.horizontal, LuxuryTheme.Spacing.medium)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                }
            }
        }
    }
}

#Preview {
    LuxuryProgressView()
}
