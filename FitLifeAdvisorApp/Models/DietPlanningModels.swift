//
//  DietPlanningModels.swift
//  FitLifeAdvisorApp
//
//  Basic models for meal plan generation and shopping list.
//

import Foundation

public enum DietaryPreference: String, CaseIterable, Codable, Identifiable {
	case balanced
	case highProtein
	case vegetarian
	case vegan
    
	public var id: String { rawValue }
	public var displayName: String {
		switch self {
		case .balanced: return "Balanced"
		case .highProtein: return "High Protein"
		case .vegetarian: return "Vegetarian"
		case .vegan: return "Vegan"
		}
	}
}

public enum MealSlot: String, Codable, CaseIterable, Identifiable {
	case breakfast
	case lunch
	case dinner
	case snack
    
	public var id: String { rawValue }
	public var displayName: String { rawValue.capitalized }
}

public struct Ingredient: Hashable, Codable, Identifiable {
	public var id: String { name.lowercased() + "_" + unit.lowercased() }
	public let name: String
	public let unit: String
	public let quantity: Double
    
	public init(name: String, unit: String, quantity: Double) {
		self.name = name
		self.unit = unit
		self.quantity = quantity
	}
}

public struct MealRecipe: Codable, Identifiable {
	public let id = UUID()
	public let name: String
	public let slot: MealSlot
	public let ingredients: [Ingredient]
	public let calories: Int
	public let tags: [DietaryPreference]
}

public struct PlannedMeal: Codable, Identifiable {
	public let id = UUID()
	public let slot: MealSlot
	public let recipe: MealRecipe
}

public struct DayMealPlan: Codable, Identifiable {
	public let id = UUID()
	public let date: Date
	public let meals: [PlannedMeal]
}

public struct WeeklyMealPlan: Codable {
	public let startDate: Date
	public let days: [DayMealPlan] // 7 days
}

public struct ShoppingItem: Codable, Identifiable {
	public var id: String { name.lowercased() + "_" + unit.lowercased() }
	public let name: String
	public let unit: String
	public let totalQuantity: Double
}

public struct ShoppingList: Codable {
	public let items: [ShoppingItem]
}

