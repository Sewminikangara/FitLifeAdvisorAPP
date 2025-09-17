//
//  LogView.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import SwiftUI

struct LogView: View {
    @State private var showingSmartCamera = false
    @State private var showingWorkoutLogger = false
    @State private var showingWeightLogger = false
    @StateObject private var mealAnalysisManager = MealAnalysisManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.extraLarge) {
                    // Header Section
                    headerSection
                    
                    // Smart Meal Logging Section
                    smartMealSection
                    
                    // Quick Action Buttons
                    quickActionsSection
                    
                    // Today's Summary
                    if !mealAnalysisManager.getMealsForToday().isEmpty {
                        todaysSummarySection
                    }
                    
                    // Recent Meals
                    if !mealAnalysisManager.getMealsForToday().isEmpty {
                        recentMealsSection
                    }
                }
                .padding(.horizontal, Constants.Spacing.large)
                .padding(.bottom, Constants.Spacing.extraLarge)
            }
            .background(Constants.Colors.backgroundGray)
            .navigationTitle("Log Activities")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $showingSmartCamera) {
            MealCameraView()
        }
        .sheet(isPresented: $showingWorkoutLogger) {
            // Workout logging view (existing)
            Text("Workout Logger - To be implemented")
        }
        .sheet(isPresented: $showingWeightLogger) {
            // Weight logging view (existing)
            Text("Weight Logger - To be implemented")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Constants.Colors.primaryBlue.opacity(0.2),
                                Constants.Colors.primaryBlue.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Constants.Colors.primaryBlue)
            }
            
            Text("Smart Logging")
                .font(Constants.Typography.title)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.textDark)
            
            Text("Use AI-powered analysis to track your meals and activities")
                .font(Constants.Typography.body)
                .foregroundColor(Constants.Colors.textLight)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Constants.Spacing.large)
    }
    
    private var smartMealSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            // Featured smart meal button
            Button(action: {
                showingSmartCamera = true
            }) {
                VStack(spacing: Constants.Spacing.medium) {
                    HStack {
                        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .foregroundColor(Constants.Colors.successGreen)
                                
                                Text("Smart Meal Analysis")
                                    .font(Constants.Typography.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.Colors.textDark)
                                
                                Spacer()
                                
                                Image(systemName: "sparkles")
                                    .font(.title3)
                                    .foregroundColor(Constants.Colors.warningOrange)
                            }
                            
                            Text("Take a photo and get instant nutrition analysis")
                                .font(Constants.Typography.body)
                                .foregroundColor(Constants.Colors.textLight)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                    }
                    
                    // AI Features showcase
                    HStack(spacing: Constants.Spacing.medium) {
                        LogFeatureBadge(
                            icon: "brain",
                            text: "AI Analysis",
                            color: .purple
                        )
                        
                        LogFeatureBadge(
                            icon: "timer",
                            text: "Quick Log",
                            color: .blue
                        )
                        
                        LogFeatureBadge(
                            icon: "chart.bar.fill",
                            text: "Analytics",
                            color: .green
                        )
                        
                        Spacer()
                    }
                }
                .padding(Constants.Spacing.large)
                .background(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(Constants.Colors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Constants.Colors.successGreen.opacity(0.3),
                                            Constants.Colors.primaryBlue.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            HStack {
                Text("Other Activities")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
            }
            
            HStack(spacing: Constants.Spacing.medium) {
                // Workout button
                Button(action: {
                    showingWorkoutLogger = true
                }) {
                    QuickActionCard(
                        title: "Log Workout",
                        subtitle: "Track exercise",
                        icon: "figure.run",
                        color: Constants.Colors.primaryBlue
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Weight button
                Button(action: {
                    showingWeightLogger = true
                }) {
                    QuickActionCard(
                        title: "Log Weight",
                        subtitle: "Track progress",
                        icon: "scalemass.fill",
                        color: Constants.Colors.warningOrange
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var todaysSummarySection: some View {
        let todaysNutrition = mealAnalysisManager.getTotalNutritionForToday()
        let todaysMeals = mealAnalysisManager.getMealsForToday()
        
        return VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Today's Summary")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Text("\(todaysMeals.count) meals logged")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            // Nutrition summary cards
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Constants.Spacing.medium) {
                SummaryCard(
                    title: "Calories",
                    value: "\(Int(todaysNutrition.calories))",
                    unit: "kcal",
                    color: Constants.Colors.warningOrange
                )
                
                SummaryCard(
                    title: "Protein",
                    value: todaysNutrition.formatted(todaysNutrition.protein),
                    unit: "g",
                    color: Constants.Colors.primaryBlue
                )
            }
        }
    }
    
    private var recentMealsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Recent Meals")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to meal history
                }
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            
            VStack(spacing: Constants.Spacing.small) {
                ForEach(mealAnalysisManager.getMealsForToday().prefix(3)) { meal in
                    MealLogItem(meal: meal)
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct LogFeatureBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Constants.Spacing.small) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(text)
                .font(Constants.Typography.small)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.horizontal, Constants.Spacing.small)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(Constants.cornerRadius / 2)
    }
}

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Constants.Spacing.small) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(Constants.Typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textDark)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            Text(title)
                .font(Constants.Typography.body)
                .fontWeight(.medium)
                .foregroundColor(Constants.Colors.textDark)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(Constants.Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(Constants.Typography.caption)
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct MealLogItem: View {
    let meal: SavedMeal
    
    var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            // Meal image or icon
            if let imageData = meal.image, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(Constants.cornerRadius)
                    .clipped()
            } else {
                Circle()
                    .fill(meal.mealType.color.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: meal.mealType.icon)
                            .font(.title3)
                            .foregroundColor(meal.mealType.color)
                    )
            }
            
            // Meal info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(Constants.Typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textDark)
                
                Text("\(meal.mealType.rawValue) • \(Int(meal.totalNutrition.calories)) calories")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Spacer()
            
            // Time
            Text(DateFormatter.timeFormatter.string(from: meal.timestamp))
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.textLight)
        }
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Simple Logger Views
struct MealLoggerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var mealName = ""
    @State private var calories = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: Constants.Spacing.large) {
                Text("Log Meal")
                    .font(Constants.Typography.title)
                    .fontWeight(.bold)
                    .padding(.top, Constants.Spacing.large)
                
                VStack(spacing: Constants.Spacing.medium) {
                    CustomTextField(title: "Meal Name", text: $mealName, placeholder: "e.g., Chicken Salad")
                    CustomTextField(title: "Calories", text: $calories, keyboardType: .numberPad, placeholder: "e.g., 450")
                }
                .padding(.horizontal, Constants.Spacing.large)
                
                Spacer()
                
                VStack(spacing: Constants.Spacing.medium) {
                    CustomButton(
                        title: "Save Meal",
                        action: {
                            // TODO: Save meal logic
                            dismiss()
                        },
                        isEnabled: !mealName.isEmpty && !calories.isEmpty
                    )
                    
                    CustomButton(
                        title: "Cancel",
                        action: {
                            dismiss()
                        },
                        style: .secondary
                    )
                }
                .padding(.horizontal, Constants.Spacing.large)
                .padding(.bottom, Constants.Spacing.extraLarge)
            }
            .background(Constants.Colors.backgroundGray)
        }
    }
}

