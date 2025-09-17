//
//  HealthKitManager.swift
//  FitLifeAdvisorApp
//
//  Created by FitLife Team on 11/09/2025.
//  Production-Ready HealthKit Integration
//

import Foundation
import HealthKit
import Combine
import CoreLocation

// MARK: - HealthKit Data Types
enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationDenied
    case dataNotAvailable
    case writeFailed
    case readFailed
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .authorizationDenied:
            return "HealthKit authorization was denied"
        case .dataNotAvailable:
            return "Requested health data is not available"
        case .writeFailed:
            return "Failed to write data to HealthKit"
        case .readFailed:
            return "Failed to read data from HealthKit"
        }
    }
}

struct HealthMetrics {
    let steps: Double
    let calories: Double
    let distance: Double
    let heartRate: Double
    let activeEnergy: Double
    let restingHeartRate: Double
    let heartRateVariability: Double
    let bodyWeight: Double
    let bodyFat: Double
    let sleepHours: Double
    let timestamp: Date
}

struct WorkoutData {
    let id = UUID()
    let type: HKWorkoutActivityType
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let totalEnergyBurned: Double
    let totalDistance: Double
    let heartRateData: [HeartRatePoint]
    let route: [CLLocation]
    let metadata: [String: Any]
}

struct HeartRatePoint {
    let heartRate: Double
    let timestamp: Date
}

struct NutritionData {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let sodium: Double
    let timestamp: Date
}

