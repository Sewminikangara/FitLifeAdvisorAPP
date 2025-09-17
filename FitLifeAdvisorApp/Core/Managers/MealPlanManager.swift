//
//  MealPlanManager.swift
//  FitLifeAdvisorApp
//
//  Advanced AI-powered meal planning system with goal-based recommendations
//

import Foundation
import SwiftUI
import Combine

// MARK: - Data Models

struct MealPlan: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let goalType: NutritionGoal
    let startDate: Date
    let endDate: Date
    let dailyPlans: [DailyMealPlan]
    let totalNutrition: WeeklyNutritionSummary
    let groceryList: GroceryList
    let estimatedCost: Double
    let difficultyLevel: DifficultyLevel
    let createdAt: Date
    
    enum DifficultyLevel: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate" 
        case advanced = "Advanced"
        
        var description: String {
            switch self {
            case .beginner: return "Simple recipes, minimal prep"
            case .intermediate: return "Moderate cooking skills required"
            case .advanced: return "Complex recipes, advanced techniques"
            }
        }
        
        var cookingTimeMultiplier: Double {
            switch self {
            case .beginner: return 1.0
            case .intermediate: return 1.3
            case .advanced: return 1.8
            }
        }
    }
}

struct DailyMealPlan: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let breakfast: PlannedMeal
    let lunch: PlannedMeal
    let dinner: PlannedMeal
    let snacks: [PlannedMeal]
    let dailyNutrition: NutritionInfo
    let dailyCalories: Double
    let mealPrepTime: TimeInterval
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct PlannedMeal: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let recipe: Recipe?
    let ingredients: [PlannedIngredient]
    let nutrition: NutritionInfo
    let cookingTime: TimeInterval
    let prepTime: TimeInterval
    let servings: Int
    let mealType: MealType
    let tags: [String]
    let imageURL: String?
    let difficulty: MealPlan.DifficultyLevel
    
    var totalTime: TimeInterval {
        return cookingTime + prepTime
    }
    
    var formattedTime: String {
        let minutes = Int(totalTime / 60)
        return "\(minutes) min"
    }
}

struct PlannedIngredient: Identifiable, Codable {
    let id = UUID()
    let name: String
    let amount: Double
    let unit: String
    let category: IngredientCategory
    let estimatedCost: Double
    let isOptional: Bool
    let substitutes: [String]
    
    var displayAmount: String {
        if amount.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(amount)) \(unit)"
        } else {
            return String(format: "%.1f \(unit)", amount)
        }
    }
}

enum IngredientCategory: String, CaseIterable, Codable {
    case protein = "Protein"
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case grains = "Grains"
    case dairy = "Dairy"
    case spices = "Spices & Seasonings"
    case oils = "Oils & Fats"
    case pantry = "Pantry Staples"
    case frozen = "Frozen"
    case canned = "Canned Goods"
    
    var emoji: String {
        switch self {
        case .protein: return "🥩"
        case .vegetables: return "🥬"
        case .fruits: return "🍎"
        case .grains: return "🌾"
        case .dairy: return "🥛"
        case .spices: return "🧂"
        case .oils: return "🫒"
        case .pantry: return "🏪"
        case .frozen: return "🧊"
        case .canned: return "🥫"
        }
    }
}

struct Recipe: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let instructions: [String]
    let cookingTime: TimeInterval
    let prepTime: TimeInterval
    let servings: Int
    let difficulty: MealPlan.DifficultyLevel
    let cuisine: String
    let tags: [String]
    let nutrition: NutritionInfo
    let imageURL: String?
    let tips: [String]
}

enum NutritionGoal: String, CaseIterable, Codable {
    case weightLoss = "Weight Loss"
    case weightGain = "Weight Gain"
    case muscleGain = "Muscle Gain"
    case maintenance = "Weight Maintenance"
    case lowCarb = "Low Carb"
    case highProtein = "High Protein"
    case balanced = "Balanced Nutrition"
    case keto = "Ketogenic"
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    
    var description: String {
        switch self {
        case .weightLoss: return "Calorie deficit with balanced macros"
        case .weightGain: return "Calorie surplus with quality foods"
        case .muscleGain: return "High protein with moderate carbs"
        case .maintenance: return "Balanced calories for current weight"
        case .lowCarb: return "Reduced carbohydrate intake"
        case .highProtein: return "Increased protein for active lifestyle"
        case .balanced: return "Optimal macro distribution"
        case .keto: return "Very low carb, high fat"
        case .vegetarian: return "Plant-based with dairy/eggs"
        case .vegan: return "100% plant-based nutrition"
        }
    }
    
