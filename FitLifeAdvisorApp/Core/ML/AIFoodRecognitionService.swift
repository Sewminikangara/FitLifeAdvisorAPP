//
//  AIFoodRecognitionService.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.

import SwiftUI
import Foundation
import Vision
import CoreML
import UIKit

// MARK: - AI Food Recognition Service
@MainActor
class AIFoodRecognitionService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var recognizedFoods: [RecognizedFood] = []
    @Published var nutritionalSummary: NutritionalSummary?
    @Published var confidence: Double = 0.0
    @Published var errorMessage: String?
    @Published var analysisProgress: Double = 0.0
    
    private let mlKitManager = MLKitManager()
    
    // MARK: - Main AI Analysis Function
    func analyzeMealFromImage(_ image: UIImage) async {
        isAnalyzing = true
        errorMessage = nil
        analysisProgress = 0.0
        recognizedFoods = []
        
        do {
            // Step 1: Image preprocessing (20%)
            updateProgress(0.2, message: "Preparing image...")
            let processedImage = preprocessImage(image)
            
            // Step 2: AI Food Detection (40%)
            updateProgress(0.4, message: "Detecting foods...")
            let detectedFoods = await detectFoodsInImage(processedImage)
            
            // Step 3: Nutritional Analysis (60%)
            updateProgress(0.6, message: "Analyzing nutrition...")
            let nutritionData = await getNutritionalData(for: detectedFoods)
            
            // Step 4: Portion Estimation (80%)
            updateProgress(0.8, message: "Estimating portions...")
            let portionEstimates = await estimatePortions(for: detectedFoods, in: processedImage)
            
            // Step 5: Final Calculations (100%)
            updateProgress(1.0, message: "Finalizing analysis...")
            let finalResults = combineResultsWithPortions(nutritionData, portionEstimates)
            
            // Update UI
            self.recognizedFoods = finalResults
            self.nutritionalSummary = calculateNutritionalSummary(from: finalResults)
            self.confidence = calculateOverallConfidence(from: finalResults)
            
        } catch {
            self.errorMessage = "Analysis failed: \(error.localizedDescription)"
        }
        
        isAnalyzing = false
        analysisProgress = 0.0
    }
    
    // MARK: - Image Preprocessing
    private func preprocessImage(_ image: UIImage) -> UIImage {
        // Resize image for optimal AI processing
        let targetSize = CGSize(width: 512, height: 512)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    // MARK: - AI Food Detection
    private func detectFoodsInImage(_ image: UIImage) async -> [DetectedFood] {
        // Simulate advanced AI food detection
        // In a real app, this would use CoreML models like YOLOv5 or custom trained models
        
        let mockFoods = [
            DetectedFood(
                name: "Grilled Chicken Breast",
                category: .protein,
                confidence: 0.92,
                boundingBox: CGRect(x: 0.2, y: 0.3, width: 0.3, height: 0.4),
                foodId: "chicken_breast_grilled"
            ),
            DetectedFood(
                name: "Brown Rice",
                category: .grain,
                confidence: 0.87,
                boundingBox: CGRect(x: 0.6, y: 0.4, width: 0.25, height: 0.3),
                foodId: "brown_rice_cooked"
            ),
            DetectedFood(
                name: "Steamed Broccoli",
                category: .vegetable,
                confidence: 0.94,
                boundingBox: CGRect(x: 0.1, y: 0.7, width: 0.4, height: 0.25),
                foodId: "broccoli_steamed"
            )
        ]
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        return mockFoods
    }
    
    // MARK: - Nutritional Data Retrieval
    private func getNutritionalData(for foods: [DetectedFood]) async -> [FoodNutritionData] {
        var nutritionData: [FoodNutritionData] = []
        
        for food in foods {
            let nutrition = await fetchNutritionData(for: food.foodId)
            nutritionData.append(FoodNutritionData(
                food: food,
                nutrition: nutrition
            ))
        }
        
        return nutritionData
    }
    
    private func fetchNutritionData(for foodId: String) async -> NutritionInfo {
        // Comprehensive nutrition database
        let nutritionDatabase: [String: NutritionInfo] = [
            "chicken_breast_grilled": NutritionInfo(
                calories: 165, protein: 31, carbs: 0, fat: 3.6,
                fiber: 0, sugar: 0, sodium: 74, cholesterol: 85
            ),
            "brown_rice_cooked": NutritionInfo(
                calories: 112, protein: 2.3, carbs: 23, fat: 0.9,
                fiber: 1.8, sugar: 0.4, sodium: 5, cholesterol: 0
            ),
            "broccoli_steamed": NutritionInfo(
                calories: 27, protein: 3, carbs: 5.5, fat: 0.3,
                fiber: 2.3, sugar: 1.9, sodium: 41, cholesterol: 0
            ),
            "salmon_fillet": NutritionInfo(
                calories: 206, protein: 22, carbs: 0, fat: 12,
                fiber: 0, sugar: 0, sodium: 59, cholesterol: 63
            ),
            "quinoa_cooked": NutritionInfo(
                calories: 143, protein: 5.2, carbs: 26, fat: 2.8,
                fiber: 2.8, sugar: 0.9, sodium: 13, cholesterol: 0
            ),
            "avocado_half": NutritionInfo(
                calories: 160, protein: 2, carbs: 8.5, fat: 14.7,
                fiber: 6.7, sugar: 0.7, sodium: 7, cholesterol: 0
            ),
            "sweet_potato": NutritionInfo(
                calories: 112, protein: 2, carbs: 26, fat: 0.1,
                fiber: 3.9, sugar: 5.4, sodium: 7, cholesterol: 0
            ),
            "spinach_fresh": NutritionInfo(
                calories: 7, protein: 0.9, carbs: 1.1, fat: 0.1,
                fiber: 0.7, sugar: 0.1, sodium: 24, cholesterol: 0
            )
        ]
        
        return nutritionDatabase[foodId] ?? NutritionInfo(
            calories: 100, protein: 5, carbs: 15, fat: 3,
            fiber: 2, sugar: 3, sodium: 50, cholesterol: 0
        )
    }
    
    // MARK: - Portion Estimation
    private func estimatePortions(for foods: [DetectedFood], in image: UIImage) async -> [PortionEstimate] {
        var portions: [PortionEstimate] = []
        
        for food in foods {
            let estimatedWeight = estimateWeightFromBoundingBox(food.boundingBox, category: food.category)
            let servingSize = calculateServingSize(weight: estimatedWeight, category: food.category)
            
            portions.append(PortionEstimate(
                food: food,
                estimatedWeight: estimatedWeight,
                servingSize: servingSize,
                confidence: food.confidence * 0.8 // Slightly lower confidence for portion estimation
            ))
        }
        
        return portions
    }
    
    private func estimateWeightFromBoundingBox(_ boundingBox: CGRect, category: FoodCategory) -> Double {
        let area = boundingBox.width * boundingBox.height
        
        // Different estimation models based on food category
        switch category {
        case .protein:
            return area * 300 // Approximate weight in grams for protein
        case .grain:
            return area * 150
        case .vegetable:
            return area * 100
        case .fruit:
            return area * 120
        case .dairy:
            return area * 200
        default:
            return area * 150
        }
    }
    
    private func calculateServingSize(weight: Double, category: FoodCategory) -> String {
        switch category {
        case .protein:
            return "\(Int(weight))g (\(String(format: "%.1f", weight/28.35))oz)"
        case .grain:
            return "\(String(format: "%.1f", weight/100)) cup"
        case .vegetable:
            return "\(Int(weight))g (\(String(format: "%.1f", weight/100)) cup)"
        case .fruit:
            if weight > 200 {
                return "1 large piece"
            } else if weight > 100 {
                return "1 medium piece"
            } else {
                return "1 small piece"
            }
        default:
            return "\(Int(weight))g"
        }
    }
    
    // MARK: - Results Combination
    private func combineResultsWithPortions(_ nutritionData: [FoodNutritionData], _ portionEstimates: [PortionEstimate]) -> [RecognizedFood] {
        var results: [RecognizedFood] = []
        
        for (nutrition, portion) in zip(nutritionData, portionEstimates) {
            // Scale nutrition based on estimated portion
            let scaleFactor = portion.estimatedWeight / 100.0 // Assuming nutrition data is per 100g
            let scaledNutrition = scaleNutrition(nutrition.nutrition, by: scaleFactor)
            
            results.append(RecognizedFood(
                id: UUID().uuidString,
                name: nutrition.food.name,
                category: nutrition.food.category,
                nutrition: scaledNutrition,
                estimatedWeight: portion.estimatedWeight,
                servingSize: portion.servingSize,
                confidence: portion.confidence,
                boundingBox: nutrition.food.boundingBox
            ))
        }
        
        return results
    }
    
    private func scaleNutrition(_ nutrition: NutritionInfo, by factor: Double) -> NutritionInfo {
        return NutritionInfo(
            calories: nutrition.calories * factor,
            protein: (nutrition.protein ?? 0) * factor,
            carbs: (nutrition.carbs ?? 0) * factor,
            fat: (nutrition.fat ?? 0) * factor,
            fiber: (nutrition.fiber ?? 0) * factor,
            sugar: (nutrition.sugar ?? 0) * factor,
            sodium: (nutrition.sodium ?? 0) * factor,
            cholesterol: (nutrition.cholesterol ?? 0) * factor
        )
    }
    
    // MARK: - Summary Calculations
    private func calculateNutritionalSummary(from foods: [RecognizedFood]) -> NutritionalSummary {
        let totalCalories = foods.reduce(0) { $0 + $1.nutrition.calories }
        let totalProtein = foods.reduce(0) { $0 + ($1.nutrition.protein ?? 0) }
        let totalCarbs = foods.reduce(0) { $0 + ($1.nutrition.carbs ?? 0) }
        let totalFat = foods.reduce(0) { $0 + ($1.nutrition.fat ?? 0) }
        let totalFiber = foods.reduce(0) { $0 + ($1.nutrition.fiber ?? 0) }
        let totalSodium = foods.reduce(0) { $0 + ($1.nutrition.sodium ?? 0) }
        
        return NutritionalSummary(
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            totalFiber: totalFiber,
            totalSodium: totalSodium,
            foodCount: foods.count,
            healthScore: calculateHealthScore(foods: foods),
            recommendations: generateRecommendations(foods: foods)
        )
    }
    
    private func calculateOverallConfidence(from foods: [RecognizedFood]) -> Double {
        guard !foods.isEmpty else { return 0.0 }
        return foods.reduce(0) { $0 + $1.confidence } / Double(foods.count)
    }
    
    private func calculateHealthScore(foods: [RecognizedFood]) -> Double {
        var score = 5.0 // Base score out of 10
        
        // Add points for vegetables and fruits
        let vegetableFruitCount = foods.filter { $0.category == .vegetable || $0.category == .fruit }.count
        score += Double(vegetableFruitCount) * 1.5
        
        // Add points for protein
        let proteinCount = foods.filter { $0.category == .protein }.count
        score += Double(proteinCount) * 1.0
        
        // Subtract points for high sodium
        let totalSodium = foods.reduce(0) { $0 + ($1.nutrition.sodium ?? 0) }
        if totalSodium > 2000 { score -= 2.0 }
        else if totalSodium > 1500 { score -= 1.0 }
        
        return min(10.0, max(0.0, score))
    }
    
    private func generateRecommendations(foods: [RecognizedFood]) -> [String] {
        var recommendations: [String] = []
        
        let hasVegetables = foods.contains { $0.category == .vegetable }
        let hasProtein = foods.contains { $0.category == .protein }
        let hasFruits = foods.contains { $0.category == .fruit }
        let totalCalories = foods.reduce(0) { $0 + $1.nutrition.calories }
        
        if !hasVegetables {
            recommendations.append("🥕 Add more vegetables for essential vitamins and minerals")
        }
        
        if !hasProtein {
            recommendations.append("🍗 Include protein to support muscle health and satiety")
        }
        
        if !hasFruits {
            recommendations.append("🍎 Add fruits for natural antioxidants and fiber")
        }
        
        if totalCalories > 800 {
            recommendations.append("⚖️ Consider portion control - this meal is quite calorie-dense")
        }
        
        if recommendations.isEmpty {
            recommendations.append("✨ Great balanced meal! Keep up the healthy eating habits")
        }
        
        return recommendations
    }
    
    // MARK: - Utility Functions
    private func updateProgress(_ progress: Double, message: String) {
        Task { @MainActor in
            self.analysisProgress = progress
        }
    }
    
    func clearResults() {
        recognizedFoods = []
        nutritionalSummary = nil
        confidence = 0.0
        errorMessage = nil
        analysisProgress = 0.0
    }
}

// MARK: - Supporting Models
struct DetectedFood {
    let name: String
    let category: FoodCategory
    let confidence: Double
    let boundingBox: CGRect
    let foodId: String
}

struct FoodNutritionData {
    let food: DetectedFood
    let nutrition: NutritionInfo
}

struct PortionEstimate {
    let food: DetectedFood
    let estimatedWeight: Double
    let servingSize: String
    let confidence: Double
}
