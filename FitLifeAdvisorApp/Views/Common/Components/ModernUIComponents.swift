//
//  ModernUIComponents.swift
//  FitLifeAdvisorApp
//
//  Modern UI Components for enhanced user experience
//

import SwiftUI

// MARK: - Modern Header View
struct ModernHeaderView: View {
    let title: String
    let subtitle: String
    var showUserAvatar: Bool = true
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Spacer()
            
            if showUserAvatar {
                Button(action: {}) {
                    AsyncImage(url: nil) { _ in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Constants.Colors.primaryBlue, Constants.Colors.primaryBlue.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text("U")
                                    .font(.system(size: 18, weight: .bold))
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
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text("U")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    .shadow(color: Constants.Colors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding(.vertical, Constants.Spacing.medium)
    }
}

// MARK: - Modern Progress Cards
struct ModernProgressCards: View {
    var body: some View {
        VStack(spacing: Constants.Spacing.medium) {
            HStack(spacing: Constants.Spacing.medium) {
                ModernStatsCard(
                    title: "Calories",
                    value: "1,847",
                    target: "2,200",
                    progress: 0.84,
                    icon: "flame.fill",
                    color: .orange
                )
                
                ModernStatsCard(
                    title: "Steps",
                    value: "8,542",
                    target: "10,000",
                    progress: 0.85,
                    icon: "figure.walk",
                    color: .green
                )
            }
            
            HStack(spacing: Constants.Spacing.medium) {
                ModernStatsCard(
                    title: "Water",
                    value: "6",
                    target: "8 glasses",
                    progress: 0.75,
                    icon: "drop.fill",
                    color: .blue
                )
                
                ModernStatsCard(
                    title: "Sleep",
                    value: "7.5h",
                    target: "8h",
                    progress: 0.94,
                    icon: "moon.fill",
                    color: .indigo
                )
            }
        }
    }
}

// MARK: - Modern Stats Card
struct ModernStatsCard: View {
    let title: String
    let value: String
    let target: String
    let progress: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text("of \(target)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(color.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 1.0), value: progress)
                }
            }
            .frame(height: 4)
        }
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Modern Charts Section
struct ModernChartsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Weekly Trends")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Button("View All") {
                    // Action
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            
            ModernWeeklyChart()
        }
    }
}

// MARK: - Modern Weekly Chart
struct ModernWeeklyChart: View {
    let weekData = [0.6, 0.8, 0.75, 0.9, 0.85, 0.7, 0.95]
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack(spacing: Constants.Spacing.medium) {
            HStack(alignment: .bottom, spacing: Constants.Spacing.small) {
                ForEach(Array(weekData.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 8) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Constants.Colors.primaryBlue, Constants.Colors.primaryBlue.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 32, height: CGFloat(value * 120))
                            .cornerRadius(4)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(Double(index) * 0.1), value: value)
                        
                        Text(days[index])
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Constants.Colors.textLight)
                    }
                }
            }
            .padding(.vertical, Constants.Spacing.medium)
        }
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Modern Achievements Section
struct ModernAchievementsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Recent Achievements")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.medium) {
                    ModernAchievementCard(
                        icon: "trophy.fill",
                        title: "7-Day Streak",
                        description: "Logged meals daily",
                        color: .orange
                    )
                    
                    ModernAchievementCard(
                        icon: "target",
                        title: "Goal Crusher",
                        description: "Met calorie target",
                        color: .green
                    )
                    
                    ModernAchievementCard(
                        icon: "heart.fill",
                        title: "Fitness Hero",
                        description: "10k steps reached",
                        color: .red
                    )
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
}

// MARK: - Modern Achievement Card
struct ModernAchievementCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Constants.Spacing.small) {
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
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 120)
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Modern Quick Log Actions
struct ModernQuickLogActions: View {
    var body: some View {
        VStack(spacing: Constants.Spacing.medium) {
            HStack(spacing: Constants.Spacing.medium) {
                ModernActionCard(
                    icon: "camera.fill",
                    title: "Snap Meal",
                    subtitle: "AI-powered analysis",
                    color: .blue
                ) {
                    // Action
                }
                
                ModernActionCard(
                    icon: "plus.circle.fill",
                    title: "Quick Add",
                    subtitle: "Manual entry",
                    color: .green
                ) {
                    // Action
                }
            }
            
            HStack(spacing: Constants.Spacing.medium) {
                ModernActionCard(
                    icon: "figure.run",
                    title: "Log Workout",
                    subtitle: "Track exercise",
                    color: .orange
                ) {
                    // Action
                }
                
                ModernActionCard(
                    icon: "drop.fill",
                    title: "Water Intake",
                    subtitle: "Stay hydrated",
                    color: .cyan
                ) {
                    // Action
                }
            }
        }
    }
}

// MARK: - Modern Action Card
struct ModernActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Constants.Spacing.small) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
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
            .padding(Constants.Spacing.large)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(ModernButtonStyle())
    }
}

// MARK: - Modern Recent Logs
struct ModernRecentLogs: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Today's Logs")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Button("View All") {
                    // Action
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            
            VStack(spacing: Constants.Spacing.small) {
                ModernLogEntry(
                    icon: "fork.knife.circle.fill",
                    title: "Breakfast",
                    subtitle: "Greek yogurt with berries",
                    time: "8:30 AM",
                    calories: "320 cal",
                    color: .orange
                )
                
                ModernLogEntry(
                    icon: "figure.run.circle.fill",
                    title: "Morning Run",
                    subtitle: "30 min cardio workout",
                    time: "7:00 AM",
                    calories: "280 cal",
                    color: .red
                )
                
                ModernLogEntry(
                    icon: "drop.circle.fill",
                    title: "Water Intake",
                    subtitle: "2 glasses of water",
                    time: "9:15 AM",
                    calories: "0 cal",
                    color: .blue
                )
            }
            .padding(Constants.Spacing.large)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        }
    }
}