    var targetMacros: MacroTargets {
        switch self {
        case .weightLoss:
            return MacroTargets(proteinPercent: 25, carbPercent: 40, fatPercent: 35, calorieMultiplier: 0.8)
        case .weightGain:
            return MacroTargets(proteinPercent: 20, carbPercent: 50, fatPercent: 30, calorieMultiplier: 1.2)
        case .muscleGain:
            return MacroTargets(proteinPercent: 30, carbPercent: 40, fatPercent: 30, calorieMultiplier: 1.1)
        case .maintenance:
            return MacroTargets(proteinPercent: 20, carbPercent: 50, fatPercent: 30, calorieMultiplier: 1.0)
        case .lowCarb:
            return MacroTargets(proteinPercent: 25, carbPercent: 25, fatPercent: 50, calorieMultiplier: 1.0)
        case .highProtein:
            return MacroTargets(proteinPercent: 35, carbPercent: 35, fatPercent: 30, calorieMultiplier: 1.0)
        case .balanced:
            return MacroTargets(proteinPercent: 20, carbPercent: 50, fatPercent: 30, calorieMultiplier: 1.0)
        case .keto:
            return MacroTargets(proteinPercent: 20, carbPercent: 5, fatPercent: 75, calorieMultiplier: 1.0)
        case .vegetarian:
            return MacroTargets(proteinPercent: 18, carbPercent: 55, fatPercent: 27, calorieMultiplier: 1.0)
        case .vegan:
            return MacroTargets(proteinPercent: 15, carbPercent: 60, fatPercent: 25, calorieMultiplier: 1.0)
        }
    }
    
    var emoji: String {
        switch self {
        case .weightLoss: return "📉"
        case .weightGain: return "📈"
        case .muscleGain: return "💪"
        case .maintenance: return "⚖️"
        case .lowCarb: return "🥩"
        case .highProtein: return "🍗" 
        case .balanced: return "🌈"
        case .keto: return "🥑"
        case .vegetarian: return "🥬"
        case .vegan: return "🌱"
        }
    }
}

struct MacroTargets {
    let proteinPercent: Double
    let carbPercent: Double
    let fatPercent: Double
    let calorieMultiplier: Double
    
    func calculateMacros(baseCalories: Double) -> (protein: Double, carbs: Double, fat: Double, calories: Double) {
        let targetCalories = baseCalories * calorieMultiplier
        let proteinGrams = (targetCalories * proteinPercent / 100) / 4
        let carbGrams = (targetCalories * carbPercent / 100) / 4
        let fatGrams = (targetCalories * fatPercent / 100) / 9
        
        return (proteinGrams, carbGrams, fatGrams, targetCalories)
    }
}

struct WeeklyNutritionSummary: Codable {
    let totalCalories: Double
    let averageDailyCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let averageMacros: MacroTargets
    let micronutrients: [String: Double]
    let weeklyGoalAdherence: Double // percentage
}

struct GroceryList: Identifiable, Codable {
    let id = UUID()
    let mealPlanId: UUID
    let items: [GroceryItem]
    let totalEstimatedCost: Double
    let createdAt: Date
    
    var itemsByCategory: [IngredientCategory: [GroceryItem]] {
        Dictionary(grouping: items, by: { $0.category })
    }
    
    var checkedOffCount: Int {
        items.filter { $0.isCheckedOff }.count
    }
    
    var completionPercentage: Double {
        guard !items.isEmpty else { return 0 }
        return Double(checkedOffCount) / Double(items.count) * 100
    }
}

struct GroceryItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let category: IngredientCategory
    let totalAmount: Double
    let unit: String
    let estimatedCost: Double
    let priority: Priority
    let isCheckedOff: Bool
    let stores: [String]
    let notes: String?
    
    enum Priority: String, CaseIterable, Codable {
        case essential = "Essential"
        case important = "Important"
        case optional = "Optional"
        
        var color: Color {
            switch self {
            case .essential: return .red
            case .important: return .orange
            case .optional: return .gray
            }
        }
    }
    
    var displayAmount: String {
        if totalAmount.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(totalAmount)) \(unit)"
        } else {
            return String(format: "%.1f \(unit)", totalAmount)
        }
    }
}

// MARK: - Meal Plan Manager

@MainActor
class MealPlanManager: ObservableObject {
    static let shared = MealPlanManager()
    
    @Published var currentMealPlan: MealPlan?
    @Published var savedMealPlans: [MealPlan] = []
    @Published var isGenerating = false
    @Published var currentGroceryList: GroceryList?
    @Published var generationProgress: Double = 0.0
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let mealPlanKey = "SavedMealPlans"
    private let currentPlanKey = "CurrentMealPlan"
    
    // Dependencies
    private let mealAnalysisManager = MealAnalysisManager.shared
    private let healthKitManager = HealthKitManager.shared
    
    private init() {
        loadSavedMealPlans()
        loadCurrentMealPlan()
    }
    
