import Foundation

struct MealAnalytics: Identifiable {
    let id = UUID()
    let mealType: MealType
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let timestamp: Date
}

struct MealStat {
    let date: Date
    let totalCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
}

enum MealType: String, CaseIterable {
    case breakfast, lunch, dinner, snack
}