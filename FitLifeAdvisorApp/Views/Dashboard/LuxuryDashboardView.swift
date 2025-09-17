

import SwiftUI

struct LuxuryDashboardView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var mealAnalysisManager = MealAnalysisManager.shared
    @StateObject private var mlKitManager = MLKitManager()
    @State private var selectedTimeframe: TimeFrame = .today
    @State private var showingProfile = false
    @State private var animateWelcome = false
    @State private var animateStats = false
    @State private var currentDate = Date()
    
    // Sheet states
    @State private var showingSnapMeal = false
    @State private var showingQuickScan = false
    @State private var showingWorkoutTracker = false
    @State private var showingRecipeDiscovery = false
    @State private var showingMealPlanner = false
    @State private var showingProgressAnalytics = false
    
    enum TimeFrame: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        
        var emoji: String {
            switch self {
            case .today: return "📅"
            case .week: return "📊"
            case .month: return "📈"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Luxury gradient background
                luxuryBackgroundGradient
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Premium Header Section
                        premiumHeaderSection
                            .padding(.horizontal, 20)
                        
                        // AI-Powered Features Showcase
                        aiPoweredFeaturesSection
                            .padding(.horizontal, 20)
                            .padding(.top, 25)
                        
                        // Smart Analytics Dashboard
                        smartAnalyticsSection
                            .padding(.horizontal, 20)
                            .padding(.top, 30)
                        
                        // Comprehensive Health Tracking
                        comprehensiveHealthSection
                            .padding(.horizontal, 20)
                            .padding(.top, 30)
                        
                        // Intelligent Recommendations
                        intelligentRecommendationsSection
                            .padding(.horizontal, 20)
                            .padding(.top, 30)
                        
                        // Bottom spacing for tab bar
                        Color.clear.frame(height: 120)
                    }
                }
                .refreshable {
                    await refreshDashboardData()
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            startAnimations()
            updateCurrentDate()
        }
        .sheet(isPresented: $showingSnapMeal) {
            MealPhotoAnalysisView()
        }
        .sheet(isPresented: $showingQuickScan) {
            FoodScannerView()
        }
        .sheet(isPresented: $showingWorkoutTracker) {
            WorkoutTrackerView()
        }
        .sheet(isPresented: $showingRecipeDiscovery) {
            RecipeDiscoveryView()
        }
        .sheet(isPresented: $showingMealPlanner) {
            LuxuryPlanView()
        }
        .sheet(isPresented: $showingProgressAnalytics) {
            AdvancedProgressView()
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }

    private var luxuryBackgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "0A0A0A"), location: 0.0),
                .init(color: Color(hex: "1A1A2E"), location: 0.3),
                .init(color: Color(hex: "16213E"), location: 0.7),
                .init(color: Color(hex: "0F0F23"), location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var premiumHeaderSection: some View {
        VStack(spacing: 25) {
            // Top Status Bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText())
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(authManager.currentUser?.name ?? "Health Enthusiast")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(animateWelcome ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateWelcome)
                }
                
                Spacer()
                
                // Premium Profile Button
                Button(action: { showingProfile = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FFD700").opacity(0.8),
                                        Color(hex: "FFA500").opacity(0.9),
                                        Color(hex: "FF6B6B").opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 10, x: 0, y: 4)
                        
                        Text(String(authManager.currentUser?.name.prefix(1) ?? "U").uppercased())
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(animateWelcome ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateWelcome)
                }
            }
            .padding(.top, 10)
            
            // Luxury Status Card
            luxuryStatusCard
        }
    }
    
    // MARK: - Luxury Status Card
    private var luxuryStatusCard: some View {
        VStack(spacing: 20) {
            // Today's Achievement Summary
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
                    
                    Text("Excellent Progress!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // AI Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: animateStats ? 0.96 : 0)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "00E5FF"), Color(hex: "0091EA")],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.5).delay(0.5), value: animateStats)
                    
                    VStack {
                        Text("96")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
    
    // MARK: - AI-Powered Features
    private var aiPoweredFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(
                title: "AI-Powered Features",
                subtitle: "Advanced intelligence for optimal health"
            )
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                // Snap Meal - Premium Feature
                PremiumFeatureCard(
                    title: "Snap Meal",
                    subtitle: "AI Nutrition Analysis",
                    icon: "camera.macro",
                    colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E53")],
                    isAIPowered: true
                ) {
                    showingSnapMeal = true
                }
                
                // Quick Scan - Premium Feature  
                PremiumFeatureCard(
                    title: "Quick Scan",
                    subtitle: "Barcode & Label Reader",
                    icon: "barcode.viewfinder",
                    colors: [Color(hex: "4ECDC4"), Color(hex: "44A08D")],
                    isAIPowered: true
                ) {
                    showingQuickScan = true
                }
                
                // Workout Intelligence
                PremiumFeatureCard(
                    title: "Smart Workouts",
                    subtitle: "AI Personal Training",
                    icon: "brain.head.profile",
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    isAIPowered: true
                ) {
                    showingWorkoutTracker = true
                }
                
                // Recipe Discovery
                PremiumFeatureCard(
                    title: "Recipe AI",
                    subtitle: "Personalized Meals",
                    icon: "chef.fill",
                    colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                    isAIPowered: true
                ) {
                    showingRecipeDiscovery = true
                }
            }
        }
    }
    
    // MARK: - Smart Analytics
    private var smartAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(
                title: "Smart Analytics",
                subtitle: "Real-time health insights powered by AI"
            )
            
            // Time Frame Selector
            luxuryTimeFrameSelector
            
            // Analytics Grid
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    // Calories Analytics
                    SmartAnalyticsCard(
                        title: "Calories",
                        current: mealAnalysisManager.getTotalNutritionForToday().calories,
                        target: 2200,
                        unit: "kcal",
                        color: Color(hex: "FF6B6B"),
                        icon: "flame.fill",
                        trend: "+12%"
                    )
                    
                    // Protein Analytics
                    SmartAnalyticsCard(
                        title: "Protein",
                        current: mealAnalysisManager.getTotalNutritionForToday().protein,
                        target: 120,
                        unit: "g",
                        color: Color(hex: "4ECDC4"),
                        icon: "bolt.fill",
                        trend: "+8%"
                    )
                }
                
                HStack(spacing: 15) {
                    // Steps Analytics
                    SmartAnalyticsCard(
                        title: "Steps",
                        current: 8432,
                        target: 10000,
                        unit: "",
                        color: Color(hex: "667eea"),
                        icon: "figure.walk",
                        trend: "+15%"
                    )
                    
                    // Water Analytics
                    SmartAnalyticsCard(
                        title: "Hydration",
                        current: 6,
                        target: 8,
                        unit: "glasses",
                        color: Color(hex: "00E5FF"),
                        icon: "drop.fill",
                        trend: "+5%"
                    )
                }
            }
        }
    }
    
    // MARK: - Comprehensive Health
    private var comprehensiveHealthSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(
                title: " Health Management",
                subtitle: "Comprehensive tracking and planning"
            )
            
            VStack(spacing: 12) {
                // Meal Planning
                HealthManagementRow(
                    title: "Smart Meal Planning",
                    subtitle: "AI-generated meal plans based on your goals",
                    icon: "calendar",
                    color: Color(hex: "f093fb"),
                    action: { showingMealPlanner = true }
                )
                
                // Progress Analytics
                HealthManagementRow(
                    title: "Advanced Analytics",
                    subtitle: "Deep insights into your health patterns",
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color(hex: "4ECDC4"),
                    action: { showingProgressAnalytics = true }
                )
                
                // Health Score
                HealthManagementRow(
                    title: "AI Health Score",
                    subtitle: "Comprehensive health assessment",
                    icon: "brain.head.profile",
                    color: Color(hex: "00E5FF"),
                    action: { showingProgressAnalytics = true }
                )
            }
        }
    }
    
    // MARK: - Intelligent Recommendations
    private var intelligentRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(
                title: "💡 Smart Recommendations",
                subtitle: "Personalized insights just for you"
            )
            
            VStack(spacing: 12) {
                // Meal Recommendation
                LuxuryRecommendationCard(
                    title: "Perfect Post-Workout Meal",
                    description: "Based on your morning cardio session, try a protein-rich smoothie bowl with berries",
                    icon: "brain.head.profile",
                    actionTitle: "View Recipe",
                    color: Color(hex: "FF6B6B")
                ) {
                    showingRecipeDiscovery = true
                }
                
                // Hydration Reminder
                LuxuryRecommendationCard(
                    title: "Hydration Boost Needed",
                    description: "You're 2 glasses behind today's goal. Perfect time for some lemon water!",
                    icon: "drop.fill",
                    actionTitle: "Log Water",
                    color: Color(hex: "00E5FF")
                ) {
                    // Log water intake
                }
                
                // Activity Suggestion
                LuxuryRecommendationCard(
                    title: "Evening Walk Suggestion",
                    description: "Great day! A 15-minute walk would help you reach your step goal",
                    icon: "figure.walk",
                    actionTitle: "Start Walk",
                    color: Color(hex: "667eea")
                ) {
                    showingWorkoutTracker = true
                }
            }
        }
    }
    
    // MARK: - Luxury Time Frame Selector
    private var luxuryTimeFrameSelector: some View {
        HStack(spacing: 0) {
            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTimeframe = timeFrame
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(timeFrame.emoji)
                            .font(.system(size: 16))
                        
                        Text(timeFrame.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedTimeframe == timeFrame ? .white : .white.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                selectedTimeframe == timeFrame 
                                ? LinearGradient(
                                    colors: [Color(hex: "FFD700").opacity(0.3), Color(hex: "FFA500").opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedTimeframe == timeFrame 
                                        ? Color(hex: "FFD700").opacity(0.5)
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
    
    // MARK: - Helper Functions
    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: currentDate)
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
            animateWelcome = true
        }
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.3)) {
            animateStats = true
        }
    }
    
    private func updateCurrentDate() {
        currentDate = Date()
    }
    
    @MainActor
    private func refreshDashboardData() async {
        // Simulate data refresh
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        updateCurrentDate()
    }
}