// MARK: - Modern Log Entry
struct ModernLogEntry: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let calories: String
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
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(calories)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(time)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
        }
        .padding(.vertical, Constants.Spacing.small)
    }
}

// MARK: - Modern Smart Suggestions
struct ModernSmartSuggestions: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Smart Suggestions")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
            }
            
            VStack(spacing: Constants.Spacing.small) {
                ModernSuggestionCard(
                    icon: "lightbulb.fill",
                    title: "Drink More Water",
                    subtitle: "You're 2 glasses behind your daily goal",
                    action: "Log Water",
                    color: .blue
                )
                
                ModernSuggestionCard(
                    icon: "leaf.fill",
                    title: "Add Some Greens",
                    subtitle: "Consider a salad for lunch today",
                    action: "Browse Recipes",
                    color: .green
                )
            }
        }
    }
}

// MARK: - Modern Suggestion Card
struct ModernSuggestionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: String
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
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text(action)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(color.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Modern Today's Plan
struct ModernTodaysPlan: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Today's Plan")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Text("Dec 10, 2025")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            VStack(spacing: Constants.Spacing.small) {
                ModernPlanItem(
                    icon: "sunrise.fill",
                    title: "Morning Cardio",
                    time: "7:00 AM",
                    duration: "30 min",
                    isCompleted: true,
                    color: .orange
                )
                
                ModernPlanItem(
                    icon: "fork.knife.circle.fill",
                    title: "Breakfast",
                    time: "8:30 AM",
                    duration: "Oatmeal & Fruits",
                    isCompleted: true,
                    color: .green
                )
                
                ModernPlanItem(
                    icon: "dumbbell.fill",
                    title: "Strength Training",
                    time: "6:00 PM",
                    duration: "45 min",
                    isCompleted: false,
                    color: .red
                )
            }
            .padding(Constants.Spacing.large)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        }
    }
}

// MARK: - Modern Plan Item
struct ModernPlanItem: View {
    let icon: String
    let title: String
    let time: String
    let duration: String
    let isCompleted: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(isCompleted ? color : color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isCompleted ? Constants.Colors.textLight : Constants.Colors.textDark)
                    .strikethrough(isCompleted)
                
                Text(duration)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Spacer()
            
            Text(time)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.textLight)
        }
        .padding(.vertical, Constants.Spacing.small)
    }
}

// MARK: - Modern Weekly Overview
struct ModernWeeklyOverview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("This Week")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Button("Edit Plan") {
                    // Action
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.medium) {
                    ForEach(0..<7) { day in
                        ModernDayCard(
                            day: "Mon",
                            date: "\(day + 4)",
                            workouts: 2,
                            meals: 3,
                            isToday: day == 6
                        )
                    }
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
}

// MARK: - Modern Day Card
struct ModernDayCard: View {
    let day: String
    let date: String
    let workouts: Int
    let meals: Int
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: Constants.Spacing.small) {
            VStack(spacing: 4) {
                Text(day)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isToday ? .white : Constants.Colors.textLight)
                
                Text(date)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isToday ? .white : Constants.Colors.textDark)
            }
            
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 10))
                        .foregroundColor(isToday ? .white : Constants.Colors.textLight)
                    
                    Text("\(workouts)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isToday ? .white : Constants.Colors.textLight)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 10))
                        .foregroundColor(isToday ? .white : Constants.Colors.textLight)
                    
                    Text("\(meals)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isToday ? .white : Constants.Colors.textLight)
                }
            }
        }
        .frame(width: 70, height: 90)
        .background(
            isToday ? 
            LinearGradient(
                colors: [Constants.Colors.primaryBlue, Constants.Colors.primaryBlue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) : 
            LinearGradient(colors: [.white, .white], startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(12)
        .shadow(
            color: isToday ? Constants.Colors.primaryBlue.opacity(0.3) : .black.opacity(0.08),
            radius: isToday ? 12 : 8,
            x: 0,
            y: isToday ? 6 : 4
        )
    }
}

// MARK: - Modern Recommended Plans
struct ModernRecommendedPlans: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Recommended for You")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.medium) {
                    ModernPlanCard(
                        title: "Weight Loss Journey",
                        subtitle: "12-week program",
                        image: "figure.walk",
                        color: .green
                    )
                    
                    ModernPlanCard(
                        title: "Muscle Building",
                        subtitle: "8-week strength focus",
                        image: "dumbbell.fill",
                        color: .red
                    )
                    
                    ModernPlanCard(
                        title: "Wellness Reset",
                        subtitle: "4-week detox plan",
                        image: "leaf.fill",
                        color: .blue
                    )
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
}

// MARK: - Modern Plan Card
struct ModernPlanCard: View {
    let title: String
    let subtitle: String
    let image: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: image)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Button("Start Plan") {
                // Action
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color)
            .cornerRadius(8)
        }
        .frame(width: 160)
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

struct ModernButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Press Button Style
struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ModernHeaderView(title: "Welcome Back!", subtitle: "Ready to crush your goals today?")
            
            ModernProgressCards()
            
            ModernChartsSection()
            
            ModernAchievementsSection()
        }
        .padding(.horizontal)
        .background(Constants.Colors.backgroundGray)
    }
}
