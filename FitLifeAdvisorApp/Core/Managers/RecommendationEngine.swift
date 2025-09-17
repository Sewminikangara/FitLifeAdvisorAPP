//
//  FitLifeAdvisorApp
//
//  Created by sewmini010 on 11/09/2025.
//

import Foundation
import HealthKit
import CoreML
import Combine

struct FitnessRecommendation {
    let id = UUID()
    let type: RecommendationType
    let title: String
    let description: String
    let priority: RecommendationPriority
    let confidence: Double
    let actionItems: [ActionItem]
    let expectedBenefit: String
    let timeframe: String
    let personalizedReason: String
    let scientificBasis: String
    let timestamp: Date = Date()
}

enum RecommendationType {
    case workout
    case nutrition
    case recovery
    case lifestyle
    case health
    case combination
}

enum RecommendationPriority: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4
    
    var displayName: String {
        switch self {
        case .low: return "Suggested"
        case .medium: return "Recommended"
        case .high: return "Important"
        case .critical: return "Critical"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "blue"
        case .medium: return "green"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

struct ActionItem {
    let id = UUID()
    let title: String
    let description: String
    let type: ActionType
    let estimatedDuration: TimeInterval
    let difficulty: DifficultyLevel
    let completionTracking: Bool
}

enum ActionType {
    case workout
    case meal
    case supplement
    case lifestyle
    case monitoring
}

enum DifficultyLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
}

struct UserProfile {
    let age: Int
    let gender: String
    let height: Double
    let weight: Double
    let activityLevel: ActivityLevel
    let fitnessGoals: [FitnessGoal]
    let medicalConditions: [String]
    let preferences: UserPreferences
    let currentFitnessLevel: FitnessLevel
}

enum ActivityLevel: String, CaseIterable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case extremelyActive = "Extremely Active"
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extremelyActive: return 1.9
        }
    }
}

struct UserPreferences {
    let preferredWorkoutTypes: [HKWorkoutActivityType]
    let workoutDuration: WorkoutDurationPreference
    let workoutTime: WorkoutTimePreference
    let dietaryRestrictions: [String]
    let cuisinePreferences: [String]
    let supplementPreferences: SupplementPreference
}

enum WorkoutDurationPreference: String, CaseIterable {
    case short = "15-30 minutes"
    case medium = "30-60 minutes"
    case long = "60-90 minutes"
    case extended = "90+ minutes"
}

enum WorkoutTimePreference: String, CaseIterable {
    case morning = "Morning (6-10 AM)"
    case midday = "Midday (10 AM-2 PM)"
    case afternoon = "Afternoon (2-6 PM)"
    case evening = "Evening (6-10 PM)"
    case flexible = "Flexible"
}

enum SupplementPreference: String, CaseIterable {
    case none = "No Supplements"
    case minimal = "Basic Supplements"
    case moderate = "Moderate Use"
    case extensive = "Extensive Use"
}

// MARK: - Analytics & Pattern Recognition
struct UserAnalytics {
    let weeklyWorkoutFrequency: Double
    let averageWorkoutDuration: TimeInterval
    let preferredWorkoutDays: [Int] // 1-7 (Sunday-Saturday)
    let workoutConsistency: Double // 0-1
    let nutritionConsistency: Double // 0-1
    let sleepQuality: Double // 0-1
    let stressLevel: Double // 0-1
    let energyLevels: [Double] // Daily energy ratings
    let progressTrends: ProgressTrends
    let metabolicData: MetabolicData
}

struct ProgressTrends {
    let weightTrend: TrendDirection
    let strengthTrend: TrendDirection
    let enduranceTrend: TrendDirection
    let bodyCompositionTrend: TrendDirection
    let overallFitnessTrend: TrendDirection
}

enum TrendDirection: String {
    case improving = "Improving"
    case stable = "Stable"
    case declining = "Declining"
    case noData = "Insufficient Data"
}

struct MetabolicData {
    let basalMetabolicRate: Double
    let totalDailyEnergyExpenditure: Double
    let macroRatios: MacroRatios
    let metabolicEfficiency: Double
    let insulinSensitivity: Double
}

struct MacroRatios {
    let proteinRatio: Double // 0-1
    let carbRatio: Double // 0-1
    let fatRatio: Double // 0-1
}

// MARK: - Main Recommendation Engine
@MainActor
class RecommendationEngine: ObservableObject {
    static let shared = RecommendationEngine()
    
    // MARK: - Published Properties
    @Published var dailyRecommendations: [FitnessRecommendation] = []
    @Published var weeklyRecommendations: [FitnessRecommendation] = []
    @Published var urgentRecommendations: [FitnessRecommendation] = []
    @Published var personalizedInsights: [String] = []
    @Published var synergyRecommendations: [FitnessRecommendation] = []
    
