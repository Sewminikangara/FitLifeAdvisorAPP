//
//  ProgressView.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//
import SwiftUI

struct ProgressView: View {
    @State private var selectedTimeframe: Timeframe = .week
    @State private var selectedMetric: ProgressMetric = .weight
    @State private var showingDetailedView = false
    @State private var animateCharts = false
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var dateRange: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            
            switch self {
            case .week:
                return "This Week"
            case .month:
                return "This Month"
            case .year:
                return "This Year"
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
            case .weight: return "scalemass"
            case .calories: return "flame"
            case .steps: return "figure.walk"
            case .workouts: return "figure.run"
            case .water: return "drop"
            case .sleep: return "bed.double"
            }
        }
        
        var color: Color {
            switch self {
            case .weight: return Constants.Colors.warningOrange
            case .calories: return Constants.Colors.errorRed
            case .steps: return Constants.Colors.successGreen
            case .workouts: return Constants.Colors.primaryBlue
            case .water: return Constants.Colors.primaryBlue
            case .sleep: return Color.purple
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
            ScrollView {
                VStack(spacing: Constants.Spacing.large) {
                    // Header with stats
                    progressHeaderSection
                    
                    // Time Range Selector
                    timeframeSelectorSection
                    
                    // Metric Selector
                    metricSelectorSection
                    
                    // Main Chart Section
                    chartSection
                    
                    // Analytics Cards
                    analyticsSection
                    
                    // Achievement Section
                    achievementSection
                    
                    // Detailed Stats
                    detailedStatsSection
                }
                .padding(.top, Constants.Spacing.medium)
                .padding(.bottom, Constants.Spacing.extraLarge)
            }
            .background(Constants.Colors.backgroundGray)
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                    animateCharts = true
                }
            }
        }
        .sheet(isPresented: $showingDetailedView) {
            DetailedProgressView(metric: selectedMetric)
        }
    }
    
    private var progressHeaderSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Progress")
                    .font(Constants.Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Text("Track your health journey")
                    .font(Constants.Typography.body)
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Spacer()
            
            Button(action: {
                showingDetailedView = true
            }) {
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Constants.Colors.primaryBlue)
            }
        }
        .padding(.horizontal, Constants.Spacing.large)
    }
    
    private var timeframeSelectorSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, Constants.Spacing.large)
            
            // Date range indicator
            Text(selectedTimeframe.dateRange)
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.textLight)
        }
    }
    
    private var metricSelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Spacing.medium) {
                ForEach(ProgressMetric.allCases, id: \.self) { metric in
                    MetricButton(
                        metric: metric,
                        isSelected: selectedMetric == metric,
                        action: {
                            withAnimation(.spring()) {
                                selectedMetric = metric
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    private var chartSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            HStack {
                Text("\(selectedMetric.rawValue) Trends")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Button(action: {
                    showingDetailedView = true
                }) {
                    HStack(spacing: 4) {
                        Text("Details")
                            .font(Constants.Typography.caption)
                        Image(systemName: "arrow.up.right")
                            .font(.caption2)
                    }
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            // Chart Container with mock data visualization
            VStack(spacing: Constants.Spacing.medium) {
                // Chart placeholder with animated elements
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(Constants.Colors.cardBackground)
                    .frame(height: 220)
                    .overlay(
                        VStack(spacing: Constants.Spacing.medium) {
                            // Chart title and value
                            VStack(spacing: 8) {
                                Text("Current: \(getCurrentValue())")
                                    .font(Constants.Typography.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(selectedMetric.color)
                                
                                Text("vs last \(selectedTimeframe.rawValue.lowercased()): +5.2%")
                                    .font(Constants.Typography.caption)
                                    .foregroundColor(Constants.Colors.successGreen)
                            }
                            
                            // Mock chart visualization
                            mockChartView
                        }
                        .padding(Constants.Spacing.large)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, Constants.Spacing.large)
                
                // Chart legend
                HStack(spacing: Constants.Spacing.large) {
                    ChartLegendItem(color: selectedMetric.color, label: selectedMetric.rawValue)
                    ChartLegendItem(color: Constants.Colors.textLight, label: "Average")
                    ChartLegendItem(color: Constants.Colors.successGreen, label: "Goal")
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
    
    private var mockChartView: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<7, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                selectedMetric.color.opacity(0.8),
                                selectedMetric.color.opacity(0.4)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 20, height: animateCharts ? CGFloat.random(in: 30...80) : 5)
                    .animation(.easeInOut(duration: 0.8).delay(Double(index) * 0.1), value: animateCharts)
            }
        }
    }
    
    private var analyticsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Constants.Spacing.medium) {
            AnalyticsCard(
                title: "This \(selectedTimeframe.rawValue)",
                value: getTrendValue(),
                change: "+12%",
                isPositive: true,
                color: selectedMetric.color
            )
            
            AnalyticsCard(
                title: "Best Day",
                value: getBestDay(),
                change: "Tuesday",
                isPositive: true,
                color: Constants.Colors.successGreen
            )
            
            AnalyticsCard(
                title: "Consistency",
                value: "85%",
                change: "Very Good",
                isPositive: true,
                color: Constants.Colors.primaryBlue
            )
            
            AnalyticsCard(
                title: "Goal Achievement",
                value: getGoalAchievement(),
                change: "On Track",
                isPositive: true,
                color: Constants.Colors.warningOrange
            )
        }
        .padding(.horizontal, Constants.Spacing.large)
    }
    
    private var achievementSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Recent Achievements")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Button("View All") {
                    // TODO: Navigate to achievements
                }
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            VStack(spacing: Constants.Spacing.small) {
                AchievementItem(
                    title: "Week Warrior",
                    description: "Completed 5 workouts this week!",
                    icon: "trophy.fill",
                    color: Constants.Colors.warningOrange,
                    isNew: true
                )
                
                AchievementItem(
                    title: "Step Master",
                    description: "Reached 10,000 steps for 3 days straight!",
                    icon: "figure.walk",
                    color: Constants.Colors.successGreen,
                    isNew: false
                )
                
                AchievementItem(
                    title: "Hydration Hero",
                    description: "Met daily water goal 7 days in a row!",
                    icon: "drop.fill",
                    color: Constants.Colors.primaryBlue,
                    isNew: false
                )
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    private var detailedStatsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Detailed Statistics")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Text(selectedTimeframe.rawValue)
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Constants.Colors.backgroundGray)
                    .cornerRadius(8)
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            VStack(spacing: Constants.Spacing.small) {
                DetailedStatRow(label: "Average", value: getAverageValue(), unit: selectedMetric.unit)
                DetailedStatRow(label: "Highest", value: getHighestValue(), unit: selectedMetric.unit)
                DetailedStatRow(label: "Lowest", value: getLowestValue(), unit: selectedMetric.unit)
                DetailedStatRow(label: "Total", value: getTotalValue(), unit: getTotalUnit())
                DetailedStatRow(label: "Days Active", value: "5", unit: "of 7 days")
                DetailedStatRow(label: "Improvement", value: "+8.3%", unit: "vs last \(selectedTimeframe.rawValue.lowercased())")
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    // Helper methods for dynamic data
    private func getCurrentValue() -> String {
        switch selectedMetric {
        case .weight: return "72.5 kg"
        case .calories: return "2,150 kcal"
        case .steps: return "8,947"
        case .workouts: return "4 sessions"
        case .water: return "7 glasses"
        case .sleep: return "7.5 hours"
        }
    }
    
    private func getTrendValue() -> String {
        switch selectedMetric {
        case .weight: return "↓ 1.2 kg"
        case .calories: return "↑ 2,180"
        case .steps: return "↑ 9,234"
        case .workouts: return "↑ 5"
        case .water: return "→ 7"
        case .sleep: return "↑ 7.8h"
        }
    }
    
    private func getBestDay() -> String {
        switch selectedMetric {
        case .weight: return "Mon"
        case .calories: return "Wed"
        case .steps: return "Sat"
        case .workouts: return "Tue"
        case .water: return "Thu"
        case .sleep: return "Sun"
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
    
    private func getAverageValue() -> String {
        switch selectedMetric {
        case .weight: return "72.8"
        case .calories: return "2,045"
        case .steps: return "8,432"
        case .workouts: return "4.2"
        case .water: return "6.5"
        case .sleep: return "7.3"
        }
    }
    
    private func getHighestValue() -> String {
        switch selectedMetric {
        case .weight: return "73.2"
        case .calories: return "2,350"
        case .steps: return "12,580"
        case .workouts: return "2"
        case .water: return "9"
        case .sleep: return "8.5"
        }
    }
    
    private func getLowestValue() -> String {
        switch selectedMetric {
        case .weight: return "72.1"
        case .calories: return "1,850"
        case .steps: return "5,240"
        case .workouts: return "0"
        case .water: return "4"
        case .sleep: return "6.2"
        }
    }
    
    private func getTotalValue() -> String {
        switch selectedMetric {
        case .weight: return "Average"
        case .calories: return "14,315"
        case .steps: return "59,024"
        case .workouts: return "21"
        case .water: return "45"
        case .sleep: return "51.1"
        }
    }
    
    private func getTotalUnit() -> String {
        switch selectedMetric {
        case .weight: return selectedMetric.unit
        case .calories: return selectedMetric.unit
        case .steps: return selectedMetric.unit
        case .workouts: return "total"
        case .water: return "total"
        case .sleep: return "total hours"
        }
    }
}

// MARK: - 8. Supporting Components for Progress View

struct MetricButton: View {
    let metric: ProgressView.ProgressMetric
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.Spacing.small) {
                Image(systemName: metric.icon)
                    .font(.caption)
                
                Text(metric.rawValue)
                    .font(Constants.Typography.caption)
                    .fontWeight(isSelected ? .medium : .regular)
            }
            .padding(.horizontal, Constants.Spacing.medium)
            .padding(.vertical, Constants.Spacing.small)
            .background(
                isSelected ?
                LinearGradient(
                    gradient: Gradient(colors: [metric.color, metric.color.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    gradient: Gradient(colors: [Constants.Colors.cardBackground, Constants.Colors.cardBackground]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(isSelected ? .white : Constants.Colors.textDark)
            .cornerRadius(Constants.smallCornerRadius)
            .shadow(color: isSelected ? metric.color.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            Text(title)
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.textLight)
            
            Text(value)
                .font(Constants.Typography.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            HStack(spacing: 4) {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption2)
                    .foregroundColor(isPositive ? Constants.Colors.successGreen : Constants.Colors.errorRed)
                
                Text(change)
                    .font(Constants.Typography.small)
                    .foregroundColor(isPositive ? Constants.Colors.successGreen : Constants.Colors.errorRed)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AchievementItem: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isNew: Bool
    
    var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                if isNew {
                    Circle()
                        .fill(Constants.Colors.errorRed)
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
                    .font(Constants.Typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(description)
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Spacer()
            
            if isNew {
                Text("🎉")
                    .font(.title2)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(Constants.Colors.successGreen)
            }
        }
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ChartLegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(Constants.Typography.small)
                .foregroundColor(Constants.Colors.textLight)
        }
    }
}

struct DetailedStatRow: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Constants.Typography.body)
                .foregroundColor(Constants.Colors.textLight)
            
            Spacer()
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(Constants.Typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(unit)
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.smallCornerRadius)
    }
}
struct DetailedProgressView: View {
    let metric: ProgressView.ProgressMetric
    @Environment(\.dismiss) var dismiss
    @State private var selectedPeriod = "Week"
    
    let periods = ["Week", "Month", "3 Months", "Year"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.large) {
                    // Header
                    VStack(spacing: Constants.Spacing.medium) {
                        Image(systemName: metric.icon + ".circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(metric.color)
                        
                        Text("\(metric.rawValue) Analytics")
                            .font(Constants.Typography.title)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.textDark)
                    }
                    .padding(.top, Constants.Spacing.large)
                    
                    // Period selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(periods, id: \.self) { period in
                            Text(period).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, Constants.Spacing.large)
                    
                    // Detailed chart placeholder
                    VStack(spacing: Constants.Spacing.medium) {
                        Text("Detailed \(metric.rawValue) Chart")
                            .font(Constants.Typography.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.textDark)
                        
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .fill(Constants.Colors.cardBackground)
                            .frame(height: 250)
                            .overlay(
                                VStack(spacing: Constants.Spacing.medium) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.system(size: 50))
                                        .foregroundColor(metric.color)
                                    
                                    Text("Advanced Chart Coming Soon!")
                                        .font(Constants.Typography.body)
                                        .foregroundColor(Constants.Colors.textLight)
                                    
                                    Text("This will show detailed trends, patterns, and insights for your \(metric.rawValue.lowercased()) data.")
                                        .font(Constants.Typography.caption)
                                        .foregroundColor(Constants.Colors.textLight)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, Constants.Spacing.large)
                                }
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    }
                    .padding(.horizontal, Constants.Spacing.large)
                    
                    // Advanced stats
                    VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                        Text("Advanced Statistics")
                            .font(Constants.Typography.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.textDark)
                            .padding(.horizontal, Constants.Spacing.large)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Constants.Spacing.medium) {
                            ProgressStatCard(title: "Standard Deviation", value: "±12.3", color: metric.color)
                            ProgressStatCard(title: "Median", value: "2,150", color: metric.color)
                            ProgressStatCard(title: "Percentile (90th)", value: "2,380", color: metric.color)
                            ProgressStatCard(title: "Trend Direction", value: "↗ Increasing", color: Constants.Colors.successGreen)
                        }
                        .padding(.horizontal, Constants.Spacing.large)
                    }
                }
                .padding(.bottom, Constants.Spacing.extraLarge)
            }
            .background(Constants.Colors.backgroundGray)
            .navigationTitle("Detailed Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
        }
    }
}

struct ProgressStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Constants.Spacing.small) {
            Text(title)
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.textLight)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(Constants.Typography.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}
