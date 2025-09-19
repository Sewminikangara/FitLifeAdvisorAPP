//
//  MealAnalysisManagerTests.swift
//  FitLifeAdvisorAppTests
//
//  unit tests for MealAnalysisManager


import XCTest
import UIKit
@testable import FitLifeAdvisorApp

@MainActor
final class MealAnalysisManagerTests: XCTestCase {
    
    //  Test Properties
    var mealAnalysisManager: MealAnalysisManager!
    var testImage: UIImage!
    
    // Setup & Teardown
    
    override func setUpWithError() throws {
        super.setUp()
        mealAnalysisManager = MealAnalysisManager.shared
        
        // Create a test image
        testImage = createTestImage()
        
        // Clear any existing saved meals
        mealAnalysisManager.savedMeals.removeAll()
    }
    
    override func tearDownWithError() throws {
        mealAnalysisManager = nil
        testImage = nil
        super.tearDown()
    }
    
    //  Helper Methods
    
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        UIColor.blue.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    private func createMockFoodItem() -> FoodItem {
        let nutrition = NutritionInfo(
            calories: 250.0,
            protein: 20.0,
            carbs: 30.0,
            fat: 10.0,
            fiber: 5.0,
            sugar: 8.0,
            sodium: 400.0,
            cholesterol: 50.0
        )
        
        let portion = PortionInfo(
            servingSize: "1 cup",
            weight: 150.0,
            unit: "grams"
        )
        
        return FoodItem(
            name: "Test Food",
            confidence: 0.85,
            nutrition: nutrition,
            portion: portion
        )
    }
    
    private func createMockMealAnalysisResult() -> MealAnalysisResult {
        let foodItems = [createMockFoodItem()]
        
        return MealAnalysisResult(
            image: testImage,
            foodItems: foodItems,
            totalNutrition: foodItems.first!.nutrition,
            confidence: 0.85,
            analysisTime: Date()
        )
    }
    
    // Initialization Tests
    
    func testMealAnalysisManagerInitialization() {
        // Given & When - MealAnalysisManager is initialized in setup
        
        // Then
        XCTAssertFalse(mealAnalysisManager.isAnalyzing, "Should not be analyzing initially")
        XCTAssertNil(mealAnalysisManager.lastAnalysisResult, "Last analysis result should be nil initially")
        XCTAssertTrue(mealAnalysisManager.savedMeals.isEmpty, "Saved meals should be empty initially")
        XCTAssertNil(mealAnalysisManager.errorMessage, "Error message should be nil initially")
    }
    
    func testMealAnalysisManagerSingleton() {
        // Given & When
        let instance1 = MealAnalysisManager.shared
        let instance2 = MealAnalysisManager.shared
        
        // Then
        XCTAssertTrue(instance1 === instance2, "Should return the same singleton instance")
    }
    
    // Data Model Tests
    
    func testNutritionInfoInitialization() {
        // Given & When
        let nutrition = NutritionInfo(
            calories: 300.0,
            protein: 25.0,
            carbs: 40.0,
            fat: 12.0,
            fiber: 6.0,
            sugar: 10.0,
            sodium: 500.0,
            cholesterol: 60.0
        )
        
        // Then
        XCTAssertEqual(nutrition.calories, 300.0)
        XCTAssertEqual(nutrition.protein, 25.0)
        XCTAssertEqual(nutrition.carbs, 40.0)
        XCTAssertEqual(nutrition.fat, 12.0)
        XCTAssertEqual(nutrition.fiber, 6.0)
        XCTAssertEqual(nutrition.sugar, 10.0)
        XCTAssertEqual(nutrition.sodium, 500.0)
        XCTAssertEqual(nutrition.cholesterol, 60.0)
    }
    
    func testNutritionInfoComputedProperties() {
        // Given
        let nutrition = NutritionInfo(
            calories: 300.0,
            protein: 25.0,
            carbs: 40.0,
            fat: 12.0,
            fiber: 6.0,
            sugar: 10.0,
            sodium: 500.0,
            cholesterol: 60.0
        )
        
        // When & Then
        XCTAssertEqual(nutrition.caloriesFromProtein, 100.0, "Protein calories should be protein * 4")
        XCTAssertEqual(nutrition.caloriesFromCarbs, 160.0, "Carb calories should be carbs * 4")
        XCTAssertEqual(nutrition.caloriesFromFat, 108.0, "Fat calories should be fat * 9")
    }
    
