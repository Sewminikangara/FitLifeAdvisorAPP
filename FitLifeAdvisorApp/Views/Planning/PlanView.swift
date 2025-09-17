//
//  PlanView.swift
//  FitLifeAdvisorApp
//
//  Modern Planning Interface with beautiful UI and enhanced user experience
//

import SwiftUI

struct PlanView: View {
    @State private var selectedTab: PlanTab = .meals
    @State private var showingMealPlan = false
    @State private var showingWorkoutPlan = false
    @State private var animateContent = false
    
    enum PlanTab: String, CaseIterable {
        case meals = "Meals"
        case workouts = "Workouts"
        
        var icon: String {
            switch self {
            case .meals: return "fork.knife.circle.fill"
            case .workouts: return "figure.run.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .meals: return Constants.Colors.successGreen
            case .workouts: return Constants.Colors.primaryBlue
            }
        }
    }
    
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
                        // Hero Section
                        VStack(spacing: Constants.Spacing.medium) {
                            ZStack {
                                Circle()
                                    .fill(selectedTab.color.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                                
                                Image(systemName: selectedTab.icon)
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(selectedTab.color)
                                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                            }
                            
                            Text("Smart Planning")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Constants.Colors.textDark)
                            
                            Text("Plan your meals and workouts for optimal results")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textLight)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Constants.Spacing.large)
                        }
                        .padding(.top, Constants.Spacing.large)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6), value: animateContent)
                        
                        // Tab Selector
                        ModernTabSelector(selectedTab: $selectedTab)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.1), value: animateContent)
                        
                        // Content Based on Selected Tab
                        Group {
                            if selectedTab == .meals {
                                MealPlanningContent(showingMealPlan: $showingMealPlan)
                            } else {
                                WorkoutPlanningContent(showingWorkoutPlan: $showingWorkoutPlan)
                            }
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateContent)
                        
                        Spacer(minLength: Constants.Spacing.extraLarge)
                    }
                }
            }
            .navigationTitle("Planning")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                withAnimation {
                    animateContent = true
                }
            }
        }
        .sheet(isPresented: $showingMealPlan) {
            ModernMealPlannerView()
        }
        .sheet(isPresented: $showingWorkoutPlan) {
            ModernWorkoutPlannerView()
        }
    }
}

// MARK: - Modern Tab Selector
struct ModernTabSelector: View {
    @Binding var selectedTab: PlanView.PlanTab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(PlanView.PlanTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    HStack(spacing: Constants.Spacing.small) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(tab.rawValue)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(selectedTab == tab ? .white : tab.color)
                    .padding(.vertical, Constants.Spacing.medium)
                    .padding(.horizontal, Constants.Spacing.large)
                    .background(
                        ZStack {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(tab.color)
                                    .matchedGeometryEffect(id: "tab", in: animation)
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, Constants.Spacing.large)
    }
}

// MARK: - Meal Planning Content
struct MealPlanningContent: View {
    @Binding var showingMealPlan: Bool
    
    var body: some View {
        VStack(spacing: Constants.Spacing.large) {
            // Quick Actions
            VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                Text("Quick Meal Plans")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Constants.Colors.textDark)
                    .padding(.horizontal, Constants.Spacing.large)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Constants.Spacing.medium) {
                        QuickMealCard(
                            title: "Weight Loss",
                            subtitle: "1,200-1,500 cal",
                            icon: "chart.line.downtrend.xyaxis",
                            color: Constants.Colors.successGreen,
                            mealCount: "21 meals"
                        )
                        
                        QuickMealCard(
                            title: "Muscle Gain",
                            subtitle: "2,000-2,500 cal",
                            icon: "chart.line.uptrend.xyaxis",
                            color: Constants.Colors.primaryBlue,
                            mealCount: "28 meals"
                        )
                        
                        QuickMealCard(
                            title: "Maintenance",
                            subtitle: "1,800-2,000 cal",
                            icon: "equal.circle",
                            color: Constants.Colors.warningOrange,
                            mealCount: "21 meals"
                        )
                    }
                    .padding(.horizontal, Constants.Spacing.large)
                }
            }
            
            // Current Week Plan
            VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                HStack {
                    Text("This Week's Plan")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Spacer()
                    
                    Button(action: { showingMealPlan = true }) {
                        HStack(spacing: Constants.Spacing.small) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Plan")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.successGreen)
                    }
                }
                .padding(.horizontal, Constants.Spacing.large)
                
                VStack(spacing: Constants.Spacing.medium) {
                    ModernMealPlanItem(
                        day: "Today",
                        daySubtitle: "Monday",
                        breakfast: "Overnight Oats with Berries",
                        lunch: "Quinoa Buddha Bowl",
                        dinner: "Grilled Salmon & Veggies",
                        isToday: true
                    )
                    
                    ModernMealPlanItem(
                        day: "Tomorrow",
                        daySubtitle: "Tuesday",
                        breakfast: "Greek Yogurt Parfait",
                        lunch: "Chicken Caesar Salad",
                        dinner: "Stir-fry Vegetables with Tofu"
                    )
                    
                    ModernMealPlanItem(
                        day: "Wednesday",
                        daySubtitle: "",
                        breakfast: "Smoothie Bowl",
                        lunch: "Turkey Wrap",
                        dinner: "Lean Beef with Sweet Potato"
                    )
                }
            }
            
            // Nutrition Goals
            VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                Text("Today's Nutrition Goals")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Constants.Colors.textDark)
                    .padding(.horizontal, Constants.Spacing.large)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Constants.Spacing.medium), count: 2), spacing: Constants.Spacing.medium) {
                    NutritionGoalCard(
                        title: "Calories",
                        current: "1,247",
                        target: "1,500",
                        progress: 0.83,
                        color: Constants.Colors.successGreen,
                        icon: "flame.fill"
                    )
                    
                    NutritionGoalCard(
                        title: "Protein",
                        current: "82",
                        target: "120g",
                        progress: 0.68,
                        color: Constants.Colors.primaryBlue,
                        icon: "leaf.fill"
                    )
                    
                    NutritionGoalCard(
                        title: "Carbs",
                        current: "156",
                        target: "200g",
                        progress: 0.78,
                        color: Constants.Colors.warningOrange,
                        icon: "speedometer"
                    )
                    
                    NutritionGoalCard(
                        title: "Fats",
                        current: "45",
                        target: "67g",
                        progress: 0.67,
                        color: Constants.Colors.errorRed,
                        icon: "drop.fill"
                    )
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
}