    // MARK: - Meal Plan Generation
    
    func generateMealPlan(
        goal: NutritionGoal,
        duration: Int = 7,
        difficulty: MealPlan.DifficultyLevel = .intermediate,
        dietaryRestrictions: [String] = [],
        dislikedIngredients: [String] = [],
        targetCalories: Double? = nil
    ) async {
        isGenerating = true
        generationProgress = 0.0
        errorMessage = nil
        
        do {
            // Step 1: Calculate user's nutritional needs
            generationProgress = 0.1
            let baseCalories = targetCalories ?? calculateBaseCalories()
            let macroTargets = goal.targetMacros.calculateMacros(baseCalories: baseCalories)
            
            // Step 2: Generate daily meal plans
            generationProgress = 0.3
            let dailyPlans = try await generateDailyPlans(
                duration: duration,
                macroTargets: macroTargets,
                goal: goal,
                difficulty: difficulty,
                dietaryRestrictions: dietaryRestrictions,
                dislikedIngredients: dislikedIngredients
            )
            
            // Step 3: Calculate weekly nutrition summary
            generationProgress = 0.7
            let nutritionSummary = calculateWeeklyNutritionSummary(from: dailyPlans)
            
            // Step 4: Generate grocery list
            generationProgress = 0.9
            let groceryList = generateGroceryList(from: dailyPlans)
            
            // Step 5: Create final meal plan
            let mealPlan = MealPlan(
                name: "\(goal.rawValue) Plan",
                description: "AI-generated \(duration)-day meal plan for \(goal.description.lowercased())",
                goalType: goal,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: duration - 1, to: Date()) ?? Date(),
                dailyPlans: dailyPlans,
                totalNutrition: nutritionSummary,
                groceryList: groceryList,
                estimatedCost: groceryList.totalEstimatedCost,
                difficultyLevel: difficulty,
                createdAt: Date()
            )
            
            currentMealPlan = mealPlan
            currentGroceryList = groceryList
            generationProgress = 1.0
            
            saveMealPlan(mealPlan)
            
        } catch {
            errorMessage = "Failed to generate meal plan: \(error.localizedDescription)"
        }
        
