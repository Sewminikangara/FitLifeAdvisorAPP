//
//  LuxuryPlanView.swift
//  FitLifeAdvisorApp
//
//  Luxury Planning View with premium design
//

import SwiftUI

struct LuxuryPlanView: View {
    @State private var selectedTab: PlanningTab = .meals
    @State private var selectedWeek = Date()
    @State private var activeSheet: ActiveSheet?
    @State private var animateCards = false
    
    enum PlanningTab: String, CaseIterable {
        case meals = "Meals"
        case workouts = "Workouts"
        case goals = "Goals"
        
        var icon: String {
            switch self {
            case .meals: return "fork.knife"
            case .workouts: return "figure.strengthtraining.traditional"
            case .goals: return "target"
            }
        }
        
        var colors: [Color] {
            switch self {
            case .meals: return [LuxuryTheme.Colors.nutritionRed, LuxuryTheme.Colors.nutritionOrange]
            case .workouts: return [LuxuryTheme.Colors.workoutPurple, LuxuryTheme.Colors.workoutViolet]
            case .goals: return [LuxuryTheme.Colors.goldPrimary, LuxuryTheme.Colors.goldSecondary]
            }
        }
    }
    
    // Single sheet controller
    enum ActiveSheet: Identifiable {
        case mealPlanner, workoutPlanner, goalSetter
        var id: String {
            switch self { case .mealPlanner: return "mealPlanner"; case .workoutPlanner: return "workoutPlanner"; case .goalSetter: return "goalSetter" }
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
                        
                        // AI Planning Assistant
                        aiPlanningAssistantSection
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Planning Tab Selector
                        planningTabSelector
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Content Based on Selected Tab
                        selectedTabContent
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Quick Actions
                        quickPlanningActions
                            .padding(.horizontal, LuxuryTheme.Spacing.medium)
                            .padding(.top, LuxuryTheme.Spacing.xLarge)
                        
                        // Weekly Overview
                        weeklyOverviewSection
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
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .mealPlanner:
                LuxuryMealPlannerView()
            case .workoutPlanner:
                LuxuryWorkoutPlannerView()
            case .goalSetter:
                LuxuryGoalSetterView()
            }
        }
    }
    
    // MARK: - Luxury Header
    private var luxuryHeaderSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Smart Planning")
                        .font(LuxuryTheme.Typography.title1)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text("AI-powered health optimization")
                        .font(LuxuryTheme.Typography.callout)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                }
                
                Spacer()
                
                // Calendar Button
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(LuxuryTheme.Gradients.goldGradient)
                            .frame(width: 50, height: 50)
                            .shadow(color: LuxuryTheme.Colors.goldPrimary.opacity(0.3), radius: 10, x: 0, y: 4)
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(animateCards ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateCards)
                }
            }
        }
    }
    
    // MARK: - AI Planning Assistant
    private var aiPlanningAssistantSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(LuxuryTheme.Colors.aiBlue)
                
                Text("AI Planning Assistant")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
            }
            
            VStack(spacing: LuxuryTheme.Spacing.medium) {
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Weekly Optimization")
                                .font(LuxuryTheme.Typography.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Text("Let AI create your perfect week based on goals, preferences, and health data")
                            .font(LuxuryTheme.Typography.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack(spacing: LuxuryTheme.Spacing.small) {
                            LuxuryFeatureTag(text: "Meal Plans", icon: "fork.knife")
                            LuxuryFeatureTag(text: "Workouts", icon: "figure.run")
                            LuxuryFeatureTag(text: "Goals", icon: "target")
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { activeSheet = .mealPlanner }) {
                        VStack(spacing: 4) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Generate")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(16)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.2))
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(LuxuryTheme.Spacing.medium)
                .background(
                    RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.xLarge)
                        .fill(LuxuryTheme.Gradients.aiGradient)
                        .shadow(color: LuxuryTheme.Colors.aiBlue.opacity(0.3), radius: 15, x: 0, y: 8)
                )
            }
        }
    }
    
    // MARK: - Planning Tab Selector
    private var planningTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(PlanningTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(tab.rawValue)
                            .font(LuxuryTheme.Typography.callout)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(selectedTab == tab ? .white : LuxuryTheme.Colors.tertiaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                selectedTab == tab 
                                ? LinearGradient(colors: tab.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedTab == tab 
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
    
    // MARK: - Selected Tab Content
    @ViewBuilder
    private var selectedTabContent: some View {
        switch selectedTab {
        case .meals:
            mealPlanningContent
        case .workouts:
            workoutPlanningContent
        case .goals:
            goalPlanningContent
        }
    }
    
    private var mealPlanningContent: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("Meal Planning")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
                
                Button("Plan Week") { activeSheet = .mealPlanner }
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.nutritionRed)
            }
            
            VStack(spacing: LuxuryTheme.Spacing.small) {
                LuxuryPlanCard(
                    title: "Monday - High Protein",
                    subtitle: "Breakfast: Protein Smoothie Bowl\nLunch: Grilled Chicken Salad\nDinner: Salmon with Quinoa",
                    icon: "calendar",
                    colors: [LuxuryTheme.Colors.nutritionRed, LuxuryTheme.Colors.nutritionOrange],
                    isCompleted: true
                )
                
                LuxuryPlanCard(
                    title: "Tuesday - Balanced Day",
                    subtitle: "Breakfast: Oatmeal with Berries\nLunch: Turkey Wrap\nDinner: Vegetable Stir-fry",
                    icon: "calendar",
                    colors: [LuxuryTheme.Colors.nutritionRed, LuxuryTheme.Colors.nutritionOrange],
                    isCompleted: false
                )
                
                LuxuryPlanCard(
                    title: "Wednesday - Plant Power",
                    subtitle: "Breakfast: Avocado Toast\nLunch: Buddha Bowl\nDinner: Lentil Curry",
                    icon: "calendar",
                    colors: [LuxuryTheme.Colors.nutritionRed, LuxuryTheme.Colors.nutritionOrange],
                    isCompleted: false
                )
            }
        }
    }
    
    private var workoutPlanningContent: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("Workout Planning")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
                
                Button("Plan Week") { activeSheet = .workoutPlanner }
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.workoutPurple)
            }
            
            VStack(spacing: LuxuryTheme.Spacing.small) {
                LuxuryPlanCard(
                    title: "Monday - Upper Body",
                    subtitle: "Chest Press • Shoulder Press • Pull-ups\nDuration: 45 min • Intensity: High",
                    icon: "figure.strengthtraining.traditional",
                    colors: [LuxuryTheme.Colors.workoutPurple, LuxuryTheme.Colors.workoutViolet],
                    isCompleted: true
                )
                
                LuxuryPlanCard(
                    title: "Tuesday - Cardio Blast",
                    subtitle: "Running • Cycling • HIIT Training\nDuration: 30 min • Intensity: Medium",
                    icon: "figure.run",
                    colors: [LuxuryTheme.Colors.workoutPurple, LuxuryTheme.Colors.workoutViolet],
                    isCompleted: false
                )
                
                LuxuryPlanCard(
                    title: "Wednesday - Lower Body",
                    subtitle: "Squats • Deadlifts • Leg Press\nDuration: 50 min • Intensity: High",
                    icon: "figure.strengthtraining.traditional",
                    colors: [LuxuryTheme.Colors.workoutPurple, LuxuryTheme.Colors.workoutViolet],
                    isCompleted: false
                )
            }
        }
    }
    
    private var goalPlanningContent: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("Goal Setting")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
                
                Button("Set Goals") { activeSheet = .goalSetter }
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.goldPrimary)
            }
            
            VStack(spacing: LuxuryTheme.Spacing.small) {
                LuxuryGoalCard(
                    title: "Weight Loss",
                    current: "72.5 kg",
                    target: "70.0 kg",
                    progress: 0.75,
                    timeframe: "4 weeks remaining",
                    color: LuxuryTheme.Colors.nutritionOrange
                )
                
                LuxuryGoalCard(
                    title: "Daily Steps",
                    current: "8,947",
                    target: "10,000",
                    progress: 0.89,
                    timeframe: "Today",
                    color: LuxuryTheme.Colors.scanTeal
                )
                
                LuxuryGoalCard(
                    title: "Workout Frequency",
                    current: "4",
                    target: "5",
                    progress: 0.8,
                    timeframe: "This week",
                    color: LuxuryTheme.Colors.workoutPurple
                )
            }
        }
    }
    
    // MARK: - Quick Planning Actions
    private var quickPlanningActions: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("Quick Actions")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: LuxuryTheme.Spacing.small), count: 2), spacing: LuxuryTheme.Spacing.small) {
                LuxuryQuickActionCard(
                    title: "Meal Prep",
                    subtitle: "Plan & Prepare",
                    icon: "chef.fill",
                    colors: [LuxuryTheme.Colors.recipePink, LuxuryTheme.Colors.recipeRed],
                    action: { activeSheet = .mealPlanner }
                )
                
                LuxuryQuickActionCard(
                    title: "Weekly Plan",
                    subtitle: "AI Generated",
                    icon: "brain.head.profile",
                    colors: [LuxuryTheme.Colors.aiBlue, LuxuryTheme.Colors.aiBlueSecondary],
                    action: { activeSheet = .mealPlanner }
                )
            }
        }
    }
    
    // MARK: - Weekly Overview
    private var weeklyOverviewSection: some View {
        VStack(spacing: LuxuryTheme.Spacing.medium) {
            HStack {
                Text("This Week Overview")
                    .font(LuxuryTheme.Typography.headline)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
                
                Text("Dec 9 - 15, 2024")
                    .font(LuxuryTheme.Typography.caption)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
            }
            
            VStack(spacing: LuxuryTheme.Spacing.small) {
                LuxuryWeeklyStatsCard(
                    title: "Meal Plans Completed",
                    value: "5/7",
                    percentage: 71,
                    color: LuxuryTheme.Colors.nutritionRed
                )
                
                LuxuryWeeklyStatsCard(
                    title: "Workouts Completed",
                    value: "3/4",
                    percentage: 75,
                    color: LuxuryTheme.Colors.workoutPurple
                )
                
                LuxuryWeeklyStatsCard(
                    title: "Goals Achieved",
                    value: "2/3",
                    percentage: 67,
                    color: LuxuryTheme.Colors.goldPrimary
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
            animateCards = true
        }
    }
}

// MARK: - Supporting Luxury Components

struct LuxuryPlanCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: LuxuryTheme.Spacing.small) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 50, height: 50)
                    .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                if isCompleted {
                    Circle()
                        .fill(LuxuryTheme.Colors.scanGreen)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 20, y: -20)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(LuxuryTheme.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Text(subtitle)
                    .font(LuxuryTheme.Typography.caption)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(LuxuryTheme.Spacing.small)
        .luxuryCard()
    }
}

