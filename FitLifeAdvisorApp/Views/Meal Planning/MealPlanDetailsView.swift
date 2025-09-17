//
//  MealPlanDetailsView.swift
//  FitLifeAdvisorApp
//
//  Comprehensive meal plan details with nutrition insights
//

import SwiftUI

struct MealPlanDetailsView: View {
    let mealPlan: MealPlan
    @State private var selectedDay: DailyMealPlan?
    @State private var selectedTab = 0
    @State private var animateContent = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Bar
                tabBarView
                
                TabView(selection: $selectedTab) {
                    // Overview Tab
                    overviewTab
                        .tag(0)
                    
                    // Daily Plans Tab
                    dailyPlansTab
                        .tag(1)
                    
                    // Nutrition Tab
                    nutritionTab
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "F8F9FF"), Color(hex: "E8EFFF")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Meal Plan Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateContent = true
                }
            }
            .sheet(item: $selectedDay) { dayPlan in
                DayPlanDetailView(dayPlan: dayPlan)
            }
        }
    }
    
    // MARK: - Tab Bar
    
    private var tabBarView: some View {
        HStack(spacing: 0) {
            TabBarItem(title: "Overview", icon: "chart.bar.fill", isSelected: selectedTab == 0) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }
            
            TabBarItem(title: "Daily Plans", icon: "calendar", isSelected: selectedTab == 1) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }
            
            TabBarItem(title: "Nutrition", icon: "heart.fill", isSelected: selectedTab == 2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedTab = 2
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Overview Tab
    
    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Plan Header
                planHeaderSection
                
                // Quick Stats
                quickStatsSection
                
                // Goal Achievement
                goalAchievementSection
                
                // Cost Breakdown
                costBreakdownSection
            }
            .padding(20)
        }
        .scaleEffect(animateContent ? 1.0 : 0.95)
        .opacity(animateContent ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6), value: animateContent)
    }
    
    // MARK: - Daily Plans Tab
    
    private var dailyPlansTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(mealPlan.dailyPlans, id: \.id) { dayPlan in
                    DailyPlanCard(dayPlan: dayPlan) {
                        selectedDay = dayPlan
                    }
                }
            }
            .padding(20)
        }
        .scaleEffect(animateContent ? 1.0 : 0.95)
        .opacity(animateContent ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: animateContent)
    }
    
    // MARK: - Nutrition Tab
    
    private var nutritionTab: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Weekly Nutrition Summary
                weeklyNutritionSection
                
                // Macro Distribution
                macroDistributionSection
                
                // Daily Averages
                dailyAveragesSection
            }
            .padding(20)
        }
        .scaleEffect(animateContent ? 1.0 : 0.95)
        .opacity(animateContent ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateContent)
    }
    
    // MARK: - Plan Header Section
    
    private var planHeaderSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(mealPlan.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "2C3E50"))
                    
                    Text(mealPlan.description)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text(mealPlan.goalType.emoji)
                        .font(.system(size: 50))
                    
                    Text(mealPlan.goalType.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "4A90E2"))
                        .multilineTextAlignment(.center)
                }
            }
            
            // Plan Details
            VStack(spacing: 12) {
                DetailRow(
                    icon: "calendar",
                    title: "Duration",
                    value: "\(mealPlan.dailyPlans.count) days"
                )
                
                DetailRow(
                    icon: "chef.hat",
                    title: "Difficulty",
                    value: mealPlan.difficultyLevel.rawValue
                )
                
                DetailRow(
                    icon: "clock",
                    title: "Created",
                    value: mealPlan.createdAt.formatted(date: .abbreviated, time: .shortened)
                )
                
                DetailRow(
                    icon: "calendar.badge.clock",
                    title: "Period",
                    value: "\(mealPlan.startDate.formatted(date: .abbreviated, time: .omitted)) - \(mealPlan.endDate.formatted(date: .abbreviated, time: .omitted))"
                )
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Quick Stats Section
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Plan Overview")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "2C3E50"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                StatCard(
                    icon: "flame.fill",
                    title: "Avg Daily Calories",
                    value: String(format: "%.0f", mealPlan.totalNutrition.averageDailyCalories),
                    subtitle: "per day",
                    color: Color(hex: "FF6B6B")
                )
                
                StatCard(
                    icon: "dollarsign.circle.fill",
                    title: "Total Cost",
                    value: "LKR \(String(format: "%.0f", mealPlan.estimatedCost))",
                    subtitle: "\(mealPlan.dailyPlans.count) days",
                    color: Color(hex: "4ECDC4")
                )
                
                StatCard(
                    icon: "target",
                    title: "Goal Adherence",
                    value: "\(String(format: "%.0f", mealPlan.totalNutrition.weeklyGoalAdherence))%",
                    subtitle: "to targets",
                    color: Color(hex: "45B7D1")
                )
                
                StatCard(
                    icon: "cart.fill",
                    title: "Grocery Items",
                    value: "\(mealPlan.groceryList.items.count)",
                    subtitle: "to buy",
                    color: Color(hex: "A78BFA")
                )
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Goal Achievement Section
    
    private var goalAchievementSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Goal Achievement")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "2C3E50"))
            
            VStack(spacing: 15) {
                GoalProgressBar(
                    title: "Calorie Target",
                    current: mealPlan.totalNutrition.averageDailyCalories,
                    target: 2000, // This would come from user preferences
                    unit: "cal",
                    color: Color(hex: "FF6B6B")
                )
                
                GoalProgressBar(
                    title: "Protein Intake",
                    current: mealPlan.totalNutrition.totalProtein / Double(mealPlan.dailyPlans.count),
                    target: 150, // This would come from user preferences
                    unit: "g",
                    color: Color(hex: "4ECDC4")
                )
                
                GoalProgressBar(
                    title: "Weekly Budget",
                    current: mealPlan.estimatedCost,
                    target: 5000, // This would come from user preferences
                    unit: "LKR",
                    color: Color(hex: "A78BFA")
                )
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Cost Breakdown Section
    
    private var costBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cost Analysis")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "2C3E50"))
            
            VStack(spacing: 15) {
                CostDetailRow(
                    title: "Per Day",
                    amount: mealPlan.estimatedCost / Double(mealPlan.dailyPlans.count),
                    icon: "calendar"
                )
                
                CostDetailRow(
                    title: "Per Meal",
                    amount: mealPlan.estimatedCost / Double(mealPlan.dailyPlans.count * 3),
                    icon: "fork.knife"
                )
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Weekly Nutrition Section
    
    private var weeklyNutritionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Weekly Nutrition Summary")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "2C3E50"))
            
            VStack(spacing: 15) {
                NutritionSummaryRow(
                    title: "Total Calories",
                    value: String(format: "%.0f", mealPlan.totalNutrition.totalCalories),
                    subtitle: "for \(mealPlan.dailyPlans.count) days",
                    color: Color(hex: "FF6B6B")
                )
                
                NutritionSummaryRow(
                    title: "Total Protein",
                    value: "\(String(format: "%.0f", mealPlan.totalNutrition.totalProtein))g",
                    subtitle: "avg \(String(format: "%.0f", mealPlan.totalNutrition.totalProtein / Double(mealPlan.dailyPlans.count)))g/day",
                    color: Color(hex: "4ECDC4")
                )
                
                NutritionSummaryRow(
                    title: "Total Carbs",
                    value: "\(String(format: "%.0f", mealPlan.totalNutrition.totalCarbs))g",
                    subtitle: "avg \(String(format: "%.0f", mealPlan.totalNutrition.totalCarbs / Double(mealPlan.dailyPlans.count)))g/day",
                    color: Color(hex: "45B7D1")
                )
                
                NutritionSummaryRow(
                    title: "Total Fat",
                    value: "\(String(format: "%.0f", mealPlan.totalNutrition.totalFat))g",
                    subtitle: "avg \(String(format: "%.0f", mealPlan.totalNutrition.totalFat / Double(mealPlan.dailyPlans.count)))g/day",
                    color: Color(hex: "A78BFA")
                )
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Macro Distribution Section
    
    private var macroDistributionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Macro Distribution")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "2C3E50"))
            
            HStack(spacing: 20) {
                MacroCircle(
                    title: "Protein",
                    percentage: mealPlan.totalNutrition.averageMacros.proteinPercent,
                    color: Color(hex: "4ECDC4")
                )
                
                MacroCircle(
                    title: "Carbs",
                    percentage: mealPlan.totalNutrition.averageMacros.carbPercent,
                    color: Color(hex: "45B7D1")
                )
                
                MacroCircle(
                    title: "Fat",
                    percentage: mealPlan.totalNutrition.averageMacros.fatPercent,
                    color: Color(hex: "A78BFA")
                )
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Daily Averages Section
    
    private var dailyAveragesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Daily Averages")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "2C3E50"))
            
            VStack(spacing: 12) {
                DailyAverageRow(
                    title: "Calories",
                    value: String(format: "%.0f", mealPlan.totalNutrition.averageDailyCalories),
                    unit: "cal",
                    color: Color(hex: "FF6B6B")
                )
                
                DailyAverageRow(
                    title: "Protein",
                    value: String(format: "%.1f", mealPlan.totalNutrition.totalProtein / Double(mealPlan.dailyPlans.count)),
                    unit: "g",
                    color: Color(hex: "4ECDC4")
                )
                
                DailyAverageRow(
                    title: "Carbohydrates",
                    value: String(format: "%.1f", mealPlan.totalNutrition.totalCarbs / Double(mealPlan.dailyPlans.count)),
                    unit: "g",
                    color: Color(hex: "45B7D1")
                )
                
                DailyAverageRow(
                    title: "Fat",
                    value: String(format: "%.1f", mealPlan.totalNutrition.totalFat / Double(mealPlan.dailyPlans.count)),
                    unit: "g",
                    color: Color(hex: "A78BFA")
                )
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Supporting Views

struct TabBarItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isSelected ? Color(hex: "4A90E2") : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: "4A90E2").opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "4A90E2"))
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "2C3E50"))
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "2C3E50"))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(color)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.1))
        )
    }
}

