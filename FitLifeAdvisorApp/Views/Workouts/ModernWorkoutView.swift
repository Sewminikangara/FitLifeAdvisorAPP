//
//  ModernWorkoutView.swift
//  FitLifeAdvisorApp
//
//  Modern Workout Discovery with beautiful UI and enhanced user experience
//

import SwiftUI

struct ModernWorkoutView: View {
    @State private var selectedCategory: WorkoutCategory = .all
    @State private var searchText = ""
    @State private var showingWorkoutDetail = false
    @State private var selectedWorkout: WorkoutPlan?
    @State private var showingActiveWorkout = false
    @State private var animateCards = false
    
    enum WorkoutCategory: String, CaseIterable {
        case all = "All"
        case strength = "Strength"
        case cardio = "Cardio"
        case yoga = "Yoga"
        case hiit = "HIIT"
        case pilates = "Pilates"
        case dance = "Dance"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .strength: return "dumbbell"
            case .cardio: return "heart.fill"
            case .yoga: return "figure.yoga"
            case .hiit: return "bolt.fill"
            case .pilates: return "figure.flexibility"
            case .dance: return "music.note"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return Constants.Colors.primaryBlue
            case .strength: return .red
            case .cardio: return .pink
            case .yoga: return .green
            case .hiit: return .orange
            case .pilates: return .purple
            case .dance: return .cyan
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
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
                    LazyVStack(spacing: Constants.Spacing.large) {
                        // Modern Header with motivation
                        modernHeaderSection
                        
                        // Search Bar
                        modernSearchSection
                        
                        // Category Selector
                        categoryFilterSection
                        
                        // Featured Workout
                        featuredWorkoutSection
                        
                        // Quick Start Workouts
                        quickStartSection
                        
                        // Workout Categories Grid
                        workoutCategoriesSection
                        
                        // Popular Workouts
                        popularWorkoutsSection
                        
                        // Personal Recommendations
                        personalRecommendationsSection
                    }
                    .padding(.top, Constants.Spacing.medium)
                    .padding(.bottom, 100) // Tab bar spacing
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingActiveWorkout = true }) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(Constants.Colors.primaryBlue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingWorkoutDetail) {
            if let workout = selectedWorkout {
                WorkoutDetailView(workout: workout)
            }
        }
        .sheet(isPresented: $showingActiveWorkout) {
            ActiveWorkoutView()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                animateCards = true
            }
        }
    }
    
    // MARK: - Modern Header Section
    private var modernHeaderSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Ready to Sweat? 💪")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text("Discover workouts designed for your fitness journey")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
                
                Spacer()
                
                // Workout streak indicator
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Constants.Colors.warningOrange, Constants.Colors.warningOrange.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        VStack(spacing: 2) {
                            Text("🔥")
                                .font(.title2)
                            Text("5")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Text("Day Streak")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
                .scaleEffect(animateCards ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateCards)
            }
            
            // Today's stats
            HStack(spacing: Constants.Spacing.large) {
                StatBadge(
                    icon: "timer",
                    title: "Active Time",
                    value: "23 min",
                    color: Constants.Colors.primaryBlue
                )
                
                StatBadge(
                    icon: "flame.fill",
                    title: "Calories Burned",
                    value: "187 kcal",
                    color: Constants.Colors.warningOrange
                )
                
                StatBadge(
                    icon: "heart.fill",
                    title: "Avg Heart Rate",
                    value: "142 bpm",
                    color: Constants.Colors.errorRed
                )
            }
        }
        .padding(.horizontal, Constants.Spacing.large)
    }
    
    // MARK: - Modern Search Section
    private var modernSearchSection: some View {
        HStack(spacing: Constants.Spacing.medium) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Constants.Colors.textLight)
                
                TextField("Search workouts, exercises, trainers...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Constants.Colors.textLight)
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.medium)
            .padding(.vertical, Constants.Spacing.small + 2)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            Button(action: {
                // Filter action
            }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.title2)
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .padding(12)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, Constants.Spacing.large)
    }
    
    // MARK: - Category Filter Section
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Spacing.medium) {
                ForEach(WorkoutCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    // MARK: - Featured Workout Section
    private var featuredWorkoutSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Featured Today")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Button("View All") {
                    // View all featured workouts
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            FeaturedWorkoutCard()
                .padding(.horizontal, Constants.Spacing.large)
                .scaleEffect(animateCards ? 1.0 : 0.95)
                .opacity(animateCards ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.8).delay(0.2), value: animateCards)
        }
    }
    
    // MARK: - Quick Start Section
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Quick Start (5-15 min)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
                .padding(.horizontal, Constants.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.medium) {
                    QuickWorkoutCard(
                        title: "Morning Boost",
                        subtitle: "5 min • Cardio",
                        icon: "sun.max.fill",
                        color: .orange,
                        difficulty: "Beginner"
                    )
                    
                    QuickWorkoutCard(
                        title: "Desk Break",
                        subtitle: "10 min • Stretch",
                        icon: "figure.flexibility",
                        color: .green,
                        difficulty: "Easy"
                    )
                    
                    QuickWorkoutCard(
                        title: "Power Burst",
                        subtitle: "15 min • HIIT",
                        icon: "bolt.fill",
                        color: .red,
                        difficulty: "Intense"
                    )
                    
                    QuickWorkoutCard(
                        title: "Core Blast",
                        subtitle: "8 min • Strength",
                        icon: "target",
                        color: .purple,
                        difficulty: "Moderate"
                    )
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
    
    // MARK: - Workout Categories Section
    private var workoutCategoriesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Browse Categories")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
                .padding(.horizontal, Constants.Spacing.large)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Constants.Spacing.medium) {
                WorkoutCategoryCard(
                    title: "Strength Training",
                    subtitle: "Build Muscle",
                    icon: "dumbbell",
                    color: .red,
                    workoutCount: "45+ workouts"
                )
                
                WorkoutCategoryCard(
                    title: "Cardio Fitness",
                    subtitle: "Burn Calories",
                    icon: "heart.fill",
                    color: .pink,
                    workoutCount: "38+ workouts"
                )
                
                WorkoutCategoryCard(
                    title: "Yoga & Mindfulness",
                    subtitle: "Find Balance",
                    icon: "figure.yoga",
                    color: .green,
                    workoutCount: "52+ workouts"
                )
                
                WorkoutCategoryCard(
                    title: "HIIT Training",
                    subtitle: "Maximum Impact",
                    icon: "bolt.fill",
                    color: .orange,
                    workoutCount: "29+ workouts"
                )
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    // MARK: - Popular Workouts Section
    private var popularWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Popular This Week")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Text("🔥 Trending")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Constants.Colors.warningOrange)
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            VStack(spacing: Constants.Spacing.small) {
                PopularWorkoutRow(
                    title: "Full Body Blast",
                    trainer: "Sarah Johnson",
                    duration: "30 min",
                    difficulty: "Intermediate",
                    rating: 4.8,
                    participants: "2.3k",
                    color: .blue
                )
                
                PopularWorkoutRow(
                    title: "Abs & Core Crusher",
                    trainer: "Mike Chen",
                    duration: "20 min",
                    difficulty: "Advanced",
                    rating: 4.9,
                    participants: "1.8k",
                    color: .purple
                )
                
                PopularWorkoutRow(
                    title: "Beginner Yoga Flow",
                    trainer: "Emma Williams",
                    duration: "45 min",
                    difficulty: "Beginner",
                    rating: 4.7,
                    participants: "3.1k",
                    color: .green
                )
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    // MARK: - Personal Recommendations
    private var personalRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Just For You")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text("Based on your fitness goals and activity")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
                
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(.horizontal, Constants.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.medium) {
                    WorkoutRecommendationCard(
                        title: "Weight Loss Journey",
                        subtitle: "Customized for your goals",
                        duration: "6 weeks",
                        workouts: "24 workouts",
                        color: Constants.Colors.successGreen
                    )
                    
                    WorkoutRecommendationCard(
                        title: "Strength Building",
                        subtitle: "Progressive difficulty",
                        duration: "8 weeks",
                        workouts: "32 workouts",
                        color: Constants.Colors.errorRed
                    )
                    
                    WorkoutRecommendationCard(
                        title: "Flexibility Focus",
                        subtitle: "Improve mobility",
                        duration: "4 weeks",
                        workouts: "20 sessions",
                        color: Constants.Colors.primaryBlue
                    )
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
}

// MARK: - Supporting Components

struct StatBadge: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Constants.Colors.textDark)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Constants.Colors.textLight)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CategoryButton: View {
    let category: ModernWorkoutView.WorkoutCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .medium))
                
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : Constants.Colors.textDark)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [category.color, category.color.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(colors: [.white, .white], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(20)
            .shadow(color: isSelected ? category.color.opacity(0.4) : .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeaturedWorkoutCard: View {
    var body: some View {
        Button(action: {}) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Constants.Colors.primaryBlue,
                                Constants.Colors.primaryBlue.opacity(0.8),
                                Constants.Colors.primaryBlue.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                
                HStack {
                    VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🏆 Featured")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("30-Day Transformation Challenge")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(2)
                            
                            Text("Full-body workout program designed to help you achieve your fitness goals")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(3)
                        }
                        
                        HStack(spacing: Constants.Spacing.medium) {
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                    .font(.caption)
                                Text("30 days")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.caption)
                                Text("High intensity")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        
                        HStack {
                            Text("Start Challenge")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Constants.Colors.primaryBlue)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(.white)
                                .cornerRadius(25)
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "figure.run.square.stack.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Spacer()
                    }
                }
                .padding(Constants.Spacing.large)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: Constants.Colors.primaryBlue.opacity(0.4), radius: 20, x: 0, y: 10)
    }
}

