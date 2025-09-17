//
//  MealAnalyticsModels.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.
//

import SwiftUI
import Foundation

// MARK: - Core Meal Models

struct NutritionInfo: Codable, Equatable {
    let calories: Double
    let protein: Double // grams
    let carbs: Double   // grams
    let fat: Double     // grams
    let fiber: Double   // grams
    let sugar: Double   // grams
    let sodium: Double  // mg
    let cholesterol: Double // mg
    
    // Computed properties for display
    var caloriesFromProtein: Double { protein * 4 }
    var caloriesFromCarbs: Double { carbs * 4 }
    var caloriesFromFat: Double { fat * 9 }
}
struct SavedMeal: Identifiable, Codable, Equatable {
    let id: String
    let timestamp: Date
    let recognizedFoods: [RecognizedFood]
    let nutritionalSummary: NutritionalSummary
    let confidence: Double
    let mealType: MealType
    var userNotes: String?
    
    init(id: String = UUID().uuidString, timestamp: Date, recognizedFoods: [RecognizedFood], nutritionalSummary: NutritionalSummary, confidence: Double, mealType: MealType, userNotes: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.recognizedFoods = recognizedFoods
        self.nutritionalSummary = nutritionalSummary
        self.confidence = confidence
        self.mealType = mealType
        self.userNotes = userNotes
    }
    
    // Equatable conformance
    static func == (lhs: SavedMeal, rhs: SavedMeal) -> Bool {
        return lhs.id == rhs.id
    }
}

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"  
    case dinner = "Dinner"
    case snack = "Snack"
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "sunset.fill"
        case .snack: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .purple
        case .snack: return .pink
        }
    }
}

struct RecognizedFood: Identifiable, Codable {
    let id: String
    let name: String
    let category: FoodCategory
    let nutrition: NutritionInfo
    let estimatedWeight: Double
    let servingSize: String
    let confidence: Double
    let boundingBox: CGRect
    
    init(id: String = UUID().uuidString, name: String, category: FoodCategory, nutrition: NutritionInfo, estimatedWeight: Double, servingSize: String, confidence: Double, boundingBox: CGRect) {
        self.id = id
        self.name = name
        self.category = category
        self.nutrition = nutrition
        self.estimatedWeight = estimatedWeight
        self.servingSize = servingSize
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

struct NutritionalSummary: Codable {
    let totalCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let totalFiber: Double
    let totalSodium: Double
    let foodCount: Int
    let healthScore: Double
    let recommendations: [String]
    
    var macroDistribution: (protein: Double, carbs: Double, fat: Double) {
        let totalMacros = totalProtein * 4 + totalCarbs * 4 + totalFat * 9
        guard totalMacros > 0 else { return (0, 0, 0) }
        
        return (
            protein: (totalProtein * 4) / totalMacros * 100,
            carbs: (totalCarbs * 4) / totalMacros * 100,
            fat: (totalFat * 9) / totalMacros * 100
        )
    }
}

// MARK: - Analytics Models
struct DailyNutrition {
    let date: Date
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sodium: Double
    let mealsLogged: Int
    let averageHealthScore: Double
    
    init() {
        self.date = Date()
        self.calories = 0
        self.protein = 0
        self.carbs = 0
        self.fat = 0
        self.fiber = 0
        self.sodium = 0
        self.mealsLogged = 0
        self.averageHealthScore = 0
    }
    
    init(date: Date, calories: Double, protein: Double, carbs: Double, fat: Double, fiber: Double, sodium: Double, mealsLogged: Int, averageHealthScore: Double) {
        self.date = date
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sodium = sodium
        self.mealsLogged = mealsLogged
        self.averageHealthScore = averageHealthScore
    }
}

struct WeeklyAnalytics {
    let weekStartDate: Date
    let dailyCalories: [Double]
    let dailyHealthScores: [Double]
    let totalMeals: Int
    let averageCalories: Double
    let averageHealthScore: Double
    let mostFrequentFoodCategory: FoodCategory
    let improvementTrend: ImprovementTrend
    
    init() {
        self.weekStartDate = Date()
        self.dailyCalories = []
        self.dailyHealthScores = []
        self.totalMeals = 0
        self.averageCalories = 0
        self.averageHealthScore = 0
        self.mostFrequentFoodCategory = .other
        self.improvementTrend = .stable
    }
    
    init(weekStartDate: Date, dailyCalories: [Double], dailyHealthScores: [Double], totalMeals: Int, averageCalories: Double, averageHealthScore: Double, mostFrequentFoodCategory: FoodCategory, improvementTrend: ImprovementTrend) {
        self.weekStartDate = weekStartDate
        self.dailyCalories = dailyCalories
        self.dailyHealthScores = dailyHealthScores
        self.totalMeals = totalMeals
        self.averageCalories = averageCalories
        self.averageHealthScore = averageHealthScore
        self.mostFrequentFoodCategory = mostFrequentFoodCategory
        self.improvementTrend = improvementTrend
    }
}

enum ImprovementTrend: String, Codable {
    case improving = "Improving"
    case stable = "Stable"
    case declining = "Declining"
    
    var icon: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }
    
    var color: Color {
        switch self {
        case .improving: return .green
        case .stable: return .blue
        case .declining: return .red
        }
    }
}

struct NutritionGoals: Codable {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sodium: Double
    
    static func defaultGoals() -> NutritionGoals {
        return NutritionGoals(
            calories: 2000,
            protein: 150,
            carbs: 250,
            fat: 65,
            fiber: 25,
            sodium: 2300
        )
    }
}

struct NutritionInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let message: String
    let recommendation: String
    let priority: Priority
    
    enum InsightType {
        case success, warning, info, suggestion
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"  
            case .info: return "info.circle.fill"
            case .suggestion: return "lightbulb.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .warning: return .orange
            case .info: return .blue
            case .suggestion: return .purple
            }
        }
    }
    
    enum Priority: Int, Comparable {
        case low = 1, medium = 2, high = 3
        
        static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

// MARK: - Extensions
extension CGRect: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y, width, height
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        let width = try container.decode(CGFloat.self, forKey: .width)
        let height = try container.decode(CGFloat.self, forKey: .height)
        self.init(x: x, y: y, width: width, height: height)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(origin.x, forKey: .x)
        try container.encode(origin.y, forKey: .y)
        try container.encode(size.width, forKey: .width)
        try container.encode(size.height, forKey: .height)
    }
}
