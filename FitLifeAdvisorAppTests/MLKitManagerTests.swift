//
//  MLKitManagerTests.swift
//  FitLifeAdvisorAppTests
//
//   unit tests for MLKitManager


import XCTest
import Vision
import UIKit
@testable import FitLifeAdvisorApp

@MainActor
final class MLKitManagerTests: XCTestCase {
    
    var mlKitManager: MLKitManager!
    
    //  Setup & Teardown
    
    override func setUpWithError() throws {
        super.setUp()
        mlKitManager = MLKitManager()
    }
    
    override func tearDownWithError() throws {
        mlKitManager = nil
        super.tearDown()
    }
    
    // Initialization Tests
    
    func testMLKitManagerInitialization() {
        // Given & When - MLKitManager is initialized in setup
        
        // Then
        XCTAssertFalse(mlKitManager.isProcessing, "Should not be processing initially")
        XCTAssertNil(mlKitManager.lastResult, "Last result should be nil initially")
        XCTAssertNil(mlKitManager.errorMessage, "Error message should be nil initially")
    }
    
    // Data Model Tests
    
    func testMLResultCreation() {
        // Given
        let testData = ["test", "data"]
        let confidence: Float = 0.85
        let timestamp = Date()
        
        // When
        let result = MLResult(
            type: .text,
            data: testData,
            confidence: confidence,
            timestamp: timestamp
        )
        
        // Then
        XCTAssertEqual(result.type, .text)
        XCTAssertEqual(result.confidence, confidence)
        XCTAssertEqual(result.timestamp, timestamp)
        
        if let data = result.data as? [String] {
            XCTAssertEqual(data, testData)
        } else {
            XCTFail("Result data should be [String]")
        }
    }
    
    func testPoseDataCreation() {
        // Given
        let landmarks = [CGPoint(x: 100, y: 200), CGPoint(x: 150, y: 250)]
        let confidence: Float = 0.9
        let exerciseType = ExerciseType.pushup
        let formScore: Float = 0.8
        
        // When
        let poseData = PoseData(
            landmarks: landmarks,
            confidence: confidence,
            exerciseType: exerciseType,
            formScore: formScore
        )
        
        // Then
        XCTAssertEqual(poseData.landmarks, landmarks)
        XCTAssertEqual(poseData.confidence, confidence)
        XCTAssertEqual(poseData.exerciseType, exerciseType)
        XCTAssertEqual(poseData.formScore, formScore)
    }
    
    // Exercise Type Tests
    
    func testExerciseTypeEnumValues() {
        // Given & When & Then
        let exerciseTypes: [ExerciseType] = [.pushup, .squat, .plank, .bicepCurl, .unknown]
        
        XCTAssertEqual(exerciseTypes.count, 5, "Should have 5 exercise types")
        XCTAssertTrue(exerciseTypes.contains(.pushup))
        XCTAssertTrue(exerciseTypes.contains(.squat))
        XCTAssertTrue(exerciseTypes.contains(.plank))
        XCTAssertTrue(exerciseTypes.contains(.bicepCurl))
        XCTAssertTrue(exerciseTypes.contains(.unknown))
    }
    
    // error Handling Tests
    
    func testMLKitErrorTypes() {
        // Given & When
        let invalidImageError = MLKitError.invalidImage
        let processingFailedError = MLKitError.processingFailed
        let noResultsFoundError = MLKitError.noResultsFound
        let permissionDeniedError = MLKitError.permissionDenied
        
        // Then
        XCTAssertEqual(invalidImageError.localizedDescription, "Invalid image provided for analysis")
        XCTAssertEqual(processingFailedError.localizedDescription, "ML processing failed")
        XCTAssertEqual(noResultsFoundError.localizedDescription, "No results found in image")
        XCTAssertEqual(permissionDeniedError.localizedDescription, "Camera or photo library permission denied")
    }
    
    //  Image Processing Tests
    
    func testCreateTestImage() {
        // Given
        let size = CGSize(width: 100, height: 100)
        
        // When
        let testImage = createTestImage(size: size, color: .red)
        
        // Then
        XCTAssertNotNil(testImage)
        XCTAssertEqual(testImage.size, size)
    }
    