struct GoalProgressBar: View {
    let title: String
    let current: Double
    let target: Double
    let unit: String
    let color: Color
    
    private var progress: Double {
        min(current / target, 1.0)
    }
    
    private var isOverTarget: Bool {
        current > target
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "2C3E50"))
                
                Spacer()
                
                Text("\(String(format: "%.0f", current)) / \(String(format: "%.0f", target)) \(unit)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isOverTarget ? Color(hex: "FF6B6B") : color)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: isOverTarget ? Color(hex: "FF6B6B") : color))
                .scaleEffect(y: 1.5)
            
            Text("\(String(format: "%.0f", progress * 100))% of target")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

struct CostDetailRow: View {
    let title: String
    let amount: Double
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "4A90E2"))
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "2C3E50"))
            
            Spacer()
            
            Text("LKR \(String(format: "%.0f", amount))")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "4ECDC4"))
        }
        .padding(.vertical, 4)
    }
}

struct NutritionSummaryRow: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "2C3E50"))
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.vertical, 6)
    }
}

struct MacroCircle: View {
    let title: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: percentage / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text("\(String(format: "%.0f", percentage))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }
            .frame(width: 80, height: 80)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "2C3E50"))
        }
    }
}

struct DailyAverageRow: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "2C3E50"))
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

