//
//  DietPlanningManager.swift
//  FitLifeAdvisorApp
//
//  Facade exposing meal plan and shopping list generation.
//

import Foundation

final class DietPlanningManager: ObservableObject {
	private let mealPlanManager = MealPlanManager()
	@Published var weeklyPlan: WeeklyMealPlan?
	@Published var shoppingList: ShoppingList?

	func generate(preference: DietaryPreference) {
		let plan = mealPlanManager.generateWeeklyPlan(preference: preference)
		self.weeklyPlan = plan
		self.shoppingList = mealPlanManager.buildShoppingList(for: plan)
	}
}