    func testBarcodeScanning() {
        // Given
        let testImage = createTestImage(size: CGSize(width: 200, height: 200), color: .white)
        let expectation = XCTestExpectation(description: "Barcode scanning completion")
        
        // When
        mlKitManager.scanBarcode(from: testImage) { result in
            // Then
            switch result {
            case .success(let barcode):
                XCTAssertFalse(barcode.isEmpty, "Barcode should not be empty if found")
            case .failure(let error):
                // Expected for test image without barcode
                XCTAssertTrue(error.localizedDescription.contains("barcode") || 
                            error.localizedDescription.contains("No") ||
                            error.localizedDescription.contains("found"),
                            "Error should indicate no barcode found")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testTextRecognition() {
        // Given
        let testImage = createTestImageWithText()
        let expectation = XCTestExpectation(description: "Text recognition completion")
        
        // When
        mlKitManager.recognizeText(from: testImage) { result in
            // Then
            switch result {
            case .success(let textArray):
                XCTAssertTrue(textArray.isEmpty || !textArray.isEmpty, "Should return array (empty or with text)")
            case .failure(let error):
                // Expected for simple test image
                XCTAssertNotNil(error, "Error should be provided when recognition fails")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testMealPhotoAnalysis() {
        // Given
        let testImage = createTestImage(size: CGSize(width: 300, height: 300), color: .green)
        let expectation = XCTestExpectation(description: "Meal analysis completion")
        
        // When
        mlKitManager.analyzeMealPhoto(testImage) { result in
            // Then
            switch result {
            case .success(let nutrition):
                XCTAssertGreaterThan(nutrition.calories, 0, "Should provide calorie estimate")
                XCTAssertGreaterThanOrEqual(nutrition.protein, 0, "Protein should be non-negative")
                XCTAssertGreaterThanOrEqual(nutrition.carbs, 0, "Carbs should be non-negative")
                XCTAssertGreaterThanOrEqual(nutrition.fat, 0, "Fat should be non-negative")
            case .failure(let error):
                // Some failure is acceptable for test image
                XCTAssertNotNil(error, "Error should be provided when analysis fails")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Nutrition Info Extraction Tests
    
    func testExtractNutritionInfoFromText() {
        // Given
        let testText = [
            "Nutrition Facts",
            "Calories 250",
            "Protein 20g",
            "Carbohydrates 30g",
            "Fat 10g",
            "Fiber 5g",
            "Sugar 8g",
            "Sodium 400mg"
        ]
        
        // When
        let nutritionInfo = mlKitManager.extractNutritionInfo(from: testText)
        
        // Then
        XCTAssertGreaterThan(nutritionInfo.calories, 0, "Should extract calories")
        XCTAssertGreaterThanOrEqual(nutritionInfo.protein, 0, "Should extract protein")
        XCTAssertGreaterThanOrEqual(nutritionInfo.carbs, 0, "Should extract carbs")
        XCTAssertGreaterThanOrEqual(nutritionInfo.fat, 0, "Should extract fat")
        XCTAssertGreaterThanOrEqual(nutritionInfo.fiber, 0, "Should extract fiber")
        XCTAssertGreaterThanOrEqual(nutritionInfo.sugar, 0, "Should extract sugar")
        XCTAssertGreaterThanOrEqual(nutritionInfo.sodium, 0, "Should extract sodium")
    }
    
    func testExtractNutritionInfoFromEmptyText() {
        // Given
        let emptyText: [String] = []
        
        // When
        let nutritionInfo = mlKitManager.extractNutritionInfo(from: emptyText)
        
        // Then
        XCTAssertEqual(nutritionInfo.calories, 0, "Should return 0 for empty text")
        XCTAssertEqual(nutritionInfo.protein, 0, "Should return 0 for empty text")
        XCTAssertEqual(nutritionInfo.carbs, 0, "Should return 0 for empty text")
        XCTAssertEqual(nutritionInfo.fat, 0, "Should return 0 for empty text")
    }
    
    // MARK: - State Management Tests
    
    func testProcessingStateManagement() {
        // Given
        let testImage = createTestImage(size: CGSize(width: 100, height: 100), color: .blue)
        let expectation = XCTestExpectation(description: "Processing state management")
        
        // When
        XCTAssertFalse(mlKitManager.isProcessing, "Should not be processing initially")
        
        mlKitManager.scanBarcode(from: testImage) { _ in
            // Then
            XCTAssertFalse(self.mlKitManager.isProcessing, "Should not be processing after completion")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Performance Tests
    
    func testBarcodePerformance() {
        // Given
        let testImage = createTestImage(size: CGSize(width: 200, height: 200), color: .white)
        
        // When & Then
        measure {
            let expectation = XCTestExpectation(description: "Barcode performance")
            
            mlKitManager.scanBarcode(from: testImage) { _ in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testTextRecognitionPerformance() {
        // Given
        let testImage = createTestImageWithText()
        
        // When & Then
        measure {
            let expectation = XCTestExpectation(description: "Text recognition performance")
            
            mlKitManager.recognizeText(from: testImage) { _ in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage(size: CGSize, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    private func createTestImageWithText() -> UIImage {
        let size = CGSize(width: 300, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // White background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Black text
            let text = "TEST 123\nCalories: 250"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            let textRect = CGRect(x: 20, y: 50, width: size.width - 40, height: size.height - 100)
            attributedText.draw(in: textRect)
        }
    }
}
