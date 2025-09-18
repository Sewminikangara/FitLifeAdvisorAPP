//
//  MealAnalysisManagerTests.swift
//  FitLifeAdvisorAppTests
//
//  Comprehensive unit tests for MealAnalysisManager
//

import XCTest
import UIKit
@testable import FitLifeAdvisorApp

@MainActor
final class MealAnalysisManagerTests: XCTestCase {
    
    // MARK: - Test Properties
    var mealAnalysisManager: MealAnalysisManager!
    var testImage: UIImage!
    
    // MARK: - Setup & Teardown
    
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
    
    // MARK: - Helper Methods
    
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
    
    // MARK: - Initialization Tests
    
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
    
    // MARK: - Data Model Tests
    
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
    
    // MARK: - Image Analysis Tests
    
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
    
    // MARK: - Meal Analysis Result Tests
    
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
    
    // MARK: - Saved Meal Tests
    
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
    
    // MARK: - Meal Type Tests
    
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
    
    // MARK: - Error Handling Tests
    
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
    
    // MARK: - Meal Management Tests
    
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
    
    func testDeleteMealsByMealType() {
        // Given
        let result1 = createMockMealAnalysisResult()
        let result2 = createMockMealAnalysisResult()
        mealAnalysisManager.saveMeal(result1, name: "Breakfast Meal", mealType: .breakfast)
        mealAnalysisManager.saveMeal(result2, name: "Lunch Meal", mealType: .lunch)
        
        let initialCount = mealAnalysisManager.savedMeals.count
        
        // When
        mealAnalysisManager.deleteMealsBy(mealType: .breakfast)
        
        // Then
        XCTAssertEqual(mealAnalysisManager.savedMeals.count, initialCount - 1, "Should remove breakfast meals")
        XCTAssertTrue(mealAnalysisManager.savedMeals.allSatisfy { $0.mealType != .breakfast }, 
                     "Should not contain any breakfast meals")
    }
    
    func testGetMealsByMealType() {
        // Given
        let result1 = createMockMealAnalysisResult()
        let result2 = createMockMealAnalysisResult()
        mealAnalysisManager.saveMeal(result1, name: "Breakfast Meal", mealType: .breakfast)
        mealAnalysisManager.saveMeal(result2, name: "Lunch Meal", mealType: .lunch)
        
        // When
        let breakfastMeals = mealAnalysisManager.getMealsBy(mealType: .breakfast)
        let lunchMeals = mealAnalysisManager.getMealsBy(mealType: .lunch)
        
        // Then
        XCTAssertEqual(breakfastMeals.count, 1, "Should have one breakfast meal")
        XCTAssertEqual(lunchMeals.count, 1, "Should have one lunch meal")
        XCTAssertEqual(breakfastMeals.first?.name, "Breakfast Meal")
        XCTAssertEqual(lunchMeals.first?.name, "Lunch Meal")
    }
    
    func testGetMealsByDateRange() {
        // Given
        let result = createMockMealAnalysisResult()
        mealAnalysisManager.saveMeal(result, name: "Recent Meal", mealType: .lunch)
        
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        
        // When
        let mealsInRange = mealAnalysisManager.getMealsBy(from: yesterday, to: tomorrow)
        let mealsOutOfRange = mealAnalysisManager.getMealsBy(from: tomorrow, to: tomorrow)
        
        // Then
        XCTAssertEqual(mealsInRange.count, 1, "Should find meal within date range")
        XCTAssertEqual(mealsOutOfRange.count, 0, "Should not find meal outside date range")
    }
    
    // MARK: - Nutrition Calculation Tests
    