// MARK: - Premium Feature Card
struct PremiumFeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]
    let isAIPowered: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 10, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                if isAIPowered {
                    HStack(spacing: 4) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "00E5FF"))
                        
                        Text("AI POWERED")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "00E5FF"))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "00E5FF").opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "00E5FF").opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(20)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Smart Analytics Card
struct SmartAnalyticsCard: View {
    let title: String
    let current: Double
    let target: Double
    let unit: String
    let color: Color
    let icon: String
    let trend: String
    
    @State private var animateProgress = false
    
    private var progress: Double {
        target > 0 ? min(current / target, 1.0) : 0.0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
                
                Text(trend)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.2))
                    )
            }
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            
            Text("\(Int(current))")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white) +
            Text(" / \(Int(target)) \(unit)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animateProgress ? geometry.size.width * progress : 0, height: 6)
                        .animation(.easeInOut(duration: 1.0).delay(0.5), value: animateProgress)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8)) {
                animateProgress = true
            }
        }
    }
}

// MARK: - Health Management Row
struct HealthManagementRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Luxury Dashboard Recommendation Card
struct LuxuryRecommendationCard: View {
    let title: String
    let description: String
    let icon: String
    let actionTitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Action Button
            Button(action: action) {
                Text(actionTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(color.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    LuxuryDashboardView()
        .environmentObject(AuthenticationManager())
}