        isGenerating = false
    }
    
    // MARK: - Daily Plan Generation
    
    private func generateDailyPlans(
        duration: Int,
        macroTargets: (protein: Double, carbs: Double, fat: Double, calories: Double),
        goal: NutritionGoal,
        difficulty: MealPlan.DifficultyLevel,
        dietaryRestrictions: [String],
        dislikedIngredients: [String]
    ) async throws -> [DailyMealPlan] {
        
        var dailyPlans: [DailyMealPlan] = []
        let startDate = Date()
        
        for day in 0..<duration {
            let date = Calendar.current.date(byAdding: .day, value: day, to: startDate) ?? Date()
            
            // Distribute calories across meals
            let calorieDistribution = getCalorieDistribution(for: goal)
            let breakfastCalories = macroTargets.calories * calorieDistribution.breakfast
            let lunchCalories = macroTargets.calories * calorieDistribution.lunch
            let dinnerCalories = macroTargets.calories * calorieDistribution.dinner
            let snackCalories = macroTargets.calories * calorieDistribution.snacks
            
            // Generate meals for the day
            let breakfast = try await generateMeal(
                type: .breakfast,
                targetCalories: breakfastCalories,
                macroTargets: macroTargets,
                goal: goal,
                difficulty: difficulty,
                dietaryRestrictions: dietaryRestrictions,
                dislikedIngredients: dislikedIngredients
            )
            
            let lunch = try await generateMeal(
                type: .lunch,
                targetCalories: lunchCalories,
                macroTargets: macroTargets,
                goal: goal,
                difficulty: difficulty,
                dietaryRestrictions: dietaryRestrictions,
                dislikedIngredients: dislikedIngredients
            )
            
            let dinner = try await generateMeal(
                type: .dinner,
                targetCalories: dinnerCalories,
                macroTargets: macroTargets,
                goal: goal,
                difficulty: difficulty,
                dietaryRestrictions: dietaryRestrictions,
                dislikedIngredients: dislikedIngredients
            )
            
            let snacks = try await generateSnacks(
                targetCalories: snackCalories,
                goal: goal,
                dietaryRestrictions: dietaryRestrictions
            )
            
            // Calculate daily nutrition
            let dailyNutrition = calculateDailyNutrition(
                breakfast: breakfast,
                lunch: lunch,
                dinner: dinner,
                snacks: snacks
            )
            
            let dailyPlan = DailyMealPlan(
                date: date,
                breakfast: breakfast,
                lunch: lunch,
                dinner: dinner,
                snacks: snacks,
                dailyNutrition: dailyNutrition,
                dailyCalories: dailyNutrition.calories,
                mealPrepTime: breakfast.totalTime + lunch.totalTime + dinner.totalTime
            )
            
            dailyPlans.append(dailyPlan)
        }
        
        return dailyPlans
    }
    
    // MARK: - Meal Generation Logic
    
    private func generateMeal(
        type: MealType,
        targetCalories: Double,
        macroTargets: (protein: Double, carbs: Double, fat: Double, calories: Double),
        goal: NutritionGoal,
        difficulty: MealPlan.DifficultyLevel,
        dietaryRestrictions: [String],
        dislikedIngredients: [String]
    ) async throws -> PlannedMeal {
        
        // Get appropriate meal templates based on type and goal
        let mealTemplates = getMealTemplates(for: type, goal: goal, difficulty: difficulty)
        
        // Filter templates based on dietary restrictions
        let filteredTemplates = mealTemplates.filter { template in
            !template.tags.contains { tag in
                dislikedIngredients.contains { $0.lowercased() == tag.lowercased() }
            }
        }
        
        // Select best template
        guard let selectedTemplate = filteredTemplates.randomElement() else {
            throw MealPlanError.noSuitableTemplate
        }
        
        // Adjust portion sizes to meet calorie targets
        let adjustedMeal = adjustMealPortions(
            template: selectedTemplate,
            targetCalories: targetCalories,
            macroTargets: macroTargets
        )
        
        return adjustedMeal
    }
    
    private func generateSnacks(
        targetCalories: Double,
        goal: NutritionGoal,
        dietaryRestrictions: [String]
    ) async throws -> [PlannedMeal] {
        
        let snackTemplates = getSnackTemplates(for: goal)
        let snackCount = targetCalories > 200 ? 2 : 1
        let caloriesPerSnack = targetCalories / Double(snackCount)
        
        var snacks: [PlannedMeal] = []
        
        for _ in 0..<snackCount {
            if let template = snackTemplates.randomElement() {
                let adjustedSnack = adjustMealPortions(
                    template: template,
                    targetCalories: caloriesPerSnack,
                    macroTargets: (0, 0, 0, caloriesPerSnack)
                )
                snacks.append(adjustedSnack)
            }
        }
        
        return snacks
    }
    
    // MARK: - Grocery List Generation
    
    private func generateGroceryList(from dailyPlans: [DailyMealPlan]) -> GroceryList {
        var ingredientMap: [String: GroceryItem] = [:]
        
        for dailyPlan in dailyPlans {
            let allMeals = [dailyPlan.breakfast, dailyPlan.lunch, dailyPlan.dinner] + dailyPlan.snacks
            
            for meal in allMeals {
                for ingredient in meal.ingredients {
                    if let existingItem = ingredientMap[ingredient.name] {
                        // Combine amounts
                        let combinedAmount = existingItem.totalAmount + ingredient.amount
                        let combinedCost = existingItem.estimatedCost + ingredient.estimatedCost
                        
                        let updatedItem = GroceryItem(
                            name: ingredient.name,
                            category: ingredient.category,
                            totalAmount: combinedAmount,
                            unit: ingredient.unit,
                            estimatedCost: combinedCost,
                            priority: determinePriority(ingredient: ingredient),
                            isCheckedOff: false,
                            stores: ["Keells Super", "Arpico", "Cargills"],
                            notes: ingredient.isOptional ? "Optional ingredient" : nil
                        )
                        
                        ingredientMap[ingredient.name] = updatedItem
                    } else {
                        // Add new item
                        let groceryItem = GroceryItem(
                            name: ingredient.name,
                            category: ingredient.category,
                            totalAmount: ingredient.amount,
                            unit: ingredient.unit,
                            estimatedCost: ingredient.estimatedCost,
                            priority: determinePriority(ingredient: ingredient),
                            isCheckedOff: false,
                            stores: ["Keells Super", "Arpico", "Cargills"],
                            notes: ingredient.isOptional ? "Optional ingredient" : nil
                        )
                        
                        ingredientMap[ingredient.name] = groceryItem
                    }
                }
            }
        }
        
        let groceryItems = Array(ingredientMap.values).sorted { $0.category.rawValue < $1.category.rawValue }
        let totalCost = groceryItems.reduce(0) { $0 + $1.estimatedCost }
        
        return GroceryList(
            mealPlanId: UUID(),
            items: groceryItems,
            totalEstimatedCost: totalCost,
            createdAt: Date()
        )
    }
    
    // MARK: - Helper Functions
    
    private func calculateBaseCalories() -> Double {
        // Use HealthKit data if available, otherwise use standard calculation
        let healthMetrics = healthKitManager.todaysMetrics
        
        // Simple BMR calculation (Harris-Benedict equation approximation)
        // This would ideally use user's age, gender, height, weight from profile
        let estimatedBMR = 1800.0 // Default for average adult
        let activityMultiplier = 1.5 // Moderate activity
        
        return estimatedBMR * activityMultiplier
    }
    
    private func getCalorieDistribution(for goal: NutritionGoal) -> (breakfast: Double, lunch: Double, dinner: Double, snacks: Double) {
        switch goal {
        case .weightLoss:
            return (0.25, 0.35, 0.30, 0.10)
        case .weightGain:
            return (0.20, 0.30, 0.35, 0.15)
        case .muscleGain:
            return (0.25, 0.30, 0.35, 0.10)
        default:
            return (0.25, 0.35, 0.30, 0.10)
        }
    }
    
    private func calculateDailyNutrition(
        breakfast: PlannedMeal,
        lunch: PlannedMeal,
        dinner: PlannedMeal,
        snacks: [PlannedMeal]
    ) -> NutritionInfo {
        let allMeals = [breakfast, lunch, dinner] + snacks
        
        let totalCalories = allMeals.reduce(0) { $0 + $1.nutrition.calories }
        let totalProtein = allMeals.reduce(0) { $0 + $1.nutrition.protein }
        let totalCarbs = allMeals.reduce(0) { $0 + $1.nutrition.carbs }
        let totalFat = allMeals.reduce(0) { $0 + $1.nutrition.fat }
        let totalFiber = allMeals.reduce(0) { $0 + $1.nutrition.fiber }
        let totalSugar = allMeals.reduce(0) { $0 + $1.nutrition.sugar }
        let totalSodium = allMeals.reduce(0) { $0 + $1.nutrition.sodium }
        let totalCholesterol = allMeals.reduce(0) { $0 + $1.nutrition.cholesterol }
        
        return NutritionInfo(
            calories: totalCalories,
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat,
            fiber: totalFiber,
            sugar: totalSugar,
            sodium: totalSodium,
            cholesterol: totalCholesterol
        )
    }
    
    private func calculateWeeklyNutritionSummary(from dailyPlans: [DailyMealPlan]) -> WeeklyNutritionSummary {
        let totalCalories = dailyPlans.reduce(0) { $0 + $1.dailyNutrition.calories }
        let averageCalories = totalCalories / Double(dailyPlans.count)
        
        let totalProtein = dailyPlans.reduce(0) { $0 + $1.dailyNutrition.protein }
        let totalCarbs = dailyPlans.reduce(0) { $0 + $1.dailyNutrition.carbs }
        let totalFat = dailyPlans.reduce(0) { $0 + $1.dailyNutrition.fat }
        
        return WeeklyNutritionSummary(
            totalCalories: totalCalories,
            averageDailyCalories: averageCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            averageMacros: MacroTargets(
                proteinPercent: (totalProtein * 4 / totalCalories) * 100,
                carbPercent: (totalCarbs * 4 / totalCalories) * 100,
                fatPercent: (totalFat * 9 / totalCalories) * 100,
                calorieMultiplier: 1.0
            ),
            micronutrients: [:],
            weeklyGoalAdherence: 85.0 // Placeholder calculation
        )
    }
    
    private func determinePriority(ingredient: PlannedIngredient) -> GroceryItem.Priority {
        if ingredient.isOptional {
            return .optional
        } else if ingredient.category == .protein || ingredient.category == .vegetables {
            return .essential
        } else {
            return .important
        }
    }
    
    private func adjustMealPortions(
        template: PlannedMeal,
        targetCalories: Double,
        macroTargets: (protein: Double, carbs: Double, fat: Double, calories: Double)
    ) -> PlannedMeal {
        let currentCalories = template.nutrition.calories
        let scaleFactor = targetCalories / currentCalories
        
        // Scale nutrition
        let adjustedNutrition = NutritionInfo(
            calories: template.nutrition.calories * scaleFactor,
            protein: template.nutrition.protein * scaleFactor,
            carbs: template.nutrition.carbs * scaleFactor,
            fat: template.nutrition.fat * scaleFactor,
            fiber: template.nutrition.fiber * scaleFactor,
            sugar: template.nutrition.sugar * scaleFactor,
            sodium: template.nutrition.sodium * scaleFactor,
            cholesterol: template.nutrition.cholesterol * scaleFactor
        )
        
        // Scale ingredients
        let adjustedIngredients = template.ingredients.map { ingredient in
            PlannedIngredient(
                name: ingredient.name,
                amount: ingredient.amount * scaleFactor,
                unit: ingredient.unit,
                category: ingredient.category,
                estimatedCost: ingredient.estimatedCost * scaleFactor,
                isOptional: ingredient.isOptional,
                substitutes: ingredient.substitutes
            )
        }
        
        return PlannedMeal(
            name: template.name,
            description: template.description,
            recipe: template.recipe,
            ingredients: adjustedIngredients,
            nutrition: adjustedNutrition,
            cookingTime: template.cookingTime,
            prepTime: template.prepTime,
            servings: template.servings,
            mealType: template.mealType,
            tags: template.tags,
            imageURL: template.imageURL,
            difficulty: template.difficulty
        )
    }
    
    // MARK: - Data Persistence
    
    private func saveMealPlan(_ mealPlan: MealPlan) {
        savedMealPlans.append(mealPlan)
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults() {
        do {
            let encoded = try JSONEncoder().encode(savedMealPlans)
            userDefaults.set(encoded, forKey: mealPlanKey)
            
            if let currentPlan = currentMealPlan {
                let encodedCurrent = try JSONEncoder().encode(currentPlan)
                userDefaults.set(encodedCurrent, forKey: currentPlanKey)
            }
        } catch {
            print("Failed to save meal plans: \(error)")
        }
    }
    
    private func loadSavedMealPlans() {
        guard let data = userDefaults.data(forKey: mealPlanKey) else { return }
        
        do {
            savedMealPlans = try JSONDecoder().decode([MealPlan].self, from: data)
        } catch {
            print("Failed to load meal plans: \(error)")
        }
    }
    
    private func loadCurrentMealPlan() {
        guard let data = userDefaults.data(forKey: currentPlanKey) else { return }
        
        do {
            currentMealPlan = try JSONDecoder().decode(MealPlan.self, from: data)
            if let plan = currentMealPlan {
                currentGroceryList = plan.groceryList
            }
        } catch {
            print("Failed to load current meal plan: \(error)")
        }
    }
    
    // MARK: - Grocery List Management
    
    func updateGroceryItem(_ item: GroceryItem, isChecked: Bool) {
        guard var list = currentGroceryList else { return }
        
        if let index = list.items.firstIndex(where: { $0.id == item.id }) {
            let updatedItem = GroceryItem(
                name: item.name,
                category: item.category,
                totalAmount: item.totalAmount,
                unit: item.unit,
                estimatedCost: item.estimatedCost,
                priority: item.priority,
                isCheckedOff: isChecked,
                stores: item.stores,
                notes: item.notes
            )
            
            var updatedItems = list.items
            updatedItems[index] = updatedItem
            
            currentGroceryList = GroceryList(
                mealPlanId: list.mealPlanId,
                items: updatedItems,
                totalEstimatedCost: list.totalEstimatedCost,
                createdAt: list.createdAt
            )
        }
    }
    
    func clearCompletedGroceryItems() {
        guard var list = currentGroceryList else { return }
        
        let uncompletedItems = list.items.filter { !$0.isCheckedOff }
        
        currentGroceryList = GroceryList(
            mealPlanId: list.mealPlanId,
            items: uncompletedItems,
            totalEstimatedCost: uncompletedItems.reduce(0) { $0 + $1.estimatedCost },
            createdAt: list.createdAt
        )
    }
}

