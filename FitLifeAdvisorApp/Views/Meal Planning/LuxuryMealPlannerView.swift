//
//  LuxuryMealPlannerView.swift
//  FitLifeAdvisorApp
//
//  Smart meal planner with AI-powered generation and grocery list management
//

import SwiftUI

struct LuxuryMealPlannerView: View {
    @StateObject private var mealPlanManager = MealPlanManager.shared
    @State private var selectedGoal: NutritionGoal = .balanced
    @State private var selectedDifficulty: MealPlan.DifficultyLevel = .intermediate
    @State private var planDuration = 7
    @State private var targetCalories: String = ""
    @State private var dietaryRestrictions: [String] = []
    @State private var dislikedIngredients: [String] = []
    @State private var showingGenerationSheet = false
    @State private var showingGroceryList = false
    @State private var showingMealPlanDetails = false
    @State private var selectedDayPlan: DailyMealPlan?
    
    // Animation states
    @State private var animateCard = false
    @State private var showProgress = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                headerSection
                
                if mealPlanManager.isGenerating {
                    generationProgressView
                } else if let currentPlan = mealPlanManager.currentMealPlan {
                    currentMealPlanView(currentPlan)
                } else {
                    createNewPlanView
                }
                
                if let groceryList = mealPlanManager.currentGroceryList {
                    groceryListPreview(groceryList)
                }
                
                savedPlansSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "F8F9FF"), Color(hex: "E8EFFF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showingGenerationSheet) {
            mealPlanGenerationSheet
        }
        .sheet(isPresented: $showingGroceryList) {
            if let groceryList = mealPlanManager.currentGroceryList {
                GroceryListView(groceryList: groceryList)
            }
        }
        .sheet(isPresented: $showingMealPlanDetails) {
            if let plan = mealPlanManager.currentMealPlan {
                MealPlanDetailsView(mealPlan: plan)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateCard = true
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Smart Meal Planner")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("AI-powered nutrition planning")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingGenerationSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(animateCard ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateCard)
            }
            
            // Quick Stats
            if let currentPlan = mealPlanManager.currentMealPlan {
                quickStatsView(currentPlan)
            }
        }
        .padding(.horizontal, 5)
    }
    
    private func quickStatsView(_ plan: MealPlan) -> some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Daily Calories",
                value: String(format: "%.0f", plan.totalNutrition.averageDailyCalories),
                subtitle: "avg",
                color: Color(hex: "FF6B6B")
            )
            
            StatCard(
                title: "Grocery Cost",
                value: "LKR \(String(format: "%.0f", plan.estimatedCost))",
                subtitle: "\(plan.dailyPlans.count) days",
                color: Color(hex: "4ECDC4")
            )
            
            StatCard(
                title: "Adherence",
                value: "\(String(format: "%.0f", plan.totalNutrition.weeklyGoalAdherence))%",
                subtitle: "to goals",
                color: Color(hex: "45B7D1")
            )
        }
        .scaleEffect(animateCard ? 1.0 : 0.9)
        .opacity(animateCard ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.3), value: animateCard)
    }
    
    // MARK: - Generation Progress View
    
    private var generationProgressView: some View {
        VStack(spacing: 20) {
            LottieView(name: "cooking_animation")
                .frame(width: 120, height: 120)
            
            VStack(spacing: 12) {
                Text("Creating Your Perfect Meal Plan")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "2C3E50"))
                
                Text("Analyzing your preferences and nutritional needs...")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Progress Bar
                ProgressView(value: mealPlanManager.generationProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "4A90E2")))
                    .scaleEffect(y: 2.0)
                    .frame(width: 250)
                
                Text("\(Int(mealPlanManager.generationProgress * 100))% Complete")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "4A90E2"))
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Current Meal Plan View
    
    private func currentMealPlanView(_ plan: MealPlan) -> some View {
        VStack(spacing: 20) {
            // Plan Header
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(plan.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "2C3E50"))
                        
                        Text(plan.description)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text(plan.goalType.emoji)
                            .font(.system(size: 40))
                        
                        Text(plan.difficultyLevel.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "4A90E2"))
                    }
                }
                
                // Duration and dates
                HStack {
                    Label("\(plan.dailyPlans.count) Days", systemImage: "calendar")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(plan.startDate.formatted(date: .abbreviated, time: .omitted)) - \(plan.endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            
            // Daily Plans Preview
            dailyPlansScrollView(plan.dailyPlans)
            
            // Action Buttons
            HStack(spacing: 15) {
                Button(action: {
                    showingMealPlanDetails = true
                }) {
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                        Text("View Details")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                Button(action: {
                    showingGroceryList = true
                }) {
                    HStack {
                        Image(systemName: "cart")
                        Text("Shopping List")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "4A90E2"))
                    .padding(.horizontal, 25)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(hex: "4A90E2"), lineWidth: 2)
                    )
                }
            }
        }
        .scaleEffect(animateCard ? 1.0 : 0.95)
        .opacity(animateCard ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: animateCard)
    }
    
    // MARK: - Create New Plan View
    
    private var createNewPlanView: some View {
        VStack(spacing: 25) {
            // Illustration
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 20)
            
            VStack(spacing: 12) {
                Text("Create Your First Meal Plan")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "2C3E50"))
                    .multilineTextAlignment(.center)
                
                Text("Let AI create personalized meal plans based on your goals, preferences, and dietary requirements.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
            
            // Features List
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "brain", title: "Smart Meal Generation", description: "AI-powered meal selection")
                FeatureRow(icon: "cart", title: "Auto Grocery Lists", description: "Organized shopping lists")
                FeatureRow(icon: "target", title: "Goal-Based Planning", description: "Personalized for your fitness goals")
                FeatureRow(icon: "leaf", title: "Dietary Preferences", description: "Supports all dietary restrictions")
            }
            .padding(.horizontal, 20)
            
            // CTA Button
            Button(action: {
                showingGenerationSheet = true
            }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate My Meal Plan")
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color(hex: "4A90E2").opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .scaleEffect(animateCard ? 1.0 : 0.9)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateCard)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
        )
        .scaleEffect(animateCard ? 1.0 : 0.95)
        .opacity(animateCard ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.8), value: animateCard)
    }
    
    // MARK: - Daily Plans Scroll View
    
    private func dailyPlansScrollView(_ dailyPlans: [DailyMealPlan]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(dailyPlans) { dayPlan in
                    DayPlanCard(dayPlan: dayPlan) {
                        selectedDayPlan = dayPlan
                        showingMealPlanDetails = true
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Grocery List Preview
    
    private func groceryListPreview(_ groceryList: GroceryList) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "cart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "4A90E2"))
                
                Text("Shopping List")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "2C3E50"))
                
                Spacer()
                
                Button(action: {
                    showingGroceryList = true
                }) {
                    Text("View All")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "4A90E2"))
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(groceryList.checkedOffCount) of \(groceryList.items.count) items")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.0f", groceryList.completionPercentage))% Complete")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "4ECDC4"))
                }
                
                ProgressView(value: groceryList.completionPercentage / 100.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "4ECDC4")))
                    .scaleEffect(y: 1.5)
            }
            
            // Quick preview of items
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                ForEach(Array(groceryList.items.prefix(4)), id: \.id) { item in
                    HStack {
                        Text(item.category.emoji)
                            .font(.system(size: 16))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                            
                            Text(item.displayAmount)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if item.isCheckedOff {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "4ECDC4"))
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "F8F9FF"))
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Saved Plans Section
    
    private var savedPlansSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Previous Meal Plans")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "2C3E50"))
                .padding(.horizontal, 5)
            
            if mealPlanManager.savedMealPlans.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No Saved Plans",
                    description: "Your meal plan history will appear here"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(mealPlanManager.savedMealPlans.suffix(5).reversed(), id: \.id) { plan in
                            SavedPlanCard(plan: plan) {
                                mealPlanManager.currentMealPlan = plan
                                mealPlanManager.currentGroceryList = plan.groceryList
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - Meal Plan Generation Sheet
    
    private var mealPlanGenerationSheet: some View {
        NavigationView {
            MealPlanGenerationView(
                selectedGoal: $selectedGoal,
                selectedDifficulty: $selectedDifficulty,
                planDuration: $planDuration,
                targetCalories: $targetCalories,
                dietaryRestrictions: $dietaryRestrictions,
                dislikedIngredients: $dislikedIngredients
            ) {
                // On generate action
                Task {
                    let calories = Double(targetCalories) ?? 0
                    await mealPlanManager.generateMealPlan(
                        goal: selectedGoal,
                        duration: planDuration,
                        difficulty: selectedDifficulty,
                        dietaryRestrictions: dietaryRestrictions,
                        dislikedIngredients: dislikedIngredients,
                        targetCalories: calories > 0 ? calories : nil
                    )
                }
                showingGenerationSheet = false
            }
            .navigationTitle("Create Meal Plan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingGenerationSheet = false
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "4A90E2"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "2C3E50"))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct DayPlanCard: View {
    let dayPlan: DailyMealPlan
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dayPlan.dayOfWeek)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "2C3E50"))
                        
                        Text(dayPlan.shortDate)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    MealPreview(name: dayPlan.breakfast.name, type: "Breakfast", emoji: "🌅")
                    MealPreview(name: dayPlan.lunch.name, type: "Lunch", emoji: "🌞")
                    MealPreview(name: dayPlan.dinner.name, type: "Dinner", emoji: "🌙")
                }
                
                HStack {
                    Label("\(String(format: "%.0f", dayPlan.dailyCalories)) cal", systemImage: "flame")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "FF6B6B"))
                    
                    Spacer()
                    
                    Label("\(String(format: "%.0f", dayPlan.mealPrepTime / 60)) min", systemImage: "clock")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(15)
            .frame(width: 200)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MealPreview: View {
    let name: String
    let type: String
    let emoji: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 14))
            
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "2C3E50"))
                    .lineLimit(1)
                
                Text(type)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct SavedPlanCard: View {
    let plan: MealPlan
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(plan.goalType.emoji)
                        .font(.system(size: 24))
                    
                    Spacer()
                    
                    Text(plan.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "2C3E50"))
                        .lineLimit(1)
                    
                    Text("\(plan.dailyPlans.count) days • \(plan.difficultyLevel.rawValue)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("LKR \(String(format: "%.0f", plan.estimatedCost))")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "4ECDC4"))
                    
                    Spacer()
                    
                    Text("\(String(format: "%.0f", plan.totalNutrition.averageDailyCalories)) cal/day")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            VStack(spacing: 5) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "2C3E50"))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(hex: "F8F9FF"))
        )
    }
}

// MARK: - Preview

#Preview {
    LuxuryMealPlannerView()
}
