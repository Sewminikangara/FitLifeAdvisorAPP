//
//  DietPlanningManager.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.
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