struct QuickWorkoutCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let difficulty: String
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                    
                    Text(difficulty)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.8))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
                
                HStack {
                    Text("Start Now")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                        .foregroundColor(color)
                }
            }
            .padding(Constants.Spacing.medium)
            .frame(width: 160, height: 120)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ModernButtonStyle())
    }
}

struct WorkoutCategoryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let workoutCount: String
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Constants.Colors.textDark)
                        .lineLimit(2)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                    
                    Text(workoutCount)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
                
                Spacer()
            }
            .padding(Constants.Spacing.large)
            .frame(height: 140)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ModernButtonStyle())
    }
}

struct PopularWorkoutRow: View {
    let title: String
    let trainer: String
    let duration: String
    let difficulty: String
    let rating: Double
    let participants: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: Constants.Spacing.medium) {
                // Workout thumbnail
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text("by \(trainer)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                    
                    HStack(spacing: Constants.Spacing.small) {
                        Label(duration, systemImage: "timer")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Constants.Colors.textLight)
                        
                        Text("•")
                            .foregroundColor(Constants.Colors.textLight)
                        
                        Text(difficulty)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(color)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Constants.Colors.textDark)
                    }
                    
                    Text("\(participants) joined")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
            }
            .padding(Constants.Spacing.medium)
            .background(.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WorkoutRecommendationCard: View {
    let title: String
    let subtitle: String
    let duration: String
    let workouts: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🎯 Recommended")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(color)
                        
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Constants.Colors.textDark)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                    .lineLimit(2)
                
                HStack(spacing: Constants.Spacing.medium) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(duration)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(color)
                        
                        Text("Duration")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Constants.Colors.textLight)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(workouts)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(color)
                        
                        Text("Workouts")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Constants.Colors.textLight)
                    }
                }
            }
            .padding(Constants.Spacing.large)
            .frame(width: 220, height: 160)
            .background(.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: color.opacity(0.2), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(ModernButtonStyle())
    }
}

// MARK: - Supporting Views for Sheets
struct WorkoutDetailView: View {
    let workout: WorkoutPlan
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Workout Details")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            .navigationTitle(workout.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ActiveWorkoutView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Active Workout")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            .navigationTitle("Workout Session")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WorkoutPlan: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let duration: Int
    let difficulty: String
    let exercises: [Exercise]
}

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let duration: Int
    let reps: Int?
    let sets: Int?
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Constants.Spacing.small) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.textDark)
        }
    }
}

#Preview {
    ModernWorkoutView()
}
