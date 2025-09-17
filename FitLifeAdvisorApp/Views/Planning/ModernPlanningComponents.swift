//
//  ModernPlanningComponents.swift
//  FitLifeAdvisorApp
//
//  Modern components for the planning interface
//

import SwiftUI

// MARK: - Modern Supporting Components

struct ModernMealPlanItem: View {
    let day: String
    let daySubtitle: String
    let breakfast: String
    let lunch: String
    let dinner: String
    let isToday: Bool
    
    init(day: String, daySubtitle: String = "", breakfast: String, lunch: String, dinner: String, isToday: Bool = false) {
        self.day = day
        self.daySubtitle = daySubtitle
        self.breakfast = breakfast
        self.lunch = lunch
        self.dinner = dinner
        self.isToday = isToday
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(day)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isToday ? Constants.Colors.successGreen : Constants.Colors.textDark)
                    
                    if !daySubtitle.isEmpty {
                        Text(daySubtitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Constants.Colors.textLight)
                    }
                }
                
                Spacer()
                
                if isToday {
                    Text("TODAY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Constants.Colors.successGreen)
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                ModernMealRow(mealTime: "Breakfast", food: breakfast, icon: "sun.max.fill")
                ModernMealRow(mealTime: "Lunch", food: lunch, icon: "sun.haze.fill")
                ModernMealRow(mealTime: "Dinner", food: dinner, icon: "moon.fill")
            }
        }
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isToday ? Constants.Colors.successGreen.opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .shadow(color: isToday ? Constants.Colors.successGreen.opacity(0.2) : .black.opacity(0.08), radius: 12, x: 0, y: 6)
        .padding(.horizontal, Constants.Spacing.large)
    }
}

struct ModernMealRow: View {
    let mealTime: String
    let food: String
    let icon: String
    
    var body: some View {
        HStack(spacing: Constants.Spacing.small) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Constants.Colors.successGreen)
                .frame(width: 20, alignment: .leading)
            
            Text(mealTime)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Constants.Colors.textLight)
                .frame(width: 80, alignment: .leading)
            
            Text(food)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.textDark)
                .lineLimit(1)
            
            Spacer()
        }
    }
}

struct QuickMealCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let mealCount: String
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                    
                    Text(mealCount)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Spacer()
            }
            .padding(Constants.Spacing.medium)
            .frame(width: 140, height: 120)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ModernButtonStyle())
    }
}

struct NutritionGoalCard: View {
    let title: String
    let current: String
    let target: String
    let progress: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: Constants.Spacing.small) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(current)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text("/ \(target)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color.opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: geometry.size.width * progress, height: 6)
                            .animation(.easeInOut(duration: 1), value: progress)
                    }
                }
                .frame(height: 6)
            }
            
            Spacer()
        }
        .padding(Constants.Spacing.medium)
        .frame(height: 120)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct ModernWorkoutPlanItem: View {
    let day: String
    let daySubtitle: String
    let workout: String
    let duration: String
    let difficulty: String
    let isToday: Bool
    
    init(day: String, daySubtitle: String = "", workout: String, duration: String, difficulty: String, isToday: Bool = false) {
        self.day = day
        self.daySubtitle = daySubtitle
        self.workout = workout
        self.duration = duration
        self.difficulty = difficulty
        self.isToday = isToday
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(day)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isToday ? Constants.Colors.primaryBlue : Constants.Colors.textDark)
                    
                    if !daySubtitle.isEmpty {
                        Text(daySubtitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Constants.Colors.textLight)
                    }
                }
                
                Spacer()
                
                if isToday {
                    Text("TODAY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Constants.Colors.primaryBlue)
                        .cornerRadius(8)
                }
            }
            
            HStack(spacing: Constants.Spacing.medium) {
                ZStack {
                    Circle()
                        .fill(Constants.Colors.primaryBlue.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "figure.run")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    HStack(spacing: Constants.Spacing.medium) {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.caption)
                            Text(duration)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Constants.Colors.textLight)
                        
                        Text("•")
                            .foregroundColor(Constants.Colors.textLight)
                        
                        Text(difficulty)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Constants.Colors.primaryBlue)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
        }
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isToday ? Constants.Colors.primaryBlue.opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .shadow(color: isToday ? Constants.Colors.primaryBlue.opacity(0.2) : .black.opacity(0.08), radius: 12, x: 0, y: 6)
        .padding(.horizontal, Constants.Spacing.large)
    }
}

struct PlanningWorkoutTypeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let sessionCount: String
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                    
                    Text(sessionCount)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Spacer()
            }
            .padding(Constants.Spacing.medium)
            .frame(width: 140, height: 120)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ModernButtonStyle())
    }
}

