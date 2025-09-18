//
//  RecipeDiscoveryView.swift
//  FitLifeAdvisorApp
//
//  AI-powered recipe discovery and meal planning
//

import SwiftUI

struct RecipeDiscoveryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: RecipeCategory = .all
    @State private var selectedDietary: DietaryFilter = .none
    @State private var showingFilters = false
    
    enum RecipeCategory: String, CaseIterable {
        case all = "All"
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snacks = "Snacks"
        case desserts = "Desserts"
        case smoothies = "Smoothies"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .breakfast: return "sunrise"
            case .lunch: return "sun.max"
            case .dinner: return "moon"
            case .snacks: return "heart"
            case .desserts: return "birthday.cake"
            case .smoothies: return "cup.and.saucer"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return Color(hex: "667eea")
            case .breakfast: return Color(hex: "FFD93D")
            case .lunch: return Color(hex: "4ECDC4")
            case .dinner: return Color(hex: "6C5CE7")
            case .snacks: return Color(hex: "FF6B6B")
            case .desserts: return Color(hex: "f093fb")
            case .smoothies: return Color(hex: "A8E6CF")
            }
        }
    }
    
    enum DietaryFilter: String, CaseIterable {
        case none = "All Diets"
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case keto = "Keto"
        case paleo = "Paleo"
        case glutenFree = "Gluten-Free"
        case lowCarb = "Low Carb"
        case highProtein = "High Protein"
    }
    
    // Mock recipe data
    private let sampleRecipes = [
        Recipe(
            id: "1",
            title: "Protein Power Bowl",
            description: "Quinoa, grilled chicken, avocado, and tahini dressing",
            cookTime: "25 min",
            calories: 480,
            protein: 35,
            category: .lunch,
            dietary: [.highProtein, .glutenFree],
            image: "bowl.fill",
            difficulty: .easy,
            rating: 4.8
        ),
        Recipe(
            id: "2",
            title: "Berry Blast Smoothie",
            description: "Antioxidant-rich breakfast smoothie with protein powder",
            cookTime: "5 min",
            calories: 220,
            protein: 25,
            category: .smoothies,
            dietary: [.vegetarian, .highProtein],
            image: "cup.and.saucer.fill",
            difficulty: .easy,
            rating: 4.9
        ),
        Recipe(
            id: "3",
            title: "Zucchini Noodle Pad Thai",
            description: "Low-carb twist on the classic Thai dish",
            cookTime: "20 min",
            calories: 320,
            protein: 18,
            category: .dinner,
            dietary: [.lowCarb, .glutenFree, .vegan],
            image: "leaf.fill",
            difficulty: .medium,
            rating: 4.7
        ),
        Recipe(
            id: "4",
            title: "Overnight Chia Pudding",
            description: "Make-ahead breakfast with tropical fruits",
            cookTime: "5 min prep",
            calories: 280,
            protein: 12,
            category: .breakfast,
            dietary: [.vegan, .glutenFree],
            image: "heart.fill",
            difficulty: .easy,
            rating: 4.6
        )
    ]
    
    var filteredRecipes: [Recipe] {
        sampleRecipes.filter { recipe in
            let categoryMatch = selectedCategory == .all || recipe.category == selectedCategory
            let dietaryMatch = selectedDietary == .none || recipe.dietary.contains(selectedDietary)
            let searchMatch = searchText.isEmpty || recipe.title.localizedCaseInsensitiveContains(searchText)
            
            return categoryMatch && dietaryMatch && searchMatch
        }
    }
    
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
                            Text("🍳 Recipe Discovery")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("AI-powered personalized meal suggestions")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Search Bar
                        searchBar
                        
                        // Category Selection
                        categorySelection
                        
                        // AI Recommendations Banner
                        aiRecommendationsBanner
                        
                        // Recipe Grid
                        recipeGrid
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "slider.horizontal.3")
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
            .sheet(isPresented: $showingFilters) {
                filtersSheet
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Search recipes...", text: $searchText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
        }
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
    
    private var categorySelection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(RecipeCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var aiRecommendationsBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(Color(hex: "00E5FF"))
                Text("Today's AI Recommendations")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text("Based on your recent meals and fitness goals, these recipes are perfect for you:")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "00E5FF").opacity(0.2), Color(hex: "0091EA").opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "00E5FF").opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var recipeGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
            ForEach(filteredRecipes) { recipe in
                RecipeCard(recipe: recipe)
            }
        }
    }
    
    private var filtersSheet: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 25) {
                Text("Dietary Preferences")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(DietaryFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedDietary = filter
                        }) {
                            Text(filter.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedDietary == filter ? .white : .white.opacity(0.8))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedDietary == filter ? Color(hex: "00E5FF").opacity(0.3) : Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedDietary == filter ? Color(hex: "00E5FF") : Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color.black)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingFilters = false
                    }
                    .foregroundColor(Color(hex: "00E5FF"))
                }
            }
        }
        .onAppear {
            if #available(iOS 16.0, *) {
                // Use presentationDetents if available
            }
        }
    }
}

struct CategoryChip: View {
    let category: RecipeDiscoveryView.RecipeCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : category.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? category.color.opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? category.color : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Recipe Image Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(recipe.category.color.opacity(0.2))
                    .frame(height: 120)
                
                Image(systemName: recipe.image)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(recipe.category.color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(recipe.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(recipe.cookTime)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", recipe.rating))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                HStack(spacing: 8) {
                    NutritionTag(title: "\(recipe.calories)", subtitle: "cal", color: Color(hex: "FF6B6B"))
                    NutritionTag(title: "\(Int(recipe.protein))g", subtitle: "protein", color: Color(hex: "4ECDC4"))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

struct NutritionTag: View {
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.2))
        )
    }
}

// MARK: - Recipe Model
struct Recipe: Identifiable {
    let id: String
    let title: String
    let description: String
    let cookTime: String
    let calories: Int
    let protein: Double
    let category: RecipeDiscoveryView.RecipeCategory
    let dietary: [RecipeDiscoveryView.DietaryFilter]
    let image: String
    let difficulty: Difficulty
    let rating: Double
    
    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
}

#Preview {
    RecipeDiscoveryView()
}
