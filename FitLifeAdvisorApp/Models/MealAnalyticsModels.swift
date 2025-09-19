import Foundation

struct MealAnalytics: Identifiable {
    let id = UUID()
    let mealType: AnalyticsMealType
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

enum AnalyticsMealType: String, CaseIterable {
    case breakfast, lunch, dinner, snack
}