struct LuxuryGoalCard: View {
    let title: String
    let current: String
    let target: String
    let progress: Double
    let timeframe: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: LuxuryTheme.Spacing.small) {
            HStack {
                Text(title)
                    .font(LuxuryTheme.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(LuxuryTheme.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color.opacity(0.2))
                    )
            }
            
            HStack {
                Text(current)
                    .font(LuxuryTheme.Typography.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text("/")
                    .font(LuxuryTheme.Typography.body)
                    .foregroundColor(LuxuryTheme.Colors.tertiaryText)
                
                Text(target)
                    .font(LuxuryTheme.Typography.body)
                    .foregroundColor(LuxuryTheme.Colors.secondaryText)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LuxuryTheme.Colors.cardBorder)
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .animation(.easeInOut(duration: 1.0), value: progress)
                }
            }
            .frame(height: 6)
            
            Text(timeframe)
                .font(LuxuryTheme.Typography.caption)
                .foregroundColor(LuxuryTheme.Colors.tertiaryText)
        }
        .padding(LuxuryTheme.Spacing.small)
        .luxuryCard()
    }
}

struct LuxuryWeeklyStatsCard: View {
    let title: String
    let value: String
    let percentage: Int
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LuxuryTheme.Typography.callout)
                    .foregroundColor(LuxuryTheme.Colors.primaryText)
                
                Text(value)
                    .font(LuxuryTheme.Typography.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
            
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: Double(percentage) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: percentage)
                
                Text("\(percentage)%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
            }
        }
        .padding(LuxuryTheme.Spacing.small)
        .luxuryCard()
    }
}

