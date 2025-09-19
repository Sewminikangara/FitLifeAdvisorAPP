//
//  NutritionEstimator.swift
//  FitLifeAdvisorApp
//
//

import Foundation

struct NutritionEstimator {
    static func defaultEstimate() -> NutritionInfo {
        // Balanced default suitable for tests
        return NutritionInfo(
            calories: 420,
            protein: 20,
            carbs: 45,
            fat: 14,
            fiber: 6,
            sugar: 8,
            sodium: 320,
            cholesterol: 0
        )
    }
}