struct PerformanceCard: View {
    let title: String
    let current: String
    let subtitle: String
    let progress: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: Constants.Spacing.small) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(current)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                
                // Progress indicator
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(index < Int(progress * 5) ? color : color.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            
            Spacer()
        }
        .padding(Constants.Spacing.medium)
        .frame(height: 120)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Modern Planner Views
struct ModernMealPlannerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDay = "Monday"
    @State private var breakfast = ""
    @State private var lunch = ""
    @State private var dinner = ""
    
    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Constants.Colors.backgroundGray,
                        Constants.Colors.backgroundGray.opacity(0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.Spacing.large) {
                        VStack(spacing: Constants.Spacing.medium) {
                            ZStack {
                                Circle()
                                    .fill(Constants.Colors.successGreen.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(Constants.Colors.successGreen)
                            }
                            
                            Text("Plan Your Meals")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Constants.Colors.textDark)
                        }
                        .padding(.top, Constants.Spacing.large)
                        
                        Picker("Day", selection: $selectedDay) {
                            ForEach(days, id: \.self) { day in
                                Text(day).tag(day)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, Constants.Spacing.large)
                        
                        VStack(spacing: Constants.Spacing.medium) {
                            ModernTextField(title: "🌅 Breakfast", text: $breakfast, placeholder: "e.g., Overnight oats with berries", icon: "sun.max")
                            ModernTextField(title: "☀️ Lunch", text: $lunch, placeholder: "e.g., Quinoa salad bowl", icon: "sun.haze")
                            ModernTextField(title: "🌙 Dinner", text: $dinner, placeholder: "e.g., Grilled salmon with vegetables", icon: "moon")
                        }
                        .padding(.horizontal, Constants.Spacing.large)
                        
                        Button(action: { dismiss() }) {
                            Text("Save Meal Plan")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Constants.Spacing.large)
                                .background(
                                    LinearGradient(
                                        colors: [Constants.Colors.successGreen, Constants.Colors.successGreen.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Constants.Colors.successGreen.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(ModernButtonStyle())
                        .disabled(breakfast.isEmpty && lunch.isEmpty && dinner.isEmpty)
                        .padding(.horizontal, Constants.Spacing.large)
                        .padding(.bottom, Constants.Spacing.extraLarge)
                    }
                }
            }
            .navigationTitle("Meal Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Constants.Colors.textLight)
                }
            }
        }
    }
}

struct ModernWorkoutPlannerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDay = "Monday"
    @State private var workoutType = ""
    @State private var duration = ""
    @State private var difficulty = "Beginner"
    
    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let difficulties = ["Beginner", "Intermediate", "Advanced"]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Constants.Colors.backgroundGray,
                        Constants.Colors.backgroundGray.opacity(0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.Spacing.large) {
                        VStack(spacing: Constants.Spacing.medium) {
                            ZStack {
                                Circle()
                                    .fill(Constants.Colors.primaryBlue.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "figure.run")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(Constants.Colors.primaryBlue)
                            }
                            
                            Text("Plan Your Workouts")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Constants.Colors.textDark)
                        }
                        .padding(.top, Constants.Spacing.large)
                        
                        Picker("Day", selection: $selectedDay) {
                            ForEach(days, id: \.self) { day in
                                Text(day).tag(day)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, Constants.Spacing.large)
                        
                        VStack(spacing: Constants.Spacing.medium) {
                            ModernTextField(title: "💪 Workout Type", text: $workoutType, placeholder: "e.g., Upper Body Strength", icon: "dumbbell")
                            ModernTextField(title: "⏰ Duration (minutes)", text: $duration, placeholder: "e.g., 45", icon: "timer", keyboardType: .numberPad)
                            
                            VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                                Text("🎯 Difficulty Level")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Constants.Colors.textDark)
                                
                                Picker("Difficulty", selection: $difficulty) {
                                    ForEach(difficulties, id: \.self) { level in
                                        Text(level).tag(level)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                        .padding(.horizontal, Constants.Spacing.large)
                        
                        Button(action: { dismiss() }) {
                            Text("Save Workout Plan")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Constants.Spacing.large)
                                .background(
                                    LinearGradient(
                                        colors: [Constants.Colors.primaryBlue, Constants.Colors.primaryBlue.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Constants.Colors.primaryBlue.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(ModernButtonStyle())
                        .disabled(workoutType.isEmpty || duration.isEmpty)
                        .padding(.horizontal, Constants.Spacing.large)
                        .padding(.bottom, Constants.Spacing.extraLarge)
                    }
                }
            }
            .navigationTitle("Workout Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Constants.Colors.textLight)
                }
            }
        }
    }
}

#Preview {
    ModernMealPlanItem(
        day: "Today",
        daySubtitle: "Monday",
        breakfast: "Overnight Oats with Berries",
        lunch: "Quinoa Buddha Bowl",
        dinner: "Grilled Salmon & Veggies",
        isToday: true
    )
}
