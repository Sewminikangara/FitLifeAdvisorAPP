//
//  MealTrackingManager.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.
//

import SwiftUI
import Foundation
import Combine

//Meal Tracking Manager
@MainActor
class MealTrackingManager: ObservableObject {
    @Published var savedMeals: [SavedMeal] = []
    @Published var dailyNutrition: DailyNutrition = DailyNutrition()
    @Published var weeklyAnalytics: WeeklyAnalytics = WeeklyAnalytics()
    @Published var nutritionGoals: NutritionGoals = NutritionGoals.defaultGoals()
    @Published var insights: [NutritionInsight] = []
    
    private let userDefaults = UserDefaults.standard
    private let mealsKey = "SavedMeals"
    private let goalsKey = "NutritionGoals"
    
    init() {
        loadSavedMeals()
        loadNutritionGoals()
        updateAnalytics()
        generateInsights()
    }
    
    //  Save Meal
    func saveMeal(from analysis: AIFoodRecognitionService) {
        guard !analysis.recognizedFoods.isEmpty,
              let summary = analysis.nutritionalSummary else {
            return
        }
        
        let savedMeal = SavedMeal(
            id: UUID().uuidString,
            timestamp: Date(),
            recognizedFoods: analysis.recognizedFoods,
            nutritionalSummary: summary,
            confidence: analysis.confidence,
            mealType: determineMealType(for: Date()),
            userNotes: nil
        )
        
        savedMeals.insert(savedMeal, at: 0)
        saveMealsToStorage()
        updateAnalytics()
        generateInsights()
    }
    
    // Analytics Updates
    private func updateAnalytics() {
        updateDailyNutrition()
        updateWeeklyAnalytics()
    }
    
    private func updateDailyNutrition() {
        let today = Calendar.current.startOfDay(for: Date())
        let todaysMeals = savedMeals.filter { 
            Calendar.current.isDate($0.timestamp, inSameDayAs: today)
        }
        
        let totalCalories = todaysMeals.reduce(0) { $0 + $1.nutritionalSummary.totalCalories }
        let totalProtein = todaysMeals.reduce(0) { $0 + $1.nutritionalSummary.totalProtein }
        let totalCarbs = todaysMeals.reduce(0) { $0 + $1.nutritionalSummary.totalCarbs }
        let totalFat = todaysMeals.reduce(0) { $0 + $1.nutritionalSummary.totalFat }
        let totalFiber = todaysMeals.reduce(0) { $0 + $1.nutritionalSummary.totalFiber }
        let totalSodium = todaysMeals.reduce(0) { $0 + $1.nutritionalSummary.totalSodium }
        
        dailyNutrition = DailyNutrition(
            date: today,
            calories: totalCalories,
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat,
            fiber: totalFiber,
            sodium: totalSodium,
            mealsLogged: todaysMeals.count,
            averageHealthScore: todaysMeals.isEmpty ? 0 : 
                todaysMeals.reduce(0) { $0 + $1.nutritionalSummary.healthScore } / Double(todaysMeals.count)
        )
    }
    
    private func updateWeeklyAnalytics() {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        let weekMeals = savedMeals.filter { $0.timestamp >= weekAgo }
        
        var dailyCalories: [Double] = []
        var dailyHealthScores: [Double] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            let dayMeals = weekMeals.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
            
            let dayCalories = dayMeals.reduce(0) { $0 + $1.nutritionalSummary.totalCalories }
            let dayHealthScore = dayMeals.isEmpty ? 0 : 
                dayMeals.reduce(0) { $0 + $1.nutritionalSummary.healthScore } / Double(dayMeals.count)
            
            dailyCalories.append(dayCalories)
            dailyHealthScores.append(dayHealthScore)
        }
        