// MARK: - Workout Planning Content
struct WorkoutPlanningContent: View {
    @Binding var showingWorkoutPlan: Bool
    
    var body: some View {
        VStack(spacing: Constants.Spacing.large) {
            // Quick Workout Types
            VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                Text("Workout Categories")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Constants.Colors.textDark)
                    .padding(.horizontal, Constants.Spacing.large)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Constants.Spacing.medium) {
                        PlanWorkoutTypeCard(
                            title: "Strength",
                            subtitle: "Build muscle",
                            icon: "dumbbell.fill",
                            color: Constants.Colors.primaryBlue,
                            sessionCount: "12 sessions"
                        )
                        
                        PlanWorkoutTypeCard(
                            title: "Cardio",
                            subtitle: "Burn calories",
                            icon: "heart.fill",
                            color: Constants.Colors.errorRed,
                            sessionCount: "8 sessions"
                        )
                        
                        PlanWorkoutTypeCard(
                            title: "Flexibility",
                            subtitle: "Improve mobility",
                            icon: "figure.yoga",
                            color: Constants.Colors.successGreen,
                            sessionCount: "6 sessions"
                        )
                    }
                    .padding(.horizontal, Constants.Spacing.large)
                }
            }
            
            // Current Week Plan
            VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                HStack {
                    Text("This Week's Plan")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Spacer()
                    
                    Button(action: { showingWorkoutPlan = true }) {
                        HStack(spacing: Constants.Spacing.small) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Workout")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.primaryBlue)
                    }
                }
                .padding(.horizontal, Constants.Spacing.large)
                
                VStack(spacing: Constants.Spacing.medium) {
                    ModernWorkoutPlanItem(
                        day: "Today",
                        daySubtitle: "Monday",
                        workout: "Upper Body Strength",
                        duration: "45 min",
                        difficulty: "Intermediate",
                        isToday: true
                    )
                    
                    ModernWorkoutPlanItem(
                        day: "Tomorrow",
                        daySubtitle: "Tuesday",
                        workout: "Cardio HIIT",
                        duration: "30 min",
                        difficulty: "Advanced"
                    )
                    
                    ModernWorkoutPlanItem(
                        day: "Wednesday",
                        daySubtitle: "",
                        workout: "Lower Body Strength",
                        duration: "50 min",
                        difficulty: "Intermediate"
                    )
                }
            }
            
            // Performance Tracking
            VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                Text("Performance Metrics")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Constants.Colors.textDark)
                    .padding(.horizontal, Constants.Spacing.large)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Constants.Spacing.medium), count: 2), spacing: Constants.Spacing.medium) {
                    PerformanceCard(
                        title: "Consistency",
                        current: "85%",
                        subtitle: "This month",
                        progress: 0.85,
                        color: Constants.Colors.successGreen,
                        icon: "calendar.badge.checkmark"
                    )
                    
                    PerformanceCard(
                        title: "Strength",
                        current: "+12%",
                        subtitle: "vs last month",
                        progress: 0.72,
                        color: Constants.Colors.primaryBlue,
                        icon: "arrow.up.right"
                    )
                    
                    PerformanceCard(
                        title: "Endurance",
                        current: "+8%",
                        subtitle: "improvement",
                        progress: 0.68,
                        color: Constants.Colors.warningOrange,
                        icon: "timer"
                    )
                    
                    PerformanceCard(
                        title: "Recovery",
                        current: "Good",
                        subtitle: "Heart rate variability",
                        progress: 0.75,
                        color: Constants.Colors.errorRed,
                        icon: "heart.text.square"
                    )
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
}

struct PlanWorkoutTypeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let sessionCount: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
                
                Text(sessionCount)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textSecondary)
            }
        }
        .padding(Constants.Spacing.medium)
        .frame(width: 140, height: 100)
        .background(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    PlanView()
}
