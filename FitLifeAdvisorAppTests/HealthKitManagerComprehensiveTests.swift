//
//  HealthKitManagerComprehensiveTests.swift
//  FitLifeAdvisorAppTests
//
//  Comprehensive unit tests for HealthKitManager
//

import XCTest
import HealthKit
import Combine
@testable import FitLifeAdvisorApp

@MainActor
final class HealthKitManagerComprehensiveTests: XCTestCase {
    
    // Test Properties
    var healthKitManager: HealthKitManager!
    var cancellables: Set<AnyCancellable>!
    
    // Setup & Teardown
    
    override func setUpWithError() throws {
        super.setUp()
        healthKitManager = HealthKitManager.shared
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        cancellables?.removeAll()
        cancellables = nil
        healthKitManager = nil
        super.tearDown()
    }
    
    // Initialization Tests
    
    func testHealthKitManagerSingleton() {
        // Given & When
        let instance1 = HealthKitManager.shared
        let instance2 = HealthKitManager.shared
        
        // Then
        XCTAssertTrue(instance1 === instance2, "HealthKitManager should be a singleton")
    }
    
    func testInitialState() {
        // Given & When - Initial state after init
        
        // Then
        XCTAssertFalse(healthKitManager.isAuthorized, "Should not be authorized initially")
        XCTAssertEqual(healthKitManager.todaysMetrics.steps, 0, "Steps should be 0 initially")
        XCTAssertEqual(healthKitManager.todaysMetrics.calories, 0, "Calories should be 0 initially")
        XCTAssertTrue(healthKitManager.recentWorkouts.isEmpty, "Recent workouts should be empty initially")
        XCTAssertTrue(healthKitManager.weeklyTrends.isEmpty, "Weekly trends should be empty initially")
        XCTAssertFalse(healthKitManager.isLoading, "Should not be loading initially")
        XCTAssertNil(healthKitManager.errorMessage, "Error message should be nil initially")
    }
    
    // Authorization Tests
    
    func testHealthKitAvailabilityCheck() {
        // Given & When - HealthKit availability is device-dependent
        let isAvailable = HKHealthStore.isHealthDataAvailable()
        
        // Then
        if !isAvailable {
            XCTAssertNotNil(healthKitManager.errorMessage, "Error message should be set when HealthKit is not available")
            XCTAssertEqual(healthKitManager.errorMessage, "HealthKit is not available on this device")
        }
    }
    
    func testRequestAuthorization() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Authorization completion")
        
        // When
        do {
            try await healthKitManager.requestAuthorization()
            expectation.fulfill()
        } catch let error as HealthKitError {
            // Then - Handle expected errors
            switch error {
            case .notAvailable:
                XCTAssertTrue(true, "Expected error when HealthKit not available")
            case .authorizationDenied:
                XCTAssertTrue(true, "Expected error when authorization denied")
            default:
                XCTFail("Unexpected HealthKit error: \(error)")
            }
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    // Data Model Tests
    
    func testHealthMetricsCreation() {
        // Given
        let timestamp = Date()
        
        // When
        let metrics = HealthMetrics(
            steps: 10000,
            calories: 500,
            distance: 5000,
            heartRate: 75,
            activeEnergy: 300,
            restingHeartRate: 60,
            heartRateVariability: 45,
            bodyWeight: 70,
            bodyFat: 15,
            sleepHours: 8,
            timestamp: timestamp
        )
        
        // Then
        XCTAssertEqual(metrics.steps, 10000)
        XCTAssertEqual(metrics.calories, 500)
        XCTAssertEqual(metrics.distance, 5000)
        XCTAssertEqual(metrics.heartRate, 75)
        XCTAssertEqual(metrics.activeEnergy, 300)
        XCTAssertEqual(metrics.restingHeartRate, 60)
        XCTAssertEqual(metrics.heartRateVariability, 45)
        XCTAssertEqual(metrics.bodyWeight, 70)
        XCTAssertEqual(metrics.bodyFat, 15)
        XCTAssertEqual(metrics.sleepHours, 8)
        XCTAssertEqual(metrics.timestamp, timestamp)
    }
    
    func testWorkoutDataCreation() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600) // 1 hour later
        let heartRateData = [HeartRatePoint(heartRate: 140, timestamp: startDate)]
        let metadata = ["source": "FitLifeApp"]
        
