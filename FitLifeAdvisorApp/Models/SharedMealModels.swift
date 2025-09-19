import Foundation

struct SharedMeal: Identifiable {
    let id = UUID()
    let name: String
    let participants: [SharedMealParticipant]
    let totalCalories: Double
    let timestamp: Date
}

struct SharedMealParticipant: Identifiable {
    let id = UUID()
    let name: String
    let caloriesConsumed: Double
}