    @Published var userProfile: UserProfile?
    @Published var userAnalytics: UserAnalytics?
    @Published var isAnalyzing = false
    @Published var lastAnalysisDate: Date?
    
    // MARK: - Dependencies
    private let healthKitManager = HealthKitManager.shared
    private let mealAnalysisManager = MealAnalysisManager.shared
    private let workoutManager = WorkoutManager.shared
    
    // MARK: - ML Models (for future integration)
    private var nutritionModel: MLModel?
    private var workoutModel: MLModel?
    private var synergyModel: MLModel?
    
    // MARK: - Analytics & Data Processing
    private var cancellables = Set<AnyCancellable>()
    private var analysisTimer: Timer?
    
    private init() {
        setupDataObservation()
        startPeriodicAnalysis()
        loadMLModels()
    }
    
    // MARK: - Data Observation Setup
    private func setupDataObservation() {
        // Observe health data changes
        healthKitManager.$todaysMetrics
            .sink { [weak self] _ in
                Task { await self?.analyzeUserData() }
            }
            .store(in: &cancellables)
        
        // Observe meal data changes
        mealAnalysisManager.$savedMeals
            .sink { [weak self] _ in
                Task { await self?.analyzeNutritionPatterns() }
            }
            .store(in: &cancellables)
        
        // Observe workout data changes
        workoutManager.$currentWorkout
            .sink { [weak self] _ in
                Task { await self?.analyzeWorkoutPatterns() }
            }
            .store(in: &cancellables)
    }
    