// MARK: - Error Types

enum MealPlanError: LocalizedError {
    case noSuitableTemplate
    case nutritionCalculationFailed
    case insufficientData
    
    var errorDescription: String? {
        switch self {
        case .noSuitableTemplate:
            return "No suitable meal template found for the specified criteria"
        case .nutritionCalculationFailed:
            return "Failed to calculate nutritional information"
        case .insufficientData:
            return "Insufficient data to generate meal plan"
        }
    }
}

// MARK: - Meal Templates Extension

extension MealPlanManager {
    private func getMealTemplates(for mealType: MealType, goal: NutritionGoal, difficulty: MealPlan.DifficultyLevel) -> [PlannedMeal] {
        // This would typically come from a database or API
        // For now, return sample templates
        
        switch mealType {
        case .breakfast:
            return getBreakfastTemplates(goal: goal, difficulty: difficulty)
        case .lunch:
            return getLunchTemplates(goal: goal, difficulty: difficulty)
        case .dinner:
            return getDinnerTemplates(goal: goal, difficulty: difficulty)
        case .snack:
            return getSnackTemplates(for: goal)
        }
    }
    
    private func getBreakfastTemplates(goal: NutritionGoal, difficulty: MealPlan.DifficultyLevel) -> [PlannedMeal] {
        return [
            // High Protein Breakfast
            PlannedMeal(
                name: "Protein Power Bowl",
                description: "Greek yogurt with berries, nuts, and protein powder",
                recipe: nil,
                ingredients: [
                    PlannedIngredient(name: "Greek Yogurt", amount: 200, unit: "g", category: .dairy, estimatedCost: 150, isOptional: false, substitutes: ["Regular Yogurt"]),
                    PlannedIngredient(name: "Mixed Berries", amount: 100, unit: "g", category: .fruits, estimatedCost: 200, isOptional: false, substitutes: ["Banana"]),
                    PlannedIngredient(name: "Almonds", amount: 30, unit: "g", category: .protein, estimatedCost: 180, isOptional: false, substitutes: ["Walnuts"]),
                    PlannedIngredient(name: "Protein Powder", amount: 25, unit: "g", category: .protein, estimatedCost: 200, isOptional: true, substitutes: [])
                ],
                nutrition: NutritionInfo(calories: 420, protein: 35, carbs: 28, fat: 18, fiber: 8, sugar: 20, sodium: 120, cholesterol: 15),
                cookingTime: 0,
                prepTime: 300,
                servings: 1,
                mealType: .breakfast,
                tags: ["high-protein", "quick", "healthy"],
                imageURL: nil,
                difficulty: .beginner
            ),
            
            // Balanced Breakfast
            PlannedMeal(
                name: "Overnight Oats with Fruits",
                description: "Nutritious overnight oats with seasonal fruits",
                recipe: nil,
                ingredients: [
                    PlannedIngredient(name: "Rolled Oats", amount: 50, unit: "g", category: .grains, estimatedCost: 40, isOptional: false, substitutes: ["Steel Cut Oats"]),
                    PlannedIngredient(name: "Milk", amount: 200, unit: "ml", category: .dairy, estimatedCost: 60, isOptional: false, substitutes: ["Almond Milk"]),
                    PlannedIngredient(name: "Banana", amount: 1, unit: "piece", category: .fruits, estimatedCost: 30, isOptional: false, substitutes: ["Apple"]),
                    PlannedIngredient(name: "Chia Seeds", amount: 15, unit: "g", category: .pantry, estimatedCost: 100, isOptional: true, substitutes: ["Flax Seeds"]),
                    PlannedIngredient(name: "Honey", amount: 10, unit: "g", category: .pantry, estimatedCost: 25, isOptional: true, substitutes: ["Maple Syrup"])
                ],
                nutrition: NutritionInfo(calories: 380, protein: 15, carbs: 65, fat: 8, fiber: 10, sugar: 25, sodium: 85, cholesterol: 5),
                cookingTime: 0,
                prepTime: 600,
                servings: 1,
                mealType: .breakfast,
                tags: ["fiber-rich", "make-ahead", "vegetarian"],
                imageURL: nil,
                difficulty: .beginner
            )
        ]
    }
    
