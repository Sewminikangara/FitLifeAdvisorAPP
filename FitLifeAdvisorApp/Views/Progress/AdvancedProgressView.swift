//
//  AdvancedProgressView.swift
//  FitLifeAdvisorApp
//
//   health analytics and progress tracking


import SwiftUI

struct AdvancedProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: HealthMetric = .weight
    @State private var showingInsights = false
    
    enum TimeRange: String, CaseIterable {
        case week = "1W"
        case month = "1M"
        case quarter = "3M"
        case year = "1Y"
        
        var displayName: String {
            switch self {
            case .week: return "This Week"
            case .month: return "This Month"
            case .quarter: return "3 Months"
            case .year: return "This Year"
            }
        }
    }
    
    enum HealthMetric: String, CaseIterable {
        case weight = "Weight"
        case bodyFat = "Body Fat %"
        case muscle = "Muscle Mass"
        case calories = "Calories"
        case steps = "Steps"
        case sleep = "Sleep"
        case water = "Hydration"
        
        var icon: String {
            switch self {
            case .weight: return "scalemass"
            case .bodyFat: return "percent"
            case .muscle: return "figure.strengthtraining.traditional"
            case .calories: return "flame"
            case .steps: return "figure.walk"
            case .sleep: return "bed.double"
            case .water: return "drop"
            }
        }
        
        var color: Color {
            switch self {
            case .weight: return Color(hex: "FF6B6B")
            case .bodyFat: return Color(hex: "FFD93D")
            case .muscle: return Color(hex: "4ECDC4")
            case .calories: return Color(hex: "FF8A65")
            case .steps: return Color(hex: "667eea")
            case .sleep: return Color(hex: "6C5CE7")
            case .water: return Color(hex: "00E5FF")
            }
        }
        
        var unit: String {
            switch self {
            case .weight: return "kg"
            case .bodyFat: return "%"
            case .muscle: return "kg"
            case .calories: return "kcal"
            case .steps: return "steps"
            case .sleep: return "hrs"
            case .water: return "L"
            }
        }
    }
    
    // Sample data for charts
    private let sampleWeightData = [
        ProgressDataPoint(date: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, value: 75.2),
        ProgressDataPoint(date: Calendar.current.date(byAdding: .day, value: -25, to: Date())!, value: 74.8),
        ProgressDataPoint(date: Calendar.current.date(byAdding: .day, value: -20, to: Date())!, value: 74.5),
        ProgressDataPoint(date: Calendar.current.date(byAdding: .day, value: -15, to: Date())!, value: 74.1),
        ProgressDataPoint(date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, value: 73.8),
        ProgressDataPoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, value: 73.5),
        ProgressDataPoint(date: Date(), value: 73.2)
    ]
    
    private let sampleCaloriesData = [
        ProgressDataPoint(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, value: 2150),
        ProgressDataPoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, value: 1980),
        ProgressDataPoint(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, value: 2200),
        ProgressDataPoint(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, value: 2050),
        ProgressDataPoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, value: 2180),
        ProgressDataPoint(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, value: 1950),
        ProgressDataPoint(date: Date(), value: 2100)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.black, Color(hex: "1A1A2E")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 15) {
                            Text("📊 Advanced Analytics")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Deep insights into your health journey")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // AI Health Score Summary
                        healthScoreSection
                        
                        // Time Range Selector
                        timeRangeSelector
                        
                        // Metric Selector
                        metricSelector
                        
                        // Main Chart
                        mainChart
                        
                        // Progress Statistics
                        progressStatistics
                        
                        // AI Insights
                        aiInsightsSection
                        
                        // Achievement Badges
                        achievementBadges
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingInsights = true }) {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(Color(hex: "00E5FF"))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "00E5FF"))
                }
            }
        }
    }
    
    private var healthScoreSection: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                            .foregroundColor(Color(hex: "00E5FF"))
                        
                        Text("AI Health Score")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Text("96/100")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(hex: "00E5FF"))
                    
                    Text("Exceptional Progress!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: 0.96)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "00E5FF"), Color(hex: "0091EA")],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("96")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("%")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            // Health Score Breakdown
            VStack(spacing: 10) {
                HealthScoreBreakdownRow(category: "Nutrition", score: 98, color: Color(hex: "4ECDC4"))
                HealthScoreBreakdownRow(category: "Exercise", score: 94, color: Color(hex: "FF6B6B"))
                HealthScoreBreakdownRow(category: "Sleep", score: 92, color: Color(hex: "6C5CE7"))
                HealthScoreBreakdownRow(category: "Hydration", score: 100, color: Color(hex: "00E5FF"))
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var timeRangeSelector: some View {
        HStack(spacing: 0) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTimeRange = range
                    }
                }) {
                    Text(range.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedTimeRange == range ? .white : .white.opacity(0.6))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    selectedTimeRange == range 
                                    ? LinearGradient(
                                        colors: [Color(hex: "00E5FF").opacity(0.3), Color(hex: "0091EA").opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            selectedTimeRange == range 
                                            ? Color(hex: "00E5FF").opacity(0.5)
                                            : Color.clear,
                                            lineWidth: 1
                                        )
                                )
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var metricSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(HealthMetric.allCases, id: \.self) { metric in
                    MetricChip(
                        metric: metric,
                        isSelected: selectedMetric == metric
                    ) {
                        selectedMetric = metric
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var mainChart: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedMetric.rawValue)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(selectedTimeRange.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(currentValue(for: selectedMetric))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(selectedMetric.color)
                    
                    Text(selectedMetric.unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Chart placeholder (using sample data)
            chartView
                .frame(height: 200)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var chartView: some View {
        // Simple line chart representation
        GeometryReader { geometry in
            let data = selectedMetric == .weight ? sampleWeightData : sampleCaloriesData
            let maxValue = data.map(\.value).max() ?? 0
            let minValue = data.map(\.value).min() ?? 0
            let valueRange = maxValue - minValue
            
            ZStack {
                // Grid lines
                VStack {
                    ForEach(0..<5) { i in
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                        if i < 4 { Spacer() }
                    }
                }
                
                // Data line
                Path { path in
                    let stepX = geometry.size.width / CGFloat(data.count - 1)
                    
                    for (index, dataPoint) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let normalizedY = valueRange > 0 ? (dataPoint.value - minValue) / valueRange : 0.5
                        let y = geometry.size.height - (normalizedY * geometry.size.height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(selectedMetric.color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                
                // Data points
                ForEach(Array(data.enumerated()), id: \.offset) { index, dataPoint in
                    let stepX = geometry.size.width / CGFloat(data.count - 1)
                    let x = CGFloat(index) * stepX
                    let normalizedY = valueRange > 0 ? (dataPoint.value - minValue) / valueRange : 0.5
                    let y = geometry.size.height - (normalizedY * geometry.size.height)
                    
                    Circle()
                        .fill(selectedMetric.color)
                        .frame(width: 6, height: 6)
                        .position(x: x, y: y)
                }
            }
        }
    }
    
    private var progressStatistics: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Progress Statistics")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 15) {
                StatCard(
                    title: "Change",
                    value: "-2.0 kg",
                    subtitle: "Last 30 days",
                    color: Color(hex: "4ECDC4"),
                    trend: .down
                )
                
                StatCard(
                    title: "Average",
                    value: "2,065",
                    subtitle: "Daily calories",
                    color: Color(hex: "FF6B6B"),
                    trend: .stable
                )
            }
            
            HStack(spacing: 15) {
                StatCard(
                    title: "Best Day",
                    value: "12,450",
                    subtitle: "Steps record",
                    color: Color(hex: "667eea"),
                    trend: .up
                )
                
                StatCard(
                    title: "Streak",
                    value: "14 days",
                    subtitle: "Goal achieved",
                    color: Color(hex: "FFD93D"),
                    trend: .up
                )
            }
        }
    }
    
    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(Color(hex: "00E5FF"))
                Text("AI Insights")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                InsightCard(
                    title: "Weight Loss Acceleration",
                    description: "Your weight loss rate has increased by 25% this month. Great consistency!",
                    icon: "arrow.down.circle",
                    color: Color(hex: "4ECDC4")
                )
                
                InsightCard(
                    title: "Optimal Training Window",
                    description: "Your performance peaks between 6-8 PM. Consider scheduling workouts then.",
                    icon: "clock.arrow.circlepath",
                    color: Color(hex: "FFD93D")
                )
                
                InsightCard(
                    title: "Nutrition Pattern",
                    description: "You tend to consume more calories on weekends. Consider meal prep strategies.",
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color(hex: "FF6B6B")
                )
            }
        }
    }
    
    private var achievementBadges: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Achievements")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    AchievementBadge(
                        title: "Weight Goal",
                        description: "Lost 2kg this month",
                        icon: "trophy.fill",
                        color: Color(hex: "FFD700")
                    )
                    
                    AchievementBadge(
                        title: "Consistency",
                        description: "14-day workout streak",
                        icon: "flame.fill",
                        color: Color(hex: "FF6B6B")
                    )
                    
                    AchievementBadge(
                        title: "Hydration",
                        description: "Perfect water intake week",
                        icon: "drop.fill",
                        color: Color(hex: "00E5FF")
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func currentValue(for metric: HealthMetric) -> String {
        switch metric {
        case .weight: return "73.2"
        case .bodyFat: return "18.5"
        case .muscle: return "54.7"
        case .calories: return "2,100"
        case .steps: return "8,432"
        case .sleep: return "7.5"
        case .water: return "2.1"
        }
    }
}

// MARK: - Supporting Views

struct ProgressDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct HealthScoreBreakdownRow: View {
    let category: String
    let score: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(category)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 8) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: geometry.size.width * (CGFloat(score) / 100), height: 6)
                    }
                }
                .frame(width: 60, height: 6)
                
                Text("\(score)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 30, alignment: .trailing)
            }
        }
    }
}

struct MetricChip: View {
    let metric: AdvancedProgressView.HealthMetric
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: metric.icon)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(metric.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : metric.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? metric.color.opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? metric.color : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let trend: TrendDirection
    
    enum TrendDirection {
        case up, down, stable
        
        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .stable: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .stable: return .yellow
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(trend.color)
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct InsightCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct AchievementBadge: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 120)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    AdvancedProgressView()
}