    private func startPeriodicAnalysis() {
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            Task { await self?.generateDailyRecommendations() }
        }
    }
    
    // MARK: - ML Model Loading (Future Implementation)
    private func loadMLModels() {
        // In production, load trained CoreML models
        // nutritionModel = try? MLModel(contentsOf: nutritionModelURL)
        // workoutModel = try? MLModel(contentsOf: workoutModelURL)
        // synergyModel = try? MLModel(contentsOf: synergyModelURL)
    }
    
    // MARK: - Main Analysis Functions
    func analyzeUserData() async {
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        // Collect all user data
        let healthMetrics = healthKitManager.todaysMetrics
        let recentWorkouts = healthKitManager.recentWorkouts
        let recentMeals = mealAnalysisManager.getMealsForToday()
        let weeklyTrends = healthKitManager.weeklyTrends
        
        // Analyze patterns
        let analytics = analyzeUserPatterns(
            healthMetrics: healthMetrics,
            workouts: recentWorkouts,
            meals: recentMeals,
            trends: weeklyTrends
        )
        
        userAnalytics = analytics
        
        // Generate recommendations
        await generateDailyRecommendations()
        await generateSynergyRecommendations()
        
        lastAnalysisDate = Date()
    }
    
    private func analyzeUserPatterns(
        healthMetrics: HealthMetrics,
        workouts: [WorkoutData],
        meals: [SavedMeal],
        trends: [HealthMetrics]
    ) -> UserAnalytics {
        
        // Calculate workout frequency
        let workoutFrequency = Double(workouts.count) / 7.0
        
        // Calculate average workout duration
        let avgDuration = workouts.isEmpty ? 0 : workouts.reduce(0) { $0 + $1.duration } / Double(workouts.count)
        
        // Analyze workout consistency
        let workoutConsistency = calculateWorkoutConsistency(workouts)
        
        // Analyze nutrition consistency
        let nutritionConsistency = calculateNutritionConsistency(meals)
        
        // Calculate BMR
        let bmr = calculateBasalMetabolicRate(metrics: healthMetrics)
        
        // Calculate TDEE
        let activityLevel = determineActivityLevel(workouts: workouts, metrics: healthMetrics)
        let tdee = bmr * activityLevel.multiplier
        
        // Analyze trends
        let progressTrends = analyzeProgressTrends(trends)
        
        return UserAnalytics(
            weeklyWorkoutFrequency: workoutFrequency,
            averageWorkoutDuration: avgDuration,
            preferredWorkoutDays: analyzePreferredWorkoutDays(workouts),
            workoutConsistency: workoutConsistency,
            nutritionConsistency: nutritionConsistency,
            sleepQuality: healthMetrics.sleepHours / 8.0, // Simplified
            stressLevel: calculateStressLevel(metrics: healthMetrics),
            energyLevels: calculateEnergyLevels(trends),
            progressTrends: progressTrends,
            metabolicData: MetabolicData(
                basalMetabolicRate: bmr,
                totalDailyEnergyExpenditure: tdee,
                macroRatios: calculateMacroRatios(meals),
                metabolicEfficiency: calculateMetabolicEfficiency(metrics: healthMetrics),
                insulinSensitivity: calculateInsulinSensitivity(meals: meals, metrics: healthMetrics)
            )
        )
    }
    
    // MARK: - Recommendation Generation
    func generateDailyRecommendations() async {
        guard let analytics = userAnalytics else { return }
        
        var recommendations: [FitnessRecommendation] = []
        
        // Workout recommendations
        recommendations.append(contentsOf: generateWorkoutRecommendations(analytics))
        
        // Nutrition recommendations
        recommendations.append(contentsOf: generateNutritionRecommendations(analytics))
        
        // Recovery recommendations
        recommendations.append(contentsOf: generateRecoveryRecommendations(analytics))
        
        // Health recommendations
        recommendations.append(contentsOf: generateHealthRecommendations(analytics))
        
        // Sort by priority and confidence
        recommendations.sort { first, second in
            if first.priority.rawValue != second.priority.rawValue {
                return first.priority.rawValue > second.priority.rawValue
            }
            return first.confidence > second.confidence
        }
        
        dailyRecommendations = Array(recommendations.prefix(8)) // Top 8 recommendations
        urgentRecommendations = recommendations.filter { $0.priority == .critical || $0.priority == .high }
    }
    
    private func generateWorkoutRecommendations(_ analytics: UserAnalytics) -> [FitnessRecommendation] {
        var recommendations: [FitnessRecommendation] = []
        
        if analytics.weeklyWorkoutFrequency < 3 {
            recommendations.append(FitnessRecommendation(
                type: .workout,
                title: "Increase Workout Frequency",
                description: "You're currently working out \(String(format: "%.1f", analytics.weeklyWorkoutFrequency)) times per week. Aim for 3-5 sessions for optimal health benefits.",
                priority: .high,
                confidence: 0.9,
                actionItems: [
                    ActionItem(
                        title: "Schedule 2 Additional Workouts",
                        description: "Add moderate-intensity sessions on your less active days",
                        type: .workout,
                        estimatedDuration: 1800, // 30 minutes
                        difficulty: .beginner,
                        completionTracking: true
                    )
                ],
                expectedBenefit: "Improved cardiovascular health, better mood, increased energy",
                timeframe: "2-3 weeks",
                personalizedReason: "Based on your current activity level and health goals",
                scientificBasis: "WHO recommends 150 minutes of moderate-intensity aerobic activity per week"
            ))
        }
        
        // Check workout consistency
        if analytics.workoutConsistency < 0.7 {
            recommendations.append(FitnessRecommendation(
                type: .workout,
                title: "Improve Workout Consistency",
                description: "Your workout consistency is at \(Int(analytics.workoutConsistency * 100))%. Building a routine will maximize your results.",
                priority: .medium,
                confidence: 0.85,
                actionItems: [
                    ActionItem(
                        title: "Set Fixed Workout Days",
                        description: "Choose 3 specific days each week for your workouts",
                        type: .lifestyle,
                        estimatedDuration: 300, // 5 minutes planning
                        difficulty: .beginner,
                        completionTracking: true
                    )
                ],
                expectedBenefit: "Better progress tracking, habit formation, improved results",
                timeframe: "4-6 weeks",
                personalizedReason: "Consistency is key to achieving your fitness goals",
                scientificBasis: "Studies show regular exercise patterns improve long-term adherence"
            ))
        }
        
        // Progressive overload check
        if analytics.progressTrends.strengthTrend == .stable || analytics.progressTrends.strengthTrend == .declining {
            recommendations.append(FitnessRecommendation(
                type: .workout,
                title: "Progressive Overload Training",
                description: "Your strength progress has plateaued. Implement progressive overload to continue gaining strength.",
                priority: .medium,
                confidence: 0.8,
                actionItems: [
                    ActionItem(
                        title: "Increase Training Intensity",
                        description: "Add 5-10% more weight or reps to your current routine",
                        type: .workout,
                        estimatedDuration: 2700, // 45 minutes
                        difficulty: .intermediate,
                        completionTracking: true
                    )
                ],
                expectedBenefit: "Continued strength gains, muscle development, improved performance",
                timeframe: "2-4 weeks",
                personalizedReason: "Your body has adapted to your current training stimulus",
                scientificBasis: "Progressive overload is fundamental to continued strength development"
            ))
        }
        
        return recommendations
    }
    
    private func generateNutritionRecommendations(_ analytics: UserAnalytics) -> [FitnessRecommendation] {
        var recommendations: [FitnessRecommendation] = []
        
        // Check protein intake
        if analytics.metabolicData.macroRatios.proteinRatio < 0.15 {
            recommendations.append(FitnessRecommendation(
                type: .nutrition,
                title: "Increase Protein Intake",
                description: "Your protein intake is below optimal levels for your activity level and goals.",
                priority: .high,
                confidence: 0.9,
                actionItems: [
                    ActionItem(
                        title: "Add Protein-Rich Snacks",
                        description: "Include Greek yogurt, nuts, or protein shakes between meals",
                        type: .meal,
                        estimatedDuration: 600, // 10 minutes prep
                        difficulty: .beginner,
                        completionTracking: true
                    )
                ],
                expectedBenefit: "Better muscle recovery, improved satiety, enhanced body composition",
                timeframe: "1-2 weeks",
                personalizedReason: "Based on your workout frequency and body composition goals",
                scientificBasis: "Active individuals need 1.6-2.2g protein per kg body weight daily"
            ))
        }
        
        // Check meal timing
        let todaysMeals = mealAnalysisManager.getMealsForToday()
        if hasSuboptimalMealTiming(todaysMeals) {
            recommendations.append(FitnessRecommendation(
                type: .nutrition,
                title: "Optimize Meal Timing",
                description: "Your meal timing could be optimized for better energy levels and workout performance.",
                priority: .medium,
                confidence: 0.75,
                actionItems: [
                    ActionItem(
                        title: "Pre-Workout Nutrition",
                        description: "Eat a balanced meal 2-3 hours before workouts",
                        type: .meal,
                        estimatedDuration: 900, // 15 minutes
                        difficulty: .beginner,
                        completionTracking: true
                    )
                ],
                expectedBenefit: "Improved workout performance, better recovery, stable energy",
                timeframe: "1 week",
                personalizedReason: "Your current meal timing doesn't align with your workout schedule",
                scientificBasis: "Proper nutrient timing enhances exercise performance and recovery"
            ))
        }
        
        // Hydration check
        if analytics.metabolicData.metabolicEfficiency < 0.8 {
            recommendations.append(FitnessRecommendation(
                type: .nutrition,
                title: "Improve Hydration",
                description: "Your metabolic efficiency suggests you may need to focus on hydration.",
                priority: .medium,
                confidence: 0.7,
                actionItems: [
                    ActionItem(
                        title: "Increase Water Intake",
                        description: "Aim for 35ml per kg body weight plus 500-750ml per hour of exercise",
                        type: .lifestyle,
                        estimatedDuration: 0, // Ongoing
                        difficulty: .beginner,
                        completionTracking: true
                    )
                ],
                expectedBenefit: "Better performance, improved recovery, enhanced metabolism",
                timeframe: "Immediate",
                personalizedReason: "Proper hydration is crucial for your activity level",
                scientificBasis: "Even 2% dehydration can significantly impact performance"
            ))
        }
        
        return recommendations
    }
    
    private func generateRecoveryRecommendations(_ analytics: UserAnalytics) -> [FitnessRecommendation] {
        var recommendations: [FitnessRecommendation] = []
        
        // Sleep analysis
        if analytics.sleepQuality < 0.7 {
            recommendations.append(FitnessRecommendation(
                type: .recovery,
                title: "Improve Sleep Quality",
                description: "Your sleep quality is below optimal levels, which can impact recovery and performance.",
                priority: .high,
                confidence: 0.9,
                actionItems: [
                    ActionItem(
                        title: "Establish Sleep Routine",
                        description: "Go to bed and wake up at the same time daily, aim for 7-9 hours",
                        type: .lifestyle,
                        estimatedDuration: 0, // Ongoing
                        difficulty: .beginner,
                        completionTracking: true
                    )
                ],
                expectedBenefit: "Better recovery, improved performance, enhanced mood",
                timeframe: "1-2 weeks",
                personalizedReason: "Quality sleep is essential for your training goals",
                scientificBasis: "Sleep is when muscle repair and growth hormone release occur"
            ))
        }
        
        // Stress level check
        if analytics.stressLevel > 0.7 {
            recommendations.append(FitnessRecommendation(
                type: .recovery,
                title: "Stress Management",
                description: "High stress levels can interfere with recovery and progress.",
                priority: .medium,
                confidence: 0.8,
                actionItems: [
                    ActionItem(
                        title: "Add Meditation or Yoga",
                        description: "Incorporate 10-15 minutes of mindfulness practice daily",
                        type: .lifestyle,
                        estimatedDuration: 900, // 15 minutes
                        difficulty: .beginner,
                        completionTracking: true
                    )
                ],
                expectedBenefit: "Reduced stress, better recovery, improved focus",
                timeframe: "2-4 weeks",
                personalizedReason: "Your current stress levels may be impacting your fitness goals",
                scientificBasis: "Chronic stress elevates cortisol, which can impair recovery"
            ))
        }
        
        return recommendations
    }
    
    private func generateHealthRecommendations(_ analytics: UserAnalytics) -> [FitnessRecommendation] {
        var recommendations: [FitnessRecommendation] = []
        
        // Heart rate variability check
        let healthMetrics = healthKitManager.todaysMetrics
        if healthMetrics.heartRateVariability > 0 && healthMetrics.heartRateVariability < 20 {
            recommendations.append(FitnessRecommendation(
                type: .health,
                title: "Improve Heart Rate Variability",
                description: "Your HRV suggests your autonomic nervous system may benefit from recovery focus.",
                priority: .medium,
                confidence: 0.75,
                actionItems: [
                    ActionItem(
                        title: "Breathing Exercises",
                        description: "Practice 4-7-8 breathing technique for 5 minutes daily",
                        type: .lifestyle,
                        estimatedDuration: 300, // 5 minutes
                        difficulty: .beginner,
                        completionTracking: true
                    )
                ],
                expectedBenefit: "Improved recovery, better stress resilience, enhanced performance",
                timeframe: "2-3 weeks",
                personalizedReason: "Based on your heart rate variability patterns",
                scientificBasis: "HRV training can improve autonomic nervous system function"
            ))
        }
        
        return recommendations
    }
    
    // MARK: - Meal-Workout Synergy Recommendations
    func generateSynergyRecommendations() async {
        var synergies: [FitnessRecommendation] = []
        
        let recentWorkouts = healthKitManager.recentWorkouts
        let recentMeals = mealAnalysisManager.getMealsForToday()
        
        // Pre-workout nutrition synergy
        if let nextWorkout = findNextScheduledWorkout() {
            synergies.append(generatePreWorkoutNutritionRecommendation(for: nextWorkout))
        }
        
        // Post-workout recovery synergy
        if let lastWorkout = recentWorkouts.first {
            if shouldRecommendPostWorkoutNutrition(workout: lastWorkout, meals: recentMeals) {
                synergies.append(generatePostWorkoutNutritionRecommendation(for: lastWorkout))
            }
        }
        
        // Training adaptation synergy
        synergies.append(contentsOf: generateTrainingAdaptationSynergies(workouts: recentWorkouts, meals: recentMeals))
        
        synergyRecommendations = synergies
    }
    
    private func generatePreWorkoutNutritionRecommendation(for workout: HKWorkoutActivityType) -> FitnessRecommendation {
        let carbAmount: String
        let timing: String
        
        switch workout {
        case .running, .cycling:
            carbAmount = "30-60g carbohydrates"
            timing = "1-3 hours before"
        case .functionalStrengthTraining, .traditionalStrengthTraining:
            carbAmount = "20-30g carbohydrates"
            timing = "1-2 hours before"
        default:
            carbAmount = "15-30g carbohydrates"
            timing = "1 hour before"
        }
        
        return FitnessRecommendation(
            type: .combination,
            title: "Pre-Workout Fuel Strategy",
            description: "Optimize your upcoming \(workout.displayName) session with targeted nutrition.",
            priority: .medium,
            confidence: 0.85,
            actionItems: [
                ActionItem(
                    title: "Pre-Workout Meal",
                    description: "Consume \(carbAmount) with moderate protein \(timing) your workout",
                    type: .meal,
                    estimatedDuration: 900, // 15 minutes
                    difficulty: .beginner,
                    completionTracking: true
                )
            ],
            expectedBenefit: "Enhanced workout performance, sustained energy, better endurance",
            timeframe: "Immediate",
            personalizedReason: "Tailored for your upcoming \(workout.displayName) session",
            scientificBasis: "Carbohydrate intake before exercise improves performance and delays fatigue"
        )
    }
    
    private func generatePostWorkoutNutritionRecommendation(for workout: WorkoutData) -> FitnessRecommendation {
        let proteinAmount = calculateOptimalPostWorkoutProtein(workout: workout)
        let carbAmount = calculateOptimalPostWorkoutCarbs(workout: workout)
        
        return FitnessRecommendation(
            type: .combination,
            title: "Post-Workout Recovery Nutrition",
            description: "Maximize recovery from your recent \(workout.type.displayName) session.",
            priority: .high,
            confidence: 0.9,
            actionItems: [
                ActionItem(
                    title: "Recovery Meal",
                    description: "Consume \(proteinAmount)g protein and \(carbAmount)g carbs within 2 hours",
                    type: .meal,
                    estimatedDuration: 1200, // 20 minutes
                    difficulty: .beginner,
                    completionTracking: true
                )
            ],
            expectedBenefit: "Faster recovery, muscle protein synthesis, glycogen replenishment",
            timeframe: "Within 2 hours",
            personalizedReason: "Based on your recent \(String(format: "%.0f", workout.duration/60))-minute \(workout.type.displayName) session",
            scientificBasis: "Post-exercise nutrition window optimizes recovery adaptations"
        )
    }
    
    private func generateTrainingAdaptationSynergies(workouts: [WorkoutData], meals: [SavedMeal]) -> [FitnessRecommendation] {
        var synergies: [FitnessRecommendation] = []
        
        // Analyze workout-nutrition patterns
        let strengthWorkouts = workouts.filter { isStrengthWorkout($0.type) }
        let enduranceWorkouts = workouts.filter { isEnduranceWorkout($0.type) }
        
        if !strengthWorkouts.isEmpty {
            let avgProteinIntake = calculateAverageProteinIntake(meals)
            if avgProteinIntake < getOptimalProteinForStrength() {
                synergies.append(createStrengthNutritionSynergy(avgProtein: avgProteinIntake))
            }
        }
        
        if !enduranceWorkouts.isEmpty {
            let avgCarbIntake = calculateAverageCarbIntake(meals)
            if avgCarbIntake < getOptimalCarbsForEndurance() {
                synergies.append(createEnduranceNutritionSynergy(avgCarbs: avgCarbIntake))
            }
        }
        
        return synergies
    }
    
    // MARK: - Helper Functions
    private func calculateWorkoutConsistency(_ workouts: [WorkoutData]) -> Double {
        guard !workouts.isEmpty else { return 0.0 }
        
        let calendar = Calendar.current
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: Date())!
        let expectedWorkouts = 4.0 // Assuming 4 workouts per week is ideal
        let actualWorkouts = Double(workouts.count)
        
        return min(1.0, actualWorkouts / expectedWorkouts)
    }
    
    private func calculateNutritionConsistency(_ meals: [SavedMeal]) -> Double {
        guard !meals.isEmpty else { return 0.0 }
        
        let targetMealsPerDay = 3.0
        let daysWithData = 7.0 // Last 7 days
        let expectedMeals = targetMealsPerDay * daysWithData
        let actualMeals = Double(meals.count)
        
        return min(1.0, actualMeals / expectedMeals)
    }
    
    private func calculateBasalMetabolicRate(metrics: HealthMetrics) -> Double {
        // Mifflin-St Jeor Equation
        // For now, use default values if health data not available
        let weight = metrics.bodyWeight > 0 ? metrics.bodyWeight : 70.0
        let height = 175.0 // Default height in cm
        let age = 30.0 // Default age
        
        // Assuming male for simplicity (in production, get from user profile)
        return 10 * weight + 6.25 * height - 5 * age + 5
    }
    
    private func determineActivityLevel(workouts: [WorkoutData], metrics: HealthMetrics) -> ActivityLevel {
        let weeklyWorkouts = workouts.count
        let avgSteps = metrics.steps
        
        if weeklyWorkouts >= 6 || avgSteps > 12000 {
            return .veryActive
        } else if weeklyWorkouts >= 4 || avgSteps > 8000 {
            return .moderatelyActive
        } else if weeklyWorkouts >= 2 || avgSteps > 5000 {
            return .lightlyActive
        } else {
            return .sedentary
        }
    }
    
    private func analyzeProgressTrends(_ trends: [HealthMetrics]) -> ProgressTrends {
        guard trends.count >= 3 else {
            return ProgressTrends(
                weightTrend: .noData,
                strengthTrend: .noData,
                enduranceTrend: .noData,
                bodyCompositionTrend: .noData,
                overallFitnessTrend: .noData
            )
        }
        
        // Analyze step count trend as proxy for endurance
        let stepTrend = analyzeTrend(trends.map { $0.steps })
        
        // Analyze calorie burn trend as proxy for overall fitness
        let calorieTrend = analyzeTrend(trends.map { $0.calories })
        
        return ProgressTrends(
            weightTrend: .stable, // Would need weight data
            strengthTrend: .stable, // Would need strength data
            enduranceTrend: stepTrend,
            bodyCompositionTrend: .stable, // Would need body composition data
            overallFitnessTrend: calorieTrend
        )
    }
    
    private func analyzeTrend(_ values: [Double]) -> TrendDirection {
        guard values.count >= 3 else { return .noData }
        
        let firstHalf = values.prefix(values.count / 2)
        let secondHalf = values.suffix(values.count / 2)
        
        let firstAvg = firstHalf.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0, +) / Double(secondHalf.count)
        
        let change = (secondAvg - firstAvg) / firstAvg
        
        if change > 0.05 {
            return .improving
        } else if change < -0.05 {
            return .declining
        } else {
            return .stable
        }
    }
    
    private func analyzePreferredWorkoutDays(_ workouts: [WorkoutData]) -> [Int] {
        let calendar = Calendar.current
        var dayFrequency: [Int: Int] = [:]
        
        for workout in workouts {
            let weekday = calendar.component(.weekday, from: workout.startDate)
            dayFrequency[weekday, default: 0] += 1
        }
        
        return dayFrequency.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
    }
    
    private func calculateStressLevel(metrics: HealthMetrics) -> Double {
        // Simplified stress calculation based on HRV and resting HR
        let restingHR = metrics.restingHeartRate
        let hrv = metrics.heartRateVariability
        
        if restingHR > 80 || hrv < 20 {
            return 0.8 // High stress
        } else if restingHR > 70 || hrv < 30 {
            return 0.5 // Moderate stress
        } else {
            return 0.2 // Low stress
        }
    }
    
    private func calculateEnergyLevels(_ trends: [HealthMetrics]) -> [Double] {
        // Simplified energy calculation based on activity levels
        return trends.map { metrics in
            let stepsRatio = min(1.0, metrics.steps / 10000.0)
            let sleepRatio = min(1.0, metrics.sleepHours / 8.0)
            return (stepsRatio + sleepRatio) / 2.0
        }
    }
    
    private func calculateMacroRatios(_ meals: [SavedMeal]) -> MacroRatios {
        guard !meals.isEmpty else {
            return MacroRatios(proteinRatio: 0.2, carbRatio: 0.5, fatRatio: 0.3)
        }
        
        let totalCalories = meals.reduce(0) { $0 + $1.totalNutrition.calories }
        let totalProtein = meals.reduce(0) { $0 + $1.totalNutrition.protein }
        let totalCarbs = meals.reduce(0) { $0 + $1.totalNutrition.carbs }
        let totalFat = meals.reduce(0) { $0 + $1.totalNutrition.fat }
        
        guard totalCalories > 0 else {
            return MacroRatios(proteinRatio: 0.2, carbRatio: 0.5, fatRatio: 0.3)
        }
        
        let proteinCals = totalProtein * 4
        let carbCals = totalCarbs * 4
        let fatCals = totalFat * 9
        
        return MacroRatios(
            proteinRatio: proteinCals / totalCalories,
            carbRatio: carbCals / totalCalories,
            fatRatio: fatCals / totalCalories
        )
    }
    
    private func calculateMetabolicEfficiency(metrics: HealthMetrics) -> Double {
        // Simplified calculation based on available metrics
        let heartRateEfficiency = metrics.restingHeartRate > 0 ? min(1.0, 80.0 / metrics.restingHeartRate) : 0.8
        let activityEfficiency = min(1.0, metrics.steps / 10000.0)
        
        return (heartRateEfficiency + activityEfficiency) / 2.0
    }
    
    private func calculateInsulinSensitivity(meals: [SavedMeal], metrics: HealthMetrics) -> Double {
        // Simplified calculation (in production, would use glucose data if available)
        let carbIntake = meals.reduce(0) { $0 + $1.totalNutrition.carbs }
        let activityLevel = min(1.0, metrics.steps / 10000.0)
        
        // Higher activity generally improves insulin sensitivity
        return 0.7 + (activityLevel * 0.3)
    }
    
    // Additional helper functions for synergy recommendations
    private func findNextScheduledWorkout() -> HKWorkoutActivityType? {
        // In production, this would check user's calendar or workout schedule
        // For now, return a common workout type
        return .running
    }
    
    private func shouldRecommendPostWorkoutNutrition(workout: WorkoutData, meals: [SavedMeal]) -> Bool {
        let workoutEnd = workout.endDate
        let twoHoursAfter = Calendar.current.date(byAdding: .hour, value: 2, to: workoutEnd) ?? Date()
        
        // Check if user has eaten sufficient protein/carbs after workout
        let postWorkoutMeals = meals.filter { $0.timestamp > workoutEnd && $0.timestamp < twoHoursAfter }
        let totalProtein = postWorkoutMeals.reduce(0) { $0 + $1.totalNutrition.protein }
        
        return totalProtein < 20 // Recommend if less than 20g protein consumed
    }
    
    private func calculateOptimalPostWorkoutProtein(workout: WorkoutData) -> Int {
        switch workout.type {
        case .functionalStrengthTraining, .traditionalStrengthTraining:
            return 25
        case .running, .cycling:
            return 20
        default:
            return 15
        }
    }
    
    private func calculateOptimalPostWorkoutCarbs(workout: WorkoutData) -> Int {
        let duration = workout.duration / 3600.0 // Convert to hours
        
        if duration > 1.5 {
            return Int(1.5 * 70) // 1.5g per kg body weight (assuming 70kg)
        } else if duration > 1.0 {
            return Int(1.0 * 70)
        } else {
            return Int(0.5 * 70)
        }
    }
    
    private func isStrengthWorkout(_ type: HKWorkoutActivityType) -> Bool {
        return [.functionalStrengthTraining, .traditionalStrengthTraining, .coreTraining].contains(type)
    }
    
    private func isEnduranceWorkout(_ type: HKWorkoutActivityType) -> Bool {
        return [.running, .cycling, .swimming, .walking].contains(type)
    }
    
    private func calculateAverageProteinIntake(_ meals: [SavedMeal]) -> Double {
        guard !meals.isEmpty else { return 0 }
        return meals.reduce(0) { $0 + $1.totalNutrition.protein } / Double(meals.count)
    }
    
    private func calculateAverageCarbIntake(_ meals: [SavedMeal]) -> Double {
        guard !meals.isEmpty else { return 0 }
        return meals.reduce(0) { $0 + $1.totalNutrition.carbs } / Double(meals.count)
    }
    
    private func getOptimalProteinForStrength() -> Double {
        return 1.6 * 70 // 1.6g per kg body weight (assuming 70kg)
    }
    
    private func getOptimalCarbsForEndurance() -> Double {
        return 6.0 * 70 // 6g per kg body weight for endurance athletes
    }
    
    private func createStrengthNutritionSynergy(avgProtein: Double) -> FitnessRecommendation {
        let deficit = getOptimalProteinForStrength() - avgProtein
        
        return FitnessRecommendation(
            type: .combination,
            title: "Strength Training Nutrition Optimization",
            description: "Enhance your strength training results with optimized protein intake.",
            priority: .medium,
            confidence: 0.85,
            actionItems: [
                ActionItem(
                    title: "Increase Daily Protein",
                    description: "Add \(String(format: "%.0f", deficit))g protein to support muscle development",
                    type: .meal,
                    estimatedDuration: 900,
                    difficulty: .beginner,
                    completionTracking: true
                )
            ],
            expectedBenefit: "Enhanced muscle protein synthesis, better strength gains",
            timeframe: "2-4 weeks",
            personalizedReason: "Your strength training frequency requires higher protein intake",
            scientificBasis: "Resistance training increases protein requirements to 1.6-2.2g/kg"
        )
    }
    
    private func createEnduranceNutritionSynergy(avgCarbs: Double) -> FitnessRecommendation {
        let deficit = getOptimalCarbsForEndurance() - avgCarbs
        
        return FitnessRecommendation(
            type: .combination,
            title: "Endurance Training Fuel Strategy",
            description: "Optimize carbohydrate intake to support your endurance training.",
            priority: .medium,
            confidence: 0.8,
            actionItems: [
                ActionItem(
                    title: "Increase Carbohydrate Intake",
                    description: "Add \(String(format: "%.0f", deficit))g quality carbs to fuel performance",
                    type: .meal,
                    estimatedDuration: 900,
                    difficulty: .beginner,
                    completionTracking: true
                )
            ],
            expectedBenefit: "Improved endurance, better recovery, sustained energy",
            timeframe: "1-2 weeks",
            personalizedReason: "Your endurance training volume requires higher carbohydrate intake",
            scientificBasis: "Endurance athletes need 6-10g carbohydrates per kg body weight daily"
        )
    }
    
    private func hasSuboptimalMealTiming(_ meals: [SavedMeal]) -> Bool {
        // Check if meals are too close to typical workout times
        let calendar = Calendar.current
        
        for meal in meals {
            let hour = calendar.component(.hour, from: meal.timestamp)
            
            // Check for meals within 1 hour of common workout times (7 AM, 12 PM, 6 PM)
            if [6, 7, 8, 11, 12, 13, 17, 18, 19].contains(hour) {
                return true
            }
        }
        
        return false
    }
    
    func analyzeNutritionPatterns() async {
        // This would analyze nutrition patterns and update recommendations
        await generateDailyRecommendations()
    }
    
    func analyzeWorkoutPatterns() async {
        // This would analyze workout patterns and update recommendations
        await generateDailyRecommendations()
    }
    
    deinit {
        analysisTimer?.invalidate()
    }
}
