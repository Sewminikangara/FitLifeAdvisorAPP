//
//  MealPlanManager.swift
//  FitLifeAdvisorApp
//
//  Minimal generator for a weekly meal plan and shopping list aggregation.
//

import Foundation

final class MealPlanManager {
	// Basic sample recipe database
	private let recipes: [MealRecipe] = [
		MealRecipe(
			name: "Protein Smoothie Bowl",
			slot: .breakfast,
			ingredients: [
				Ingredient(name: "Greek Yogurt", unit: "cup", quantity: 1),
				Ingredient(name: "Banana", unit: "pc", quantity: 1),
				Ingredient(name: "Mixed Berries", unit: "cup", quantity: 1),
				Ingredient(name: "Whey Protein", unit: "scoop", quantity: 1)
			],
			calories: 420,
			tags: [.balanced, .highProtein]
	),
	MealRecipe(
			name: "Avocado Toast",
			slot: .breakfast,
			ingredients: [
				Ingredient(name: "Wholegrain Bread", unit: "slice", quantity: 2),
				Ingredient(name: "Avocado", unit: "pc", quantity: 1),
				Ingredient(name: "Cherry Tomato", unit: "pc", quantity: 6)
			],
			calories: 360,
			tags: [.balanced, .vegetarian, .vegan]
	),
	MealRecipe(
			name: "Grilled Chicken Salad",
			slot: .lunch,
			ingredients: [
				Ingredient(name: "Chicken Breast", unit: "g", quantity: 150),
				Ingredient(name: "Mixed Greens", unit: "cup", quantity: 2),
				Ingredient(name: "Olive Oil", unit: "tbsp", quantity: 1),
				Ingredient(name: "Quinoa", unit: "cup", quantity: 0.5)
			],
			calories: 520,
			tags: [.balanced, .highProtein]
	),
	MealRecipe(
			name: "Buddha Bowl",
			slot: .lunch,
			ingredients: [
				Ingredient(name: "Brown Rice", unit: "cup", quantity: 1),
				Ingredient(name: "Chickpeas", unit: "cup", quantity: 1),
				Ingredient(name: "Spinach", unit: "cup", quantity: 2)
			],
			calories: 540,
			tags: [.balanced, .vegetarian, .vegan]
	),
	MealRecipe(
			name: "Salmon with Quinoa",
			slot: .dinner,
			ingredients: [
				Ingredient(name: "Salmon Fillet", unit: "g", quantity: 180),
				Ingredient(name: "Quinoa", unit: "cup", quantity: 1),
				Ingredient(name: "Broccoli", unit: "cup", quantity: 1)
			],
			calories: 610,
			tags: [.balanced]
	),
	MealRecipe(
			name: "Lentil Curry",
			slot: .dinner,
			ingredients: [
				Ingredient(name: "Red Lentils", unit: "cup", quantity: 1),
				Ingredient(name: "Coconut Milk", unit: "cup", quantity: 0.5),
				Ingredient(name: "Onion", unit: "pc", quantity: 1)
			],
			calories: 580,
			tags: [.vegetarian, .vegan]
	),
	MealRecipe(
			name: "Greek Yogurt Parfait",
			slot: .snack,
			ingredients: [
				Ingredient(name: "Greek Yogurt", unit: "cup", quantity: 0.5),
				Ingredient(name: "Granola", unit: "cup", quantity: 0.25),
				Ingredient(name: "Honey", unit: "tsp", quantity: 1)
			],
			calories: 220,
			tags: [.balanced]
	),
	MealRecipe(
			name: "Apple & Peanut Butter",
			slot: .snack,
			ingredients: [
				Ingredient(name: "Apple", unit: "pc", quantity: 1),
				Ingredient(name: "Peanut Butter", unit: "tbsp", quantity: 1)
			],
			calories: 200,
			tags: [.balanced, .vegetarian, .vegan]
		),
	]

	func generateWeeklyPlan(starting startDate: Date = Date(), preference: DietaryPreference) -> WeeklyMealPlan {
		let calendar = Calendar.current
		let startOfDay = calendar.startOfDay(for: startDate)
		var days: [DayMealPlan] = []
		for offset in 0..<7 {
			guard let date = calendar.date(byAdding: .day, value: offset, to: startOfDay) else { continue }
			let meals = MealSlot.allCases.compactMap { slot -> PlannedMeal? in
				let options = recipes.filter { $0.slot == slot && ($0.tags.contains(preference) || $0.tags.contains(.balanced)) }
				guard let recipe = options.randomElement() else { return nil }
				return PlannedMeal(slot: slot, recipe: recipe)
			}
			days.append(DayMealPlan(date: date, meals: meals))
		}
		return WeeklyMealPlan(startDate: startOfDay, days: days)
	}

	func buildShoppingList(for plan: WeeklyMealPlan) -> ShoppingList {
		var aggregate: [String: ShoppingItem] = [:] // key: name+unit
		for day in plan.days {
			for meal in day.meals {
				for ing in meal.recipe.ingredients {
					let key = ing.name.lowercased() + "_" + ing.unit.lowercased()
					if var existing = aggregate[key] {
						let newQty = existing.totalQuantity + ing.quantity
						aggregate[key] = ShoppingItem(name: existing.name, unit: existing.unit, totalQuantity: newQty)
					} else {
						aggregate[key] = ShoppingItem(name: ing.name, unit: ing.unit, totalQuantity: ing.quantity)
					}
				}
			}
		}
		let items = aggregate.values.sorted { $0.name < $1.name }
		return ShoppingList(items: items)
	}
}