    func testFoodItemInitialization() {
        // Given
        let nutrition = NutritionInfo(calories: 200, protein: 15, carbs: 25, fat: 8, fiber: 4, sugar: 6, sodium: 300, cholesterol: 40)
        let portion = PortionInfo(servingSize: "1 serving", weight: 100.0, unit: "grams")
        
        // When
        let foodItem = FoodItem(
            name: "Test Food",
            confidence: 0.75,
            nutrition: nutrition,
            portion: portion
        )
        
        // Then
        XCTAssertEqual(foodItem.name, "Test Food")
        XCTAssertEqual(foodItem.confidence, 0.75)
        XCTAssertEqual(foodItem.nutrition.calories, 200)
        XCTAssertEqual(foodItem.portion.servingSize, "1 serving")
        XCTAssertTrue(foodItem.isSelected, "Should be selected by default")
    }
    
    func testFoodItemEquality() {
        // Given
        let foodItem1 = createMockFoodItem()
        let foodItem2 = createMockFoodItem()
        
        // When & Then
        XCTAssertNotEqual(foodItem1, foodItem2, "Different food items should not be equal")
        XCTAssertEqual(foodItem1, foodItem1, "Same food item should be equal to itself")
    }
    
    func testPortionInfoInitialization() {
        // Given & When
        let portion = PortionInfo(
            servingSize: "2 cups",
            weight: 240.0,
            unit: "grams"
        )
        
        // Then
        XCTAssertEqual(portion.servingSize, "2 cups")
        XCTAssertEqual(portion.weight, 240.0)
        XCTAssertEqual(portion.unit, "grams")
    }
    
    //  Image Analysis Tests
    
    func testImageAnalysisProperties() {
        // Given & When
        let analysis = ImageAnalysis(
            brightness: 0.7,
            colorComplexity: 0.6,
            dominantColors: ["green", "brown"],
            aspectRatio: 1.5
        )
        
        // Then
        XCTAssertEqual(analysis.brightness, 0.7)
        XCTAssertEqual(analysis.colorComplexity, 0.6)
        XCTAssertEqual(analysis.dominantColors, ["green", "brown"])
        XCTAssertEqual(analysis.aspectRatio, 1.5)
    }
    
    func testImageAnalysisColorDetection() {
        // Given
        let greenAnalysis = ImageAnalysis(
            brightness: 0.7,
            colorComplexity: 0.6,
            dominantColors: ["green"],
            aspectRatio: 1.0
        )
        
        let brownAnalysis = ImageAnalysis(
            brightness: 0.5,
            colorComplexity: 0.4,
            dominantColors: ["brown"],
            aspectRatio: 1.0
        )
        
        let redAnalysis = ImageAnalysis(
            brightness: 0.5,
            colorComplexity: 0.4,
            dominantColors: ["red"],
            aspectRatio: 1.0
        )
        
        // When & Then
        XCTAssertTrue(greenAnalysis.hasSignificantGreen(), "Should detect significant green")
        XCTAssertTrue(brownAnalysis.hasSignificantBrown(), "Should detect significant brown")
        XCTAssertTrue(redAnalysis.hasSignificantRed(), "Should detect significant red")
        XCTAssertFalse(brownAnalysis.hasSignificantGreen(), "Should not detect green when not present")
    }
    
    func testImageAnalysisBrightnessDetection() {
        // Given
        let brightAnalysis = ImageAnalysis(
            brightness: 0.9,
            colorComplexity: 0.3,
            dominantColors: [],
            aspectRatio: 1.0
        )
        
        let darkAnalysis = ImageAnalysis(
            brightness: 0.3,
            colorComplexity: 0.3,
            dominantColors: [],
            aspectRatio: 1.0
        )
        
        // When & Then
        XCTAssertTrue(brightAnalysis.hasSignificantWhite(), "Should detect white in bright images")
        XCTAssertFalse(darkAnalysis.hasSignificantWhite(), "Should not detect white in dark images")
    }
    
    // Meal Analysis Result Tests
    
    func testMealAnalysisResultInitialization() {
        // Given
        let foodItems = [createMockFoodItem()]
        let totalNutrition = foodItems.first!.nutrition
        let analysisTime = Date()
        
        // When
        let result = MealAnalysisResult(
            image: testImage,
            foodItems: foodItems,
            totalNutrition: totalNutrition,
            confidence: 0.8,
            analysisTime: analysisTime
        )
        
        // Then
        XCTAssertEqual(result.image, testImage)
        XCTAssertEqual(result.foodItems.count, 1)
        XCTAssertEqual(result.totalNutrition.calories, 250.0)
        XCTAssertEqual(result.confidence, 0.8)
        XCTAssertEqual(result.analysisTime, analysisTime)
    }
    
    //  Saved Meal Tests
    