// MARK: - Placeholder Planner Views

struct LuxuryWorkoutPlannerView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: LuxuryTheme.Spacing.xLarge) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 80))
                        .foregroundColor(LuxuryTheme.Colors.workoutPurple)
                    
                    Text("Workout Planner")
                        .font(LuxuryTheme.Typography.title1)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text("Coming Soon")
                        .font(LuxuryTheme.Typography.body)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                }
            }
        }
    }
}

struct LuxuryGoalSetterView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LuxuryTheme.Gradients.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: LuxuryTheme.Spacing.xLarge) {
                    Image(systemName: "target")
                        .font(.system(size: 80))
                        .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                    
                    Text("Goal Setter")
                        .font(LuxuryTheme.Typography.title1)
                        .foregroundColor(LuxuryTheme.Colors.primaryText)
                    
                    Text("Coming Soon")
                        .font(LuxuryTheme.Typography.body)
                        .foregroundColor(LuxuryTheme.Colors.secondaryText)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(LuxuryTheme.Colors.goldPrimary)
                }
            }
        }
    }
}

struct LuxuryMealPlannerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var planning = DietPlanningManager()
    @State private var preference: DietaryPreference = .balanced
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Form {
                    Section(header: Text("Preferences")) {
                        Picker("Diet", selection: $preference) {
                            ForEach(DietaryPreference.allCases) { pref in
                                Text(pref.displayName).tag(pref)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section(header: Text("Actions")) {
                        Button {
                            planning.generate(preference: preference)
                        } label: {
                            Label("Generate Weekly Plan", systemImage: "wand.and.stars")
                        }
                        .accessibilityLabel("Generate weekly plan")
                        
                        if let plan = planning.weeklyPlan {
                            NavigationLink(destination: MealPlanDetailsView(plan: plan)) {
                                Label("View Plan", systemImage: "calendar")
                            }
                        }
                        if let list = planning.shoppingList, planning.weeklyPlan != nil {
                            NavigationLink(destination: ShoppingListView(list: list)) {
                                Label("Shopping List", systemImage: "cart")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Meal Planner")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct MealPlanDetailsView: View {
    let plan: WeeklyMealPlan
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    
    var body: some View {
        List {
            ForEach(plan.days) { day in
                Section(header: Text(dateFormatter.string(from: day.date))) {
                    ForEach(day.meals) { pm in
                        HStack {
                            Text(pm.slot.displayName)
                                .fontWeight(.semibold)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(pm.recipe.name)
                                Text("\(pm.recipe.calories) kcal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(pm.slot.displayName): \(pm.recipe.name), \(pm.recipe.calories) calories")
                    }
                }
            }
        }
        .navigationTitle("Weekly Plan")
    }
}

#Preview {
    LuxuryPlanView()
}
