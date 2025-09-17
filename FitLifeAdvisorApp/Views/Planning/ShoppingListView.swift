//
//  ShoppingListView.swift
//  FitLifeAdvisorApp
//
//  Simple shopping list UI.
//

import SwiftUI

struct ShoppingListView: View {
	let list: ShoppingList

	var body: some View {
		List {
			ForEach(list.items) { item in
				HStack {
					Text(item.name)
					Spacer()
					Text("\(format(item.totalQuantity)) \(item.unit)")
						.foregroundColor(.secondary)
				}
				.accessibilityElement(children: .combine)
				.accessibilityLabel("\(item.name), \(format(item.totalQuantity)) \(item.unit)")
			}
		}
		.navigationTitle("Shopping List")
	}

	private func format(_ value: Double) -> String {
		if value.rounded() == value { return String(Int(value)) }
		return String(format: "%.2f", value)
	}
}

#Preview {
	let items = [
		ShoppingItem(name: "Banana", unit: "pc", totalQuantity: 7),
		ShoppingItem(name: "Greek Yogurt", unit: "cup", totalQuantity: 5.5)
	]
	return NavigationView { ShoppingListView(list: ShoppingList(items: items)) }
}