struct DailyPlanCard: View {
    let dayPlan: DailyMealPlan
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 15) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dayPlan.dayOfWeek)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "2C3E50"))
                        
                        Text(dayPlan.shortDate)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(String(format: "%.0f", dayPlan.dailyCalories)) cal")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "FF6B6B"))
                        
                        Text("\(String(format: "%.0f", dayPlan.mealPrepTime / 60)) min prep")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Meals Preview
                VStack(spacing: 8) {
                    MealPreviewRow(meal: dayPlan.breakfast, emoji: "🌅")
                    MealPreviewRow(meal: dayPlan.lunch, emoji: "🌞")
                    MealPreviewRow(meal: dayPlan.dinner, emoji: "🌙")
                    
                    if !dayPlan.snacks.isEmpty {
                        HStack {
                            Text("🍎")
                                .font(.system(size: 14))
                            
                            Text("\(dayPlan.snacks.count) snacks")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MealPreviewRow: View {
    let meal: PlannedMeal
    let emoji: String
    
    var body: some View {
        HStack {
            Text(emoji)
                .font(.system(size: 14))
            
            Text(meal.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "2C3E50"))
                .lineLimit(1)
            
            Spacer()
            
            Text("\(String(format: "%.0f", meal.nutrition.calories)) cal")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Day Plan Detail View

struct DayPlanDetailView: View {
    let dayPlan: DailyMealPlan
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Day Header
                    dayHeaderSection
                    
                    // Meals
                    mealsSection
                    
                    // Nutrition Summary
                    nutritionSummarySection
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "F8F9FF"), Color(hex: "E8EFFF")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle(dayPlan.dayOfWeek)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var dayHeaderSection: some View {
        VStack(spacing: 15) {
            Text(dayPlan.date.formatted(date: .complete, time: .omitted))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("\(String(format: "%.0f", dayPlan.dailyCalories))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "FF6B6B"))
                    
                    Text("Calories")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(String(format: "%.0f", dayPlan.mealPrepTime / 60))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "4A90E2"))
                    
                    Text("Minutes")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(3 + dayPlan.snacks.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "4ECDC4"))
                    
                    Text("Meals")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
    
    private var mealsSection: some View {
        VStack(spacing: 20) {
            MealCard(meal: dayPlan.breakfast, mealType: "Breakfast", emoji: "🌅")
            MealCard(meal: dayPlan.lunch, mealType: "Lunch", emoji: "🌞")
            MealCard(meal: dayPlan.dinner, mealType: "Dinner", emoji: "🌙")
            
            if !dayPlan.snacks.isEmpty {
                VStack(spacing: 15) {
                    ForEach(Array(dayPlan.snacks.enumerated()), id: \.element.id) { index, snack in
                        MealCard(meal: snack, mealType: "Snack \(index + 1)", emoji: "🍎")
                    }
                }
            }
        }
    }
    
    private var nutritionSummarySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Nutrition Summary")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "2C3E50"))
            
            VStack(spacing: 12) {
                NutritionRow(title: "Protein", value: dayPlan.dailyNutrition.protein, unit: "g", color: Color(hex: "4ECDC4"))
                NutritionRow(title: "Carbohydrates", value: dayPlan.dailyNutrition.carbs, unit: "g", color: Color(hex: "45B7D1"))
                NutritionRow(title: "Fat", value: dayPlan.dailyNutrition.fat, unit: "g", color: Color(hex: "A78BFA"))
                NutritionRow(title: "Fiber", value: dayPlan.dailyNutrition.fiber, unit: "g", color: Color(hex: "4CAF50"))
                NutritionRow(title: "Sugar", value: dayPlan.dailyNutrition.sugar, unit: "g", color: Color(hex: "FF9800"))
                NutritionRow(title: "Sodium", value: dayPlan.dailyNutrition.sodium, unit: "mg", color: Color(hex: "F44336"))
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
}

struct MealCard: View {
    let meal: PlannedMeal
    let mealType: String
    let emoji: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Meal Header
            HStack {
                HStack(spacing: 8) {
                    Text(emoji)
                        .font(.system(size: 20))
                    
                    Text(mealType)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "2C3E50"))
                }
                
                Spacer()
                
                Text("\(String(format: "%.0f", meal.nutrition.calories)) cal")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "FF6B6B"))
            }
            
            // Meal Name and Description
            VStack(alignment: .leading, spacing: 6) {
                Text(meal.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "2C3E50"))
                
                Text(meal.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            // Quick Nutrition
            HStack(spacing: 20) {
                NutritionBadge(title: "P", value: meal.nutrition.protein, color: Color(hex: "4ECDC4"))
                NutritionBadge(title: "C", value: meal.nutrition.carbs, color: Color(hex: "45B7D1"))
                NutritionBadge(title: "F", value: meal.nutrition.fat, color: Color(hex: "A78BFA"))
                
                Spacer()
                
                Text(meal.formattedTime)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
    }
}

struct NutritionRow: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "2C3E50"))
            
            Spacer()
            
            Text("\(String(format: "%.1f", value)) \(unit)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

struct NutritionBadge: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color)
            
            Text("\(String(format: "%.0f", value))g")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "2C3E50"))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Preview

#Preview {
    let sampleMealPlan = MealPlan(
        name: "Weight Loss Plan",
        description: "7-day balanced meal plan for healthy weight loss",
        goalType: .weightLoss,
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 6, to: Date()) ?? Date(),
        dailyPlans: [],
        totalNutrition: WeeklyNutritionSummary(
            totalCalories: 10500,
            averageDailyCalories: 1500,
            totalProtein: 700,
            totalCarbs: 1050,
            totalFat: 350,
            averageMacros: MacroTargets(proteinPercent: 25, carbPercent: 40, fatPercent: 35, calorieMultiplier: 0.8),
            micronutrients: [:],
            weeklyGoalAdherence: 87.5
        ),
        groceryList: GroceryList(items: [], totalEstimatedCost: 3500, createdAt: Date()),
        estimatedCost: 3500,
        difficultyLevel: .intermediate,
        createdAt: Date()
    )
    
    MealPlanDetailsView(mealPlan: sampleMealPlan)
}