        weeklyAnalytics = WeeklyAnalytics(
            weekStartDate: weekAgo,
            dailyCalories: dailyCalories.reversed(),
            dailyHealthScores: dailyHealthScores.reversed(),
            totalMeals: weekMeals.count,
            averageCalories: dailyCalories.isEmpty ? 0 : dailyCalories.reduce(0, +) / Double(dailyCalories.count),
            averageHealthScore: dailyHealthScores.isEmpty ? 0 : dailyHealthScores.reduce(0, +) / Double(dailyHealthScores.count),
            mostFrequentFoodCategory: getMostFrequentCategory(from: weekMeals),
            improvementTrend: calculateImprovementTrend(dailyHealthScores)
        )
    }
    
    // Insights Generation
    private func generateInsights() {
        var newInsights: [NutritionInsight] = []
        
        // Calorie Goal Insight
        let calorieProgress = dailyNutrition.calories / nutritionGoals.calories
        if calorieProgress > 1.2 {
            newInsights.append(NutritionInsight(
                type: .warning,
                title: "High Calorie Intake",
                message: "You've consumed \(Int((calorieProgress - 1) * 100))% more calories than your goal today.",
                recommendation: "Consider lighter options for your next meal or increase physical activity.",
                priority: .high
            ))
        } else if calorieProgress < 0.7 {
            newInsights.append(NutritionInsight(
                type: .info,
                title: "Low Calorie Intake",
                message: "You're \(Int((1 - calorieProgress) * 100))% below your calorie goal.",
                recommendation: "Make sure you're eating enough to fuel your body properly.",
                priority: .medium
            ))
        }
        
        // Protein Insight
        let proteinProgress = dailyNutrition.protein / nutritionGoals.protein
        if proteinProgress < 0.8 {
            newInsights.append(NutritionInsight(
                type: .suggestion,
                title: "Increase Protein Intake",
                message: "You need \(Int(nutritionGoals.protein - dailyNutrition.protein))g more protein today.",
                recommendation: "Add lean meats, fish, eggs, or plant-based proteins to reach your goal.",
                priority: .medium
            ))
        }
        
        // Health Score Trend
        if weeklyAnalytics.improvementTrend == .improving {
            newInsights.append(NutritionInsight(
                type: .success,
                title: "Improving Health Score! 📈",
                message: "Your meal quality has improved this week with an average score of \(String(format: "%.1f", weeklyAnalytics.averageHealthScore))/10.",
                recommendation: "Keep up the great work! Focus on maintaining this positive trend.",
                priority: .high
            ))
        } else if weeklyAnalytics.improvementTrend == .declining {
            newInsights.append(NutritionInsight(
                type: .warning,
                title: "Health Score Declining",
                message: "Your meal quality has decreased this week.",
                recommendation: "Try to include more vegetables, fruits, and whole foods in your meals.",
                priority: .high
            ))
        }
        
        // Fiber Insight
        if dailyNutrition.fiber < nutritionGoals.fiber * 0.6 {
            newInsights.append(NutritionInsight(
                type: .suggestion,
                title: "Need More Fiber",
                message: "You've only consumed \(String(format: "%.1f", dailyNutrition.fiber))g of your \(String(format: "%.0f", nutritionGoals.fiber))g fiber goal.",
                recommendation: "Add fruits, vegetables, whole grains, or legumes to increase fiber intake.",
                priority: .medium
            ))
        }
        
        // Sodium Warning
        if dailyNutrition.sodium > nutritionGoals.sodium {
            newInsights.append(NutritionInsight(
                type: .warning,
                title: "High Sodium Intake",
                message: "You've exceeded your daily sodium limit by \(Int(dailyNutrition.sodium - nutritionGoals.sodium))mg.",
                recommendation: "Drink more water and choose low-sodium options for your next meals.",
                priority: .high
            ))
        }
        
        insights = newInsights
    }
    
    // Utility Functions
    private func determineMealType(for date: Date) -> MealType {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<11: return .breakfast
        case 11..<15: return .lunch
        case 15..<18: return .snack
        case 18..<23: return .dinner
        default: return .snack
        }
    }
    
    private func getMostFrequentCategory(from meals: [SavedMeal]) -> FoodCategory {
        var categoryCount: [FoodCategory: Int] = [:]
        
        for meal in meals {
            for food in meal.recognizedFoods {
                categoryCount[food.category, default: 0] += 1
            }
        }
        
        return categoryCount.max(by: { $0.value < $1.value })?.key ?? .other
    }
    
    private func calculateImprovementTrend(_ scores: [Double]) -> ImprovementTrend {
        guard scores.count >= 3 else { return .stable }
        
        let recent = Array(scores.suffix(3))
        let earlier = Array(scores.prefix(3))
        
        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let earlierAvg = earlier.reduce(0, +) / Double(earlier.count)
        
        let difference = recentAvg - earlierAvg
        
        if difference > 0.5 { return .improving }
        if difference < -0.5 { return .declining }
        return .stable
    }
    
    // Goals Management
    func updateNutritionGoals(_ goals: NutritionGoals) {
        nutritionGoals = goals
        saveGoalsToStorage()
        generateInsights()
    }
    
    // Data Persistence
    private func saveMealsToStorage() {
        if let encoded = try? JSONEncoder().encode(savedMeals) {
            userDefaults.set(encoded, forKey: mealsKey)
        }
    }
    
    private func loadSavedMeals() {
        if let data = userDefaults.data(forKey: mealsKey),
           let decoded = try? JSONDecoder().decode([SavedMeal].self, from: data) {
            savedMeals = decoded
        }
    }
    
    private func saveGoalsToStorage() {
        if let encoded = try? JSONEncoder().encode(nutritionGoals) {
            userDefaults.set(encoded, forKey: goalsKey)
        }
    }
    
    private func loadNutritionGoals() {
        if let data = userDefaults.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode(NutritionGoals.self, from: data) {
            nutritionGoals = decoded
        }
    }
    
    //  Meal Management
    func deleteMeal(_ meal: SavedMeal) {
        savedMeals.removeAll { $0.id == meal.id }
        saveMealsToStorage()
        updateAnalytics()
        generateInsights()
    }
    
    func updateMealNotes(_ mealId: String, notes: String) {
        if let index = savedMeals.firstIndex(where: { $0.id == mealId }) {
            savedMeals[index].userNotes = notes.isEmpty ? nil : notes
            saveMealsToStorage()
        }
    }
}