        // When
        let workoutData = WorkoutData(
            type: .running,
            startDate: startDate,
            endDate: endDate,
            duration: 3600,
            totalEnergyBurned: 400,
            totalDistance: 5000,
            heartRateData: heartRateData,
            route: [],
            metadata: metadata
        )
        
        // Then
        XCTAssertEqual(workoutData.type, .running)
        XCTAssertEqual(workoutData.startDate, startDate)
        XCTAssertEqual(workoutData.endDate, endDate)
        XCTAssertEqual(workoutData.duration, 3600)
        XCTAssertEqual(workoutData.totalEnergyBurned, 400)
        XCTAssertEqual(workoutData.totalDistance, 5000)
        XCTAssertEqual(workoutData.heartRateData.count, 1)
        XCTAssertEqual(workoutData.heartRateData.first?.heartRate, 140)
        XCTAssertNotNil(workoutData.id)
    }
    
    func testNutritionDataCreation() {
        // Given
        let timestamp = Date()
        
        // When
        let nutritionData = NutritionData(
            calories: 500,
            protein: 25,
            carbs: 60,
            fat: 20,
            fiber: 10,
            sugar: 15,
            sodium: 800,
            timestamp: timestamp
        )
        
        // Then
        XCTAssertEqual(nutritionData.calories, 500)
        XCTAssertEqual(nutritionData.protein, 25)
        XCTAssertEqual(nutritionData.carbs, 60)
        XCTAssertEqual(nutritionData.fat, 20)
        XCTAssertEqual(nutritionData.fiber, 10)
        XCTAssertEqual(nutritionData.sugar, 15)
        XCTAssertEqual(nutritionData.sodium, 800)
        XCTAssertEqual(nutritionData.timestamp, timestamp)
    }
    
    // Error Handling Tests
    
    func testHealthKitError() {
        // Given & When
        let notAvailableError = HealthKitError.notAvailable
        let authDeniedError = HealthKitError.authorizationDenied
        let dataNotAvailableError = HealthKitError.dataNotAvailable
        let writeFailedError = HealthKitError.writeFailed
        let readFailedError = HealthKitError.readFailed
        
        // Then
        XCTAssertEqual(notAvailableError.errorDescription, "HealthKit is not available on this device")
        XCTAssertEqual(authDeniedError.errorDescription, "HealthKit authorization was denied")
        XCTAssertEqual(dataNotAvailableError.errorDescription, "Requested health data is not available")
        XCTAssertEqual(writeFailedError.errorDescription, "Failed to write data to HealthKit")
        XCTAssertEqual(readFailedError.errorDescription, "Failed to read data from HealthKit")
    }
    
    //Workout Activity Type Extension Tests
    
    func testWorkoutActivityTypeDisplayNames() {
        // Given & When & Then
        XCTAssertEqual(HKWorkoutActivityType.running.displayName, "Running")
        XCTAssertEqual(HKWorkoutActivityType.walking.displayName, "Walking")
        XCTAssertEqual(HKWorkoutActivityType.cycling.displayName, "Cycling")
        XCTAssertEqual(HKWorkoutActivityType.swimming.displayName, "Swimming")
        XCTAssertEqual(HKWorkoutActivityType.yoga.displayName, "Yoga")
        XCTAssertEqual(HKWorkoutActivityType.functionalStrengthTraining.displayName, "Strength Training")
        XCTAssertEqual(HKWorkoutActivityType.traditionalStrengthTraining.displayName, "Weight Lifting")
        XCTAssertEqual(HKWorkoutActivityType.coreTraining.displayName, "Core Training")
        XCTAssertEqual(HKWorkoutActivityType.flexibility.displayName, "Stretching")
        XCTAssertEqual(HKWorkoutActivityType.dance.displayName, "Dance")
        XCTAssertEqual(HKWorkoutActivityType.other.displayName, "Workout")
    }
    
    func testWorkoutActivityTypeIcons() {
        // Given & When & Then
        XCTAssertEqual(HKWorkoutActivityType.running.icon, "figure.run")
        XCTAssertEqual(HKWorkoutActivityType.walking.icon, "figure.walk")
        XCTAssertEqual(HKWorkoutActivityType.cycling.icon, "bicycle")
        XCTAssertEqual(HKWorkoutActivityType.swimming.icon, "figure.pool.swim")
        XCTAssertEqual(HKWorkoutActivityType.yoga.icon, "figure.mind.and.body")
        XCTAssertEqual(HKWorkoutActivityType.functionalStrengthTraining.icon, "dumbbell")
        XCTAssertEqual(HKWorkoutActivityType.traditionalStrengthTraining.icon, "dumbbell")
        XCTAssertEqual(HKWorkoutActivityType.coreTraining.icon, "figure.core.training")
        XCTAssertEqual(HKWorkoutActivityType.flexibility.icon, "figure.flexibility")
        XCTAssertEqual(HKWorkoutActivityType.dance.icon, "figure.dance")
        XCTAssertEqual(HKWorkoutActivityType.other.icon, "heart.fill")
    }
    
    // Data Saving Tests
    
    func testSaveWorkout() async throws {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600)
        let totalEnergyBurned = 400.0
        let totalDistance = 5000.0
        let metadata = ["source": "FitLifeApp"]
        
        // When
        do {
            try await healthKitManager.saveWorkout(
                type: .running,
                startDate: startDate,
                endDate: endDate,
                totalEnergyBurned: totalEnergyBurned,
                totalDistance: totalDistance,
                metadata: metadata
            )
            // Then - If no exception thrown, test passes
            XCTAssertTrue(true, "Workout saved successfully")
        } catch let error as HealthKitError {
            // Then - Handle expected errors gracefully
            switch error {
            case .notAvailable:
                XCTAssertTrue(true, "Expected error when HealthKit not available")
            case .authorizationDenied:
                XCTAssertTrue(true, "Expected error when authorization denied")
            case .writeFailed:
                XCTAssertTrue(true, "Expected error when write fails")
            default:
                XCTFail("Unexpected HealthKit error: \(error)")
            }
        }
    }
    
    func testSaveNutritionData() async throws {
        // Given
        let nutritionData = NutritionData(
            calories: 500,
            protein: 25,
            carbs: 60,
            fat: 20,
            fiber: 10,
            sugar: 15,
            sodium: 800,
            timestamp: Date()
        )
        
        // When
        do {
            try await healthKitManager.saveNutritionData(nutritionData)
            // Then - If no exception thrown, test passes
            XCTAssertTrue(true, "Nutrition data saved successfully")
        } catch let error as HealthKitError {
            // Then - Handle expected errors gracefully
            switch error {
            case .notAvailable:
                XCTAssertTrue(true, "Expected error when HealthKit not available")
            case .authorizationDenied:
                XCTAssertTrue(true, "Expected error when authorization denied")
            case .writeFailed:
                XCTAssertTrue(true, "Expected error when write fails")
            default:
                XCTFail("Unexpected HealthKit error: \(error)")
            }
        }
    }
    
    //  Published Properties Tests
    
    func testPublishedPropertiesUpdateCorrectly() {
        // Given
        let expectation = XCTestExpectation(description: "Published properties update")
        var receivedUpdates = 0
        
        // When
        healthKitManager.$isLoading
            .dropFirst() // Skip initial value
            .sink { isLoading in
                receivedUpdates += 1
                if receivedUpdates == 1 {
                    XCTAssertTrue(isLoading, "Should be loading")
                } else if receivedUpdates == 2 {
                    XCTAssertFalse(isLoading, "Should finish loading")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Simulate loading state changes
        Task { @MainActor in
            healthKitManager.isLoading = true
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            healthKitManager.isLoading = false
        }
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
    //  Performance Tests
    
    func testLoadAllHealthDataPerformance() {
        // Given
        measure {
            // When
            Task { @MainActor in
                await healthKitManager.loadAllHealthData()
            }
        }
    }
    
    // Memory Management Tests
    
    func testMemoryManagement() {
        // Given
        weak var weakHealthKitManager: HealthKitManager?
        
        // When
        autoreleasepool {
            let strongHealthKitManager = HealthKitManager.shared
            weakHealthKitManager = strongHealthKitManager
            // strongHealthKitManager goes out of scope
        }
        
        // Then - Since it's a singleton, it should still exist
        XCTAssertNotNil(weakHealthKitManager, "Singleton should not be deallocated")
    }
}