struct WorkoutLoggerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var workoutType = ""
    @State private var duration = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: Constants.Spacing.large) {
                Text("Log Workout")
                    .font(Constants.Typography.title)
                    .fontWeight(.bold)
                    .padding(.top, Constants.Spacing.large)
                
                VStack(spacing: Constants.Spacing.medium) {
                    CustomTextField(title: "Workout Type", text: $workoutType, placeholder: "e.g., Running")
                    CustomTextField(title: "Duration (minutes)", text: $duration, keyboardType: .numberPad, placeholder: "e.g., 30")
                }
                .padding(.horizontal, Constants.Spacing.large)
                
                Spacer()
                
                VStack(spacing: Constants.Spacing.medium) {
                    CustomButton(
                        title: "Save Workout",
                        action: {
                            // TODO: Save workout logic
                            dismiss()
                        },
                        isEnabled: !workoutType.isEmpty && !duration.isEmpty
                    )
                    
                    CustomButton(
                        title: "Cancel",
                        action: {
                            dismiss()
                        },
                        style: .secondary
                    )
                }
                .padding(.horizontal, Constants.Spacing.large)
                .padding(.bottom, Constants.Spacing.extraLarge)
            }
            .background(Constants.Colors.backgroundGray)
        }
    }
}

struct WeightLoggerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var weight = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: Constants.Spacing.large) {
                Text("Log Weight")
                    .font(Constants.Typography.title)
                    .fontWeight(.bold)
                    .padding(.top, Constants.Spacing.large)
                
                VStack(spacing: Constants.Spacing.medium) {
                    CustomTextField(title: "Weight (kg)", text: $weight, keyboardType: .decimalPad, placeholder: "e.g., 75.2")
                }
                .padding(.horizontal, Constants.Spacing.large)
                
                Spacer()
                
                VStack(spacing: Constants.Spacing.medium) {
                    CustomButton(
                        title: "Save Weight",
                        action: {
                            // TODO: Save weight logic
                            dismiss()
                        },
                        isEnabled: !weight.isEmpty
                    )
                    
                    CustomButton(
                        title: "Cancel",
                        action: {
                            dismiss()
                        },
                        style: .secondary
                    )
                }
                .padding(.horizontal, Constants.Spacing.large)
                .padding(.bottom, Constants.Spacing.extraLarge)
            }
            .background(Constants.Colors.backgroundGray)
        }
    }
}