    private func getLunchTemplates(goal: NutritionGoal, difficulty: MealPlan.DifficultyLevel) -> [PlannedMeal] {
        return [
            // Protein-Rich Lunch
            PlannedMeal(
                name: "Grilled Chicken Salad",
                description: "Fresh mixed greens with grilled chicken and quinoa",
                recipe: nil,
                ingredients: [
                    PlannedIngredient(name: "Chicken Breast", amount: 150, unit: "g", category: .protein, estimatedCost: 400, isOptional: false, substitutes: ["Turkey Breast"]),
                    PlannedIngredient(name: "Mixed Greens", amount: 100, unit: "g", category: .vegetables, estimatedCost: 120, isOptional: false, substitutes: ["Spinach"]),
                    PlannedIngredient(name: "Quinoa", amount: 80, unit: "g", category: .grains, estimatedCost: 150, isOptional: false, substitutes: ["Brown Rice"]),
                    PlannedIngredient(name: "Cherry Tomatoes", amount: 100, unit: "g", category: .vegetables, estimatedCost: 80, isOptional: false, substitutes: ["Regular Tomatoes"]),
                    PlannedIngredient(name: "Olive Oil", amount: 15, unit: "ml", category: .oils, estimatedCost: 30, isOptional: false, substitutes: []),
                    PlannedIngredient(name: "Lemon", amount: 0.5, unit: "piece", category: .fruits, estimatedCost: 20, isOptional: false, substitutes: ["Lime"])
                ],
                nutrition: NutritionInfo(calories: 520, protein: 42, carbs: 35, fat: 22, fiber: 6, sugar: 8, sodium: 180, cholesterol: 75),
                cookingTime: 900,
                prepTime: 600,
                servings: 1,
                mealType: .lunch,
                tags: ["high-protein", "gluten-free", "balanced"],
                imageURL: nil,
                difficulty: .intermediate
            ),
            
            // Vegetarian Lunch
            PlannedMeal(
                name: "Buddha Bowl",
                description: "Colorful vegetarian bowl with legumes and vegetables",
                recipe: nil,
                ingredients: [
                    PlannedIngredient(name: "Chickpeas", amount: 120, unit: "g", category: .protein, estimatedCost: 60, isOptional: false, substitutes: ["Black Beans"]),
                    PlannedIngredient(name: "Sweet Potato", amount: 150, unit: "g", category: .vegetables, estimatedCost: 80, isOptional: false, substitutes: ["Regular Potato"]),
                    PlannedIngredient(name: "Broccoli", amount: 100, unit: "g", category: .vegetables, estimatedCost: 100, isOptional: false, substitutes: ["Cauliflower"]),
                    PlannedIngredient(name: "Avocado", amount: 80, unit: "g", category: .fruits, estimatedCost: 120, isOptional: false, substitutes: []),
                    PlannedIngredient(name: "Tahini", amount: 20, unit: "g", category: .pantry, estimatedCost: 80, isOptional: true, substitutes: ["Hummus"])
                ],
                nutrition: NutritionInfo(calories: 485, protein: 18, carbs: 58, fat: 20, fiber: 15, sugar: 12, sodium: 95, cholesterol: 0),
                cookingTime: 1200,
                prepTime: 900,
                servings: 1,
                mealType: .lunch,
                tags: ["vegetarian", "vegan", "fiber-rich"],
                imageURL: nil,
                difficulty: .intermediate
            )
        ]
    }
    
