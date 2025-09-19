import Foundation

struct RecipeModel: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let ingredients: [RecipeIngredient]
    let category: RecipeCategory
    let calories: Int
}

struct RecipeIngredient: Identifiable {
    let id = UUID()
    let name: String
    let quantity: Double
    let unit: String
}

enum RecipeCategory: String, CaseIterable {
    case breakfast, lunch, dinner, snack, dessert, smoothie
}