    func testSavedMealInitialization() {
        // Given
        let foodItems = [createMockFoodItem()]
        let nutrition = foodItems.first!.nutrition
        let imageData = testImage.jpegData(compressionQuality: 0.7)
        let timestamp = Date()
        
        // When
        let savedMeal = SavedMeal(
            name: "Test Meal",
            image: imageData,
            foodItems: foodItems,
            totalNutrition: nutrition,
            timestamp: timestamp,
            mealType: .lunch
        )
        
        // Then
        XCTAssertEqual(savedMeal.name, "Test Meal")
        XCTAssertNotNil(savedMeal.image)
        XCTAssertEqual(savedMeal.foodItems.count, 1)
        XCTAssertEqual(savedMeal.totalNutrition.calories, 250.0)
        XCTAssertEqual(savedMeal.timestamp, timestamp)
        XCTAssertEqual(savedMeal.mealType, .lunch)
    }
    
    func testSavedMealEquality() {
        // Given
        let savedMeal1 = SavedMeal(
            name: "Meal 1",
            image: nil,
            foodItems: [],
            totalNutrition: NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, sugar: 0, sodium: 0, cholesterol: 0),
            timestamp: Date(),
            mealType: .breakfast
        )
        
        let savedMeal2 = SavedMeal(
            name: "Meal 2",
            image: nil,
            foodItems: [],
            totalNutrition: NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, sugar: 0, sodium: 0, cholesterol: 0),
            timestamp: Date(),
            mealType: .dinner
        )
        
        // When & Then
        XCTAssertNotEqual(savedMeal1, savedMeal2, "Different saved meals should not be equal")
        XCTAssertEqual(savedMeal1, savedMeal1, "Same saved meal should be equal to itself")
    }
    
    //  Meal Type Tests
    
    func testMealTypeEnum() {
        // Given & When & Then
        XCTAssertEqual(MealType.breakfast.rawValue, "Breakfast")
        XCTAssertEqual(MealType.lunch.rawValue, "Lunch")
        XCTAssertEqual(MealType.dinner.rawValue, "Dinner")
        XCTAssertEqual(MealType.snack.rawValue, "Snack")
        
        XCTAssertEqual(MealType.breakfast.icon, "sun.rise.fill")
        XCTAssertEqual(MealType.lunch.icon, "sun.max.fill")
        XCTAssertEqual(MealType.dinner.icon, "moon.fill")
        XCTAssertEqual(MealType.snack.icon, "heart.fill")
        
        XCTAssertEqual(MealType.breakfast.color, .orange)
        XCTAssertEqual(MealType.lunch.color, .yellow)
        XCTAssertEqual(MealType.dinner.color, .purple)
        XCTAssertEqual(MealType.snack.color, .pink)
    }
    
    func testMealTypeAllCases() {
        // Given & When
        let allCases = MealType.allCases
        
        // Then
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.breakfast))
        XCTAssertTrue(allCases.contains(.lunch))
        XCTAssertTrue(allCases.contains(.dinner))
        XCTAssertTrue(allCases.contains(.snack))
    }
    
    // Error Handling Tests
    
    func testMealAnalysisErrorDescriptions() {
        // Given & When & Then
        XCTAssertEqual(MealAnalysisError.noFoodDetected.errorDescription, 
                      "No food items were detected in the image. Please try again with a clearer photo.")
        XCTAssertEqual(MealAnalysisError.lowConfidence.errorDescription, 
                      "The analysis confidence is too low. Please retake the photo with better lighting.")
        XCTAssertEqual(MealAnalysisError.networkError.errorDescription, 
                      "Network error occurred. Please check your connection and try again.")
        XCTAssertEqual(MealAnalysisError.imageProcessingError.errorDescription, 
                      "Failed to process the image. Please try with a different photo.")
        XCTAssertEqual(MealAnalysisError.nutritionDataUnavailable.errorDescription, 
                      "Nutrition data is currently unavailable. Please try again later.")
    }
    
    //  Meal Management Tests
    
    func testSaveMeal() {
        // Given
        let result = createMockMealAnalysisResult()
        let mealName = "Test Saved Meal"
        let mealType = MealType.dinner
        let initialCount = mealAnalysisManager.savedMeals.count
        
        // When
        mealAnalysisManager.saveMeal(result, name: mealName, mealType: mealType)
        
        // Then
        XCTAssertEqual(mealAnalysisManager.savedMeals.count, initialCount + 1, "Should add one saved meal")
        
        let savedMeal = mealAnalysisManager.savedMeals.last
        XCTAssertNotNil(savedMeal, "Should have a saved meal")
        XCTAssertEqual(savedMeal?.name, mealName, "Should save correct meal name")
        XCTAssertEqual(savedMeal?.mealType, mealType, "Should save correct meal type")
        XCTAssertEqual(savedMeal?.totalNutrition.calories, result.totalNutrition.calories, "Should save correct nutrition")
    }
    
    func testDeleteMeal() {
        // Given
        let result = createMockMealAnalysisResult()
        mealAnalysisManager.saveMeal(result, name: "Test Meal", mealType: .lunch)
        let savedMeal = mealAnalysisManager.savedMeals.first!
        let initialCount = mealAnalysisManager.savedMeals.count
        
        // When
        mealAnalysisManager.deleteMeal(savedMeal)
        
        // Then
        XCTAssertEqual(mealAnalysisManager.savedMeals.count, initialCount - 1, "Should remove one saved meal")
        XCTAssertFalse(mealAnalysisManager.savedMeals.contains(savedMeal), "Should not contain deleted meal")
    }
    
    func testGetMealsForToday() {
        // Given
        let result = createMockMealAnalysisResult()
        mealAnalysisManager.saveMeal(result, name: "Today's Meal", mealType: .lunch)
        
        // When
        let todaysMeals = mealAnalysisManager.getMealsForToday()
        
        // Then
        XCTAssertEqual(todaysMeals.count, 1, "Should have one meal for today")
        XCTAssertEqual(todaysMeals.first?.name, "Today's Meal")
    }
    
    func testGetTotalNutritionForToday() {
        // Given
        let result1 = createMockMealAnalysisResult()
        let result2 = createMockMealAnalysisResult()
        mealAnalysisManager.saveMeal(result1, name: "Breakfast", mealType: .breakfast)
        mealAnalysisManager.saveMeal(result2, name: "Lunch", mealType: .lunch)
        
        // When
        let totalNutrition = mealAnalysisManager.getTotalNutritionForToday()
        
        // Then
        XCTAssertEqual(totalNutrition.calories, 500.0, "Should sum calories from both meals")
        XCTAssertEqual(totalNutrition.protein, 40.0, "Should sum protein from both meals")
        XCTAssertEqual(totalNutrition.carbs, 60.0, "Should sum carbs from both meals")
        XCTAssertEqual(totalNutrition.fat, 20.0, "Should sum fat from both meals")
    }
    
    // NutritionInfo Extension Tests
    
    func testNutritionInfoMacroBreakdown() {
        // Given
        let nutrition = NutritionInfo(
            calories: 400,
            protein: 25, // 100 calories (25%)
            carbs: 50,   // 200 calories (50%)  
            fat: 11,     // 100 calories (25%)
            fiber: 5,
            sugar: 10,
            sodium: 500,
            cholesterol: 60
        )
        
        // When
        let breakdown = nutrition.macroBreakdown
        
        // Then
        XCTAssertEqual(breakdown.protein, 25.0, accuracy: 1.0, "Protein should be 25% of calories")
        XCTAssertEqual(breakdown.carbs, 50.0, accuracy: 1.0, "Carbs should be 50% of calories")
        XCTAssertEqual(breakdown.fat, 25.0, accuracy: 1.0, "Fat should be 25% of calories")
    }
    
    func testNutritionInfoFormattedValues() {
        // Given
        let nutrition = NutritionInfo(
            calories: 250.567,
            protein: 20.123,
            carbs: 30.789,
            fat: 10.456,
            fiber: 5.234,
            sugar: 8.678,
            sodium: 400.901,
            cholesterol: 50.345
        )
        
        // When & Then
        XCTAssertEqual(nutrition.formatted(nutrition.calories), "250.6")
        XCTAssertEqual(nutrition.formatted(nutrition.protein, decimals: 2), "20.12")
        XCTAssertEqual(nutrition.formatted(nutrition.carbs, decimals: 0), "31")
    }
    
    //  State Management Tests
    
    func testAnalyzingState() {
        // Given
        XCTAssertFalse(mealAnalysisManager.isAnalyzing, "Should not be analyzing initially")
        
        // When
        mealAnalysisManager.isAnalyzing = true
        
        // Then
        XCTAssertTrue(mealAnalysisManager.isAnalyzing, "Should be analyzing when set to true")
        
        // When
        mealAnalysisManager.isAnalyzing = false
        
        // Then
        XCTAssertFalse(mealAnalysisManager.isAnalyzing, "Should not be analyzing when set to false")
    }
    
    func testErrorMessageState() {
        // Given
        XCTAssertNil(mealAnalysisManager.errorMessage, "Error message should be nil initially")
        
        // When
        mealAnalysisManager.errorMessage = "Test error message"
        
        // Then
        XCTAssertEqual(mealAnalysisManager.errorMessage, "Test error message", "Should store error message")
        
        // When
        mealAnalysisManager.errorMessage = nil
        
        // Then
        XCTAssertNil(mealAnalysisManager.errorMessage, "Should clear error message")
    }
    
    // Performance Tests
    
    func testMealSavingPerformance() {
        let result = createMockMealAnalysisResult()
        
        measure {
            for i in 0..<10 { // Reduced from 100 to 10 for faster testing
                mealAnalysisManager.saveMeal(result, name: "Performance Test \(i)", mealType: .lunch)
            }
        }
    }
    
    func testTotalNutritionCalculationPerformance() {
        // Given - Create multiple meals for today
        let results = Array(0..<50).map { _ in createMockMealAnalysisResult() }
        
        for (index, result) in results.enumerated() {
            mealAnalysisManager.saveMeal(result, name: "Meal \(index)", mealType: .lunch)
        }
        
        // When & Then
        measure {
            _ = mealAnalysisManager.getTotalNutritionForToday()
        }
    }
    
    // Compatibility Tests
    
    func testNutritionInfoCodable() throws {
        // Given
        let nutrition = NutritionInfo(
            calories: 300.0,
            protein: 25.0,
            carbs: 40.0,
            fat: 12.0,
            fiber: 6.0,
            sugar: 10.0,
            sodium: 500.0,
            cholesterol: 60.0
        )
        
        // When
        let encodedData = try JSONEncoder().encode(nutrition)
        let decodedNutrition = try JSONDecoder().decode(NutritionInfo.self, from: encodedData)
        
        // Then
        XCTAssertEqual(nutrition, decodedNutrition, "Encoded and decoded nutrition should be equal")
    }
    
    func testFoodItemCodable() throws {
        // Given
        let foodItem = createMockFoodItem()
        
        // When
        let encodedData = try JSONEncoder().encode(foodItem)
        let decodedFoodItem = try JSONDecoder().decode(FoodItem.self, from: encodedData)
        
        // Then
        XCTAssertEqual(foodItem.name, decodedFoodItem.name)
        XCTAssertEqual(foodItem.confidence, decodedFoodItem.confidence)
        XCTAssertEqual(foodItem.nutrition, decodedFoodItem.nutrition)
        XCTAssertEqual(foodItem.portion, decodedFoodItem.portion)
    }
    
    func testSavedMealCodable() throws {
        // Given
        let savedMeal = SavedMeal(
            name: "Test Meal",
            image: testImage.jpegData(compressionQuality: 0.7),
            foodItems: [createMockFoodItem()],
            totalNutrition: createMockFoodItem().nutrition,
            timestamp: Date(),
            mealType: .dinner
        )
        
        // When
        let encodedData = try JSONEncoder().encode(savedMeal)
        let decodedSavedMeal = try JSONDecoder().decode(SavedMeal.self, from: encodedData)
        
        // Then
        XCTAssertEqual(savedMeal.name, decodedSavedMeal.name)
        XCTAssertEqual(savedMeal.mealType, decodedSavedMeal.mealType)
        XCTAssertEqual(savedMeal.totalNutrition, decodedSavedMeal.totalNutrition)
        XCTAssertEqual(savedMeal.foodItems.count, decodedSavedMeal.foodItems.count)
    }
    
    
    func testParseNutritionFromLabelText() {
        // Given
        let sample = "Calories 250 kcal\nProtein 20 g\nCarbs 30 g\nFat 10 g\nFiber 5 g\nSodium 200 mg"
        
        // When
        let result = NutritionLabelParser.parse(from: sample)
        
        // Then
        XCTAssertNotNil(result, "Should successfully parse nutrition label")
        XCTAssertEqual(Int(result!.calories), 250, "Should parse calories correctly")
        XCTAssertEqual(Int(result!.protein), 20, "Should parse protein correctly")
        XCTAssertEqual(Int(result!.carbs), 30, "Should parse carbs correctly")
        XCTAssertEqual(Int(result!.fat), 10, "Should parse fat correctly")
        XCTAssertEqual(Int(result!.fiber), 5, "Should parse fiber correctly")
    }

    func testEstimateMealNutritionFallback() {
        // Given & When
        let info = NutritionEstimator.defaultEstimate()
        
        // Then
        XCTAssertGreaterThan(info.calories, 0, "Default estimate should have positive calories")
        XCTAssertGreaterThan(info.protein + info.carbs + info.fat, 0, "Default estimate should have positive macronutrients")
    }
}