    private func getDinnerTemplates(goal: NutritionGoal, difficulty: MealPlan.DifficultyLevel) -> [PlannedMeal] {
        return [
            // Balanced Dinner
            PlannedMeal(
                name: "Salmon with Vegetables",
                description: "Baked salmon with roasted seasonal vegetables",
                recipe: nil,
                ingredients: [
                    PlannedIngredient(name: "Salmon Fillet", amount: 150, unit: "g", category: .protein, estimatedCost: 800, isOptional: false, substitutes: ["Tuna Steak"]),
                    PlannedIngredient(name: "Broccoli", amount: 150, unit: "g", category: .vegetables, estimatedCost: 120, isOptional: false, substitutes: ["Green Beans"]),
                    PlannedIngredient(name: "Carrots", amount: 100, unit: "g", category: .vegetables, estimatedCost: 50, isOptional: false, substitutes: ["Bell Peppers"]),
                    PlannedIngredient(name: "Brown Rice", amount: 80, unit: "g", category: .grains, estimatedCost: 60, isOptional: false, substitutes: ["Quinoa"]),
                    PlannedIngredient(name: "Olive Oil", amount: 10, unit: "ml", category: .oils, estimatedCost: 20, isOptional: false, substitutes: []),
                    PlannedIngredient(name: "Lemon", amount: 0.5, unit: "piece", category: .fruits, estimatedCost: 20, isOptional: false, substitutes: [])
                ],
                nutrition: NutritionInfo(calories: 580, protein: 45, carbs: 48, fat: 22, fiber: 8, sugar: 10, sodium: 220, cholesterol: 85),
                cookingTime: 1800,
                prepTime: 900,
                servings: 1,
                mealType: .dinner,
                tags: ["omega-3", "balanced", "healthy"],
                imageURL: nil,
                difficulty: .intermediate
            )
        ]
    }
    
