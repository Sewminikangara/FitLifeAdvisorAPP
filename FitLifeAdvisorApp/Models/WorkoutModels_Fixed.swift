import Foundation

struct WorkoutFixed: Identifiable {
    let id = UUID()
    let name: String
    let duration: Int // minutes
    let caloriesBurned: Int
    let exercises: [ExerciseFixed]
}

struct ExerciseFixed: Identifiable {
    let id = UUID()
    let name: String
    let reps: Int
    let sets: Int
}