    func testCalculateTotalNutritionFromMultipleFoodItems() {
        // Given
        let nutrition1 = NutritionInfo(calories: 100, protein: 10, carbs: 15, fat: 5, fiber: 2, sugar: 3, sodium: 200, cholesterol: 20)
        let nutrition2 = NutritionInfo(calories: 150, protein: 15, carbs: 20, fat: 8, fiber: 3, sugar: 5, sodium: 300, cholesterol: 30)
        
        let portion = PortionInfo(servingSize: "1 serving", weight: 100, unit: "grams")
        
        let foodItem1 = FoodItem(name: "Food 1", confidence: 0.8, nutrition: nutrition1, portion: portion)
        let foodItem2 = FoodItem(name: "Food 2", confidence: 0.9, nutrition: nutrition2, portion: portion)
        
        let foodItems = [foodItem1, foodItem2]
        
        // When
        let totalNutrition = mealAnalysisManager.calculateTotalNutrition(from: foodItems)
        
        // Then
        XCTAssertEqual(totalNutrition.calories, 250, "Should sum calories correctly")
        XCTAssertEqual(totalNutrition.protein, 25, "Should sum protein correctly")
        XCTAssertEqual(totalNutrition.carbs, 35, "Should sum carbs correctly")
        XCTAssertEqual(totalNutrition.fat, 13, "Should sum fat correctly")
        XCTAssertEqual(totalNutrition.fiber, 5, "Should sum fiber correctly")
        XCTAssertEqual(totalNutrition.sugar, 8, "Should sum sugar correctly")
        XCTAssertEqual(totalNutrition.sodium, 500, "Should sum sodium correctly")
        XCTAssertEqual(totalNutrition.cholesterol, 50, "Should sum cholesterol correctly")
    }
    
    func testCalculateTotalNutritionFromEmptyArray() {
        // Given
        let emptyFoodItems: [FoodItem] = []
        
        // When
        let totalNutrition = mealAnalysisManager.calculateTotalNutrition(from: emptyFoodItems)
        
        // Then
        XCTAssertEqual(totalNutrition.calories, 0)
        XCTAssertEqual(totalNutrition.protein, 0)
        XCTAssertEqual(totalNutrition.carbs, 0)
        XCTAssertEqual(totalNutrition.fat, 0)
        XCTAssertEqual(totalNutrition.fiber, 0)
        XCTAssertEqual(totalNutrition.sugar, 0)
        XCTAssertEqual(totalNutrition.sodium, 0)
        XCTAssertEqual(totalNutrition.cholesterol, 0)
    }
    
    func testCalculateOverallConfidenceFromFoodItems() {
        // Given
        let portion = PortionInfo(servingSize: "1 serving", weight: 100, unit: "grams")
        let nutrition = NutritionInfo(calories: 100, protein: 10, carbs: 15, fat: 5, fiber: 2, sugar: 3, sodium: 200, cholesterol: 20)
        
        let foodItem1 = FoodItem(name: "Food 1", confidence: 0.8, nutrition: nutrition, portion: portion)
        let foodItem2 = FoodItem(name: "Food 2", confidence: 0.6, nutrition: nutrition, portion: portion)
        let foodItem3 = FoodItem(name: "Food 3", confidence: 0.9, nutrition: nutrition, portion: portion)
        
        let foodItems = [foodItem1, foodItem2, foodItem3]
        
        // When
        let overallConfidence = mealAnalysisManager.calculateOverallConfidence(from: foodItems)
        
        // Then
        let expectedConfidence = (0.8 + 0.6 + 0.9) / 3.0
        XCTAssertEqual(overallConfidence, Float(expectedConfidence), accuracy: 0.01, "Should calculate average confidence correctly")
    }
    
    func testCalculateOverallConfidenceFromEmptyArray() {
        // Given
        let emptyFoodItems: [FoodItem] = []
        
        // When
        let overallConfidence = mealAnalysisManager.calculateOverallConfidence(from: emptyFoodItems)
        
        // Then
        XCTAssertEqual(overallConfidence, 0.0, "Should return 0 confidence for empty array")
    }
    
    // MARK: - State Management Tests
    
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
    
    // MARK: - Performance Tests
    
    func testMealSavingPerformance() {
        let result = createMockMealAnalysisResult()
        
        measure {
            for i in 0..<100 {
                mealAnalysisManager.saveMeal(result, name: "Performance Test \(i)", mealType: .lunch)
            }
        }
    }
    
    func testNutritionCalculationPerformance() {
        // Given
        let portion = PortionInfo(servingSize: "1 serving", weight: 100, unit: "grams")
        let nutrition = NutritionInfo(calories: 100, protein: 10, carbs: 15, fat: 5, fiber: 2, sugar: 3, sodium: 200, cholesterol: 20)
        
        var foodItems: [FoodItem] = []
        for i in 0..<1000 {
            let foodItem = FoodItem(name: "Food \(i)", confidence: 0.8, nutrition: nutrition, portion: portion)
            foodItems.append(foodItem)
        }
        
        // When & Then
        measure {
            _ = mealAnalysisManager.calculateTotalNutrition(from: foodItems)
        }
    }
    
    // MARK: - Compatibility Tests
    
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
    
    // MARK: - Legacy Compatibility Tests
    
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