    private func getSnackTemplates(for goal: NutritionGoal) -> [PlannedMeal] {
        return [
            PlannedMeal(
                name: "Mixed Nuts",
                description: "Healthy mix of almonds, walnuts, and cashews",
                recipe: nil,
                ingredients: [
                    PlannedIngredient(name: "Mixed Nuts", amount: 30, unit: "g", category: .protein, estimatedCost: 150, isOptional: false, substitutes: [])
                ],
                nutrition: NutritionInfo(calories: 180, protein: 6, carbs: 6, fat: 16, fiber: 3, sugar: 2, sodium: 2, cholesterol: 0),
                cookingTime: 0,
                prepTime: 0,
                servings: 1,
                mealType: .snack,
                tags: ["healthy-fat", "protein"],
                imageURL: nil,
                difficulty: .beginner
            ),
            
            PlannedMeal(
                name: "Greek Yogurt with Berries",
                description: "Protein-rich snack with antioxidants",
                recipe: nil,
                ingredients: [
                    PlannedIngredient(name: "Greek Yogurt", amount: 100, unit: "g", category: .dairy, estimatedCost: 80, isOptional: false, substitutes: []),
                    PlannedIngredient(name: "Blueberries", amount: 50, unit: "g", category: .fruits, estimatedCost: 100, isOptional: false, substitutes: ["Strawberries"])
                ],
                nutrition: NutritionInfo(calories: 120, protein: 12, carbs: 15, fat: 2, fiber: 2, sugar: 12, sodium: 40, cholesterol: 10),
                cookingTime: 0,
                prepTime: 120,
                servings: 1,
                mealType: .snack,
                tags: ["high-protein", "antioxidants"],
                imageURL: nil,
                difficulty: .beginner
            )
        ]
    }
}
