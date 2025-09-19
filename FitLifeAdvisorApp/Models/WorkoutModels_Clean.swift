import Foundation

struct WorkoutClean: Identifiable {
    let id = UUID()
    let name: String
    let duration: Int // minutes
    let caloriesBurned: Int
    let exercises: [ExerciseClean]
}

struct ExerciseClean: Identifiable {
    let id = UUID()
    let name: String
    let reps: Int
    let sets: Int
}