// MARK: - Main HealthKit Manager
@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    // Published Properties for Real-Time Updates
    @Published var isAuthorized = false
    @Published var todaysMetrics = HealthMetrics(
        steps: 0, calories: 0, distance: 0, heartRate: 0,
        activeEnergy: 0, restingHeartRate: 0, heartRateVariability: 0,
        bodyWeight: 0, bodyFat: 0, sleepHours: 0, timestamp: Date()
    )
    @Published var recentWorkouts: [WorkoutData] = []
    @Published var weeklyTrends: [HealthMetrics] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var backgroundUpdateTask: Task<Void, Never>?
    
    // MARK: - Health Data Types We Need
    private let readTypes: Set<HKObjectType> = [
        // Activity & Fitness
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
        
        // Heart Health
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        
        // Body Measurements
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!,
        HKObjectType.quantityType(forIdentifier: .height)!,
        
        // Sleep Analysis
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        
        // Workouts
        HKObjectType.workoutType(),
        
        // Nutrition
        HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
        HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
        HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
        HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!,
        HKObjectType.quantityType(forIdentifier: .dietaryFiber)!,
        HKObjectType.quantityType(forIdentifier: .dietarySugar)!,
        HKObjectType.quantityType(forIdentifier: .dietarySodium)!
    ]
    
    private let writeTypes: Set<HKSampleType> = [
        // We can write workouts and nutrition data
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
        HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
        HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
        HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)!,
        HKObjectType.quantityType(forIdentifier: .dietaryFiber)!,
        HKObjectType.quantityType(forIdentifier: .dietarySugar)!,
        HKObjectType.quantityType(forIdentifier: .dietarySodium)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    private init() {
        checkHealthKitAvailability()
        startBackgroundUpdates()
    }
    
    // MARK: - Authorization & Setup
    
    private func checkHealthKitAvailability() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit is not available on this device"
            return
        }
    }
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
        
        // Check authorization status
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let authStatus = healthStore.authorizationStatus(for: stepType)
        
        DispatchQueue.main.async {
            self.isAuthorized = authStatus == .sharingAuthorized
            if self.isAuthorized {
                Task {
                    await self.loadAllHealthData()
                }
            }
        }
    }
    
    // MARK: - Real-Time Data Loading
    
    func loadAllHealthData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTodaysMetrics() }
            group.addTask { await self.loadRecentWorkouts() }
            group.addTask { await self.loadWeeklyTrends() }
        }
    }
    
    private func loadTodaysMetrics() async {
        isLoading = true
        defer { isLoading = false }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        async let steps = fetchQuantityData(for: .stepCount, start: startOfDay, end: endOfDay)
        async let calories = fetchQuantityData(for: .activeEnergyBurned, start: startOfDay, end: endOfDay)
        async let distance = fetchQuantityData(for: .distanceWalkingRunning, start: startOfDay, end: endOfDay)
        async let heartRate = fetchLatestHeartRate()
        async let restingHR = fetchLatestRestingHeartRate()
        async let hrv = fetchLatestHRV()
        async let weight = fetchLatestBodyWeight()
        async let bodyFat = fetchLatestBodyFat()
        async let sleep = fetchSleepData(for: startOfDay)
        
        let metrics = HealthMetrics(
            steps: await steps,
            calories: await calories,
            distance: await distance,
            heartRate: await heartRate,
            activeEnergy: await calories,
            restingHeartRate: await restingHR,
            heartRateVariability: await hrv,
            bodyWeight: await weight,
            bodyFat: await bodyFat,
            sleepHours: await sleep,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.todaysMetrics = metrics
        }
    }
    
    // MARK: - Quantity Data Fetching
    
    private func fetchQuantityData(for identifier: HKQuantityTypeIdentifier, start: Date, end: Date) async -> Double {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            return 0.0
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let sum = result?.sumQuantity()?.doubleValue(for: self.unit(for: identifier)) ?? 0.0
                continuation.resume(returning: sum)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchLatestHeartRate() async -> Double {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return 0.0
        }
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, _ in
                let latestSample = samples?.first as? HKQuantitySample
                let heartRate = latestSample?.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0.0
                continuation.resume(returning: heartRate)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchLatestRestingHeartRate() async -> Double {
        guard let restingHRType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return 0.0
        }
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: restingHRType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, _ in
                let latestSample = samples?.first as? HKQuantitySample
                let restingHR = latestSample?.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0.0
                continuation.resume(returning: restingHR)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchLatestHRV() async -> Double {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            return 0.0
        }
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: hrvType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, _ in
                let latestSample = samples?.first as? HKQuantitySample
                let hrv = latestSample?.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)) ?? 0.0
                continuation.resume(returning: hrv)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchLatestBodyWeight() async -> Double {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            return 0.0
        }
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, _ in
                let latestSample = samples?.first as? HKQuantitySample
                let weight = latestSample?.quantity.doubleValue(for: .gramUnit(with: .kilo)) ?? 0.0
                continuation.resume(returning: weight)
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchLatestBodyFat() async -> Double {
        guard let bodyFatType = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage) else {
            return 0.0
        }
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: bodyFatType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, _ in
                let latestSample = samples?.first as? HKQuantitySample
                let bodyFat = latestSample?.quantity.doubleValue(for: .percent()) ?? 0.0
                continuation.resume(returning: bodyFat * 100) // Convert to percentage
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchSleepData(for date: Date) async -> Double {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            return 0.0
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, _ in
                let sleepSamples = samples as? [HKCategorySample] ?? []
                let totalSleepTime = sleepSamples
                    .filter { $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue }
                    .reduce(0.0) { total, sample in
                        total + sample.endDate.timeIntervalSince(sample.startDate)
                    }
                continuation.resume(returning: totalSleepTime / 3600) // Convert to hours
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Workout Data
    
    private func loadRecentWorkouts() async {
        let calendar = Calendar.current
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: Date())!
        let predicate = HKQuery.predicateForWorkouts(with: .greaterThan, duration: 60) // At least 1 minute
        let datePredicate = HKQuery.predicateForSamples(withStart: lastWeek, end: Date())
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, datePredicate])
        
        let workouts = await fetchWorkouts(with: compoundPredicate)
        
        DispatchQueue.main.async {
            self.recentWorkouts = workouts
        }
    }
    
    private func fetchWorkouts(with predicate: NSPredicate) async -> [WorkoutData] {
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKWorkoutType.workoutType(),
                predicate: predicate,
                limit: 20,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, _ in
                let workouts = samples as? [HKWorkout] ?? []
                let workoutData = workouts.map { workout in
                    WorkoutData(
                        type: workout.workoutActivityType,
                        startDate: workout.startDate,
                        endDate: workout.endDate,
                        duration: workout.duration,
                        totalEnergyBurned: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0.0,
                        totalDistance: workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0,
                        heartRateData: [], // Will fetch separately if needed
                        route: [], // Will fetch separately if needed
                        metadata: workout.metadata ?? [:]
                    )
                }
                continuation.resume(returning: workoutData)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Weekly Trends
    
    private func loadWeeklyTrends() async {
        let calendar = Calendar.current
        let today = Date()
        var trends: [HealthMetrics] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            async let steps = fetchQuantityData(for: .stepCount, start: startOfDay, end: endOfDay)
            async let calories = fetchQuantityData(for: .activeEnergyBurned, start: startOfDay, end: endOfDay)
            async let distance = fetchQuantityData(for: .distanceWalkingRunning, start: startOfDay, end: endOfDay)
            
            let metrics = HealthMetrics(
                steps: await steps,
                calories: await calories,
                distance: await distance,
                heartRate: 0, // Don't need for trends
                activeEnergy: await calories,
                restingHeartRate: 0,
                heartRateVariability: 0,
                bodyWeight: 0,
                bodyFat: 0,
                sleepHours: 0,
                timestamp: date
            )
            
            trends.append(metrics)
        }
        
        DispatchQueue.main.async {
            self.weeklyTrends = trends.reversed() // Show oldest first
        }
    }
    
    // MARK: - Writing Data to HealthKit
    
    func saveWorkout(
        type: HKWorkoutActivityType,
        startDate: Date,
        endDate: Date,
        totalEnergyBurned: Double,
        totalDistance: Double,
        metadata: [String: Any] = [:]
    ) async throws {
        let energyQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: totalEnergyBurned)
        let distanceQuantity = totalDistance > 0 ? HKQuantity(unit: .meter(), doubleValue: totalDistance) : nil
        
        let workout = HKWorkout(
            activityType: type,
            start: startDate,
            end: endDate,
            duration: endDate.timeIntervalSince(startDate),
            totalEnergyBurned: energyQuantity,
            totalDistance: distanceQuantity,
            metadata: metadata
        )
        
        try await healthStore.save(workout)
    }
    
    func saveNutritionData(_ nutrition: NutritionData) async throws {
        var samples: [HKQuantitySample] = []
        
        // Calories
        if nutrition.calories > 0 {
            let calorieQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: nutrition.calories)
            let calorieSample = HKQuantitySample(
                type: HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
                quantity: calorieQuantity,
                start: nutrition.timestamp,
                end: nutrition.timestamp
            )
            samples.append(calorieSample)
        }
        
        // Protein
        if nutrition.protein > 0 {
            let proteinQuantity = HKQuantity(unit: .gram(), doubleValue: nutrition.protein)
            let proteinSample = HKQuantitySample(
                type: HKQuantityType.quantityType(forIdentifier: .dietaryProtein)!,
                quantity: proteinQuantity,
                start: nutrition.timestamp,
                end: nutrition.timestamp
            )
            samples.append(proteinSample)
        }
        
        // Continue for other nutrients...
        try await healthStore.save(samples)
    }
    
    // MARK: - Background Updates
    
    private func startBackgroundUpdates() {
        backgroundUpdateTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5 * 60 * 1_000_000_000) // 5 minutes
                if isAuthorized {
                    await loadTodaysMetrics()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func unit(for identifier: HKQuantityTypeIdentifier) -> HKUnit {
        switch identifier {
        case .stepCount:
            return .count()
        case .distanceWalkingRunning:
            return .meter()
        case .activeEnergyBurned, .basalEnergyBurned:
            return .kilocalorie()
        case .heartRate:
            return HKUnit.count().unitDivided(by: .minute())
        case .bodyMass:
            return .gramUnit(with: .kilo)
        case .height:
            return .meter()
        default:
            return .count()
        }
    }
    
    deinit {
        backgroundUpdateTask?.cancel()
    }
}

// MARK: - Extensions for UI Integration

extension HKWorkoutActivityType {
    var displayName: String {
        switch self {
        case .running: return "Running"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .swimming: return "Swimming"
        case .yoga: return "Yoga"
        case .functionalStrengthTraining: return "Strength Training"
        case .traditionalStrengthTraining: return "Weight Lifting"
        case .coreTraining: return "Core Training"
        case .flexibility: return "Stretching"
        case .dance: return "Dance"
        default: return "Workout"
        }
    }
    
    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .yoga: return "figure.mind.and.body"
        case .functionalStrengthTraining, .traditionalStrengthTraining: return "dumbbell"
        case .coreTraining: return "figure.core.training"
        case .flexibility: return "figure.flexibility"
        case .dance: return "figure.dance"
        default: return "heart.fill"
        }
    }
}
