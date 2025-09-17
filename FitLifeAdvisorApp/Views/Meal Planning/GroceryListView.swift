//
//  GroceryListView.swift
//  FitLifeAdvisorApp
//
//  Advanced grocery list management with smart organization
//

import SwiftUI

struct GroceryListView: View {
    @StateObject private var mealPlanManager = MealPlanManager.shared
    let groceryList: GroceryList
    
    @State private var searchText = ""
    @State private var selectedCategory: IngredientCategory?
    @State private var showingCompletedItems = true
    @State private var animateItems = false
    @State private var showingCostBreakdown = false
    @State private var showingShoppingTips = false
    
    @Environment(\.dismiss) private var dismiss
    
    private var filteredItems: [GroceryItem] {
        var items = searchText.isEmpty ? groceryList.items : groceryList.items.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
        
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        if !showingCompletedItems {
            items = items.filter { !$0.isCheckedOff }
        }
        
        return items.sorted { item1, item2 in
            if item1.isCheckedOff != item2.isCheckedOff {
                return !item1.isCheckedOff && item2.isCheckedOff
            }
            return item1.priority.rawValue < item2.priority.rawValue
        }
    }
    
    private var categories: [IngredientCategory] {
        Array(Set(groceryList.items.map { $0.category })).sorted { $0.rawValue < $1.rawValue }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                
                searchAndFilterSection
                
                if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    groceryItemsList
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "F8F9FF"), Color(hex: "E8EFFF")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Shopping List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingCostBreakdown = true
                        }) {
                            Label("Cost Breakdown", systemImage: "chart.pie")
                        }
                        
                        Button(action: {
                            showingShoppingTips = true
                        }) {
                            Label("Shopping Tips", systemImage: "lightbulb")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            mealPlanManager.clearCompletedGroceryItems()
                        }) {
                            Label("Clear Completed", systemImage: "trash")
                        }
                        .disabled(groceryList.checkedOffCount == 0)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6)) {
                    animateItems = true
                }
            }
            .sheet(isPresented: $showingCostBreakdown) {
                CostBreakdownView(groceryList: groceryList)
            }
            .sheet(isPresented: $showingShoppingTips) {
                ShoppingTipsView()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            // Progress Overview
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Shopping Progress")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "2C3E50"))
                        
                        Text("\(groceryList.checkedOffCount) of \(groceryList.items.count) items")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(String(format: "%.0f", groceryList.completionPercentage))%")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "4ECDC4"))
                        
                        Text("Complete")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress Bar
                ProgressView(value: groceryList.completionPercentage / 100.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "4ECDC4")))
                    .scaleEffect(y: 2.0)
                    .animation(.easeInOut(duration: 0.5), value: groceryList.completionPercentage)
            }
            
            // Cost Summary
            HStack(spacing: 20) {
                CostSummaryCard(
                    title: "Total Cost",
                    amount: groceryList.totalEstimatedCost,
                    color: Color(hex: "4A90E2")
                )
                
                CostSummaryCard(
                    title: "Remaining",
                    amount: groceryList.items.filter { !$0.isCheckedOff }.reduce(0) { $0 + $1.estimatedCost },
                    color: Color(hex: "FF6B6B")
                )
                
                CostSummaryCard(
                    title: "Categories",
                    amount: Double(categories.count),
                    color: Color(hex: "4ECDC4"),
                    isCount: true
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .scaleEffect(animateItems ? 1.0 : 0.95)
        .opacity(animateItems ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6), value: animateItems)
    }
    
    // MARK: - Search and Filter Section
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 15) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search items...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "E2E8F0"), lineWidth: 1)
                    )
            )
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryFilterChip(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        count: groceryList.items.count
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedCategory = nil
                        }
                    }
                    
                    ForEach(categories, id: \.self) { category in
                        CategoryFilterChip(
                            title: category.rawValue,
                            emoji: category.emoji,
                            isSelected: selectedCategory == category,
                            count: groceryList.items.filter { $0.category == category }.count
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Filter Options
            HStack {
                Toggle("Show Completed", isOn: $showingCompletedItems)
                    .font(.system(size: 14, weight: .medium))
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "4A90E2")))
                
                Spacer()
                
                Text("\(filteredItems.count) items")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
    
    // MARK: - Grocery Items List
    
    private var groceryItemsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if selectedCategory == nil {
                    // Group by category
                    ForEach(categories, id: \.self) { category in
                        let categoryItems = filteredItems.filter { $0.category == category }
                        
                        if !categoryItems.isEmpty {
                            CategorySection(
                                category: category,
                                items: categoryItems,
                                onItemToggle: { item in
                                    toggleItemCompletion(item)
                                }
                            )
                        }
                    }
                } else {
                    // Show filtered items
                    CategorySection(
                        category: selectedCategory!,
                        items: filteredItems,
                        onItemToggle: { item in
                            toggleItemCompletion(item)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .animation(.easeInOut(duration: 0.3), value: filteredItems.count)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Items Found")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "2C3E50"))
                
                Text("Try adjusting your search or filters")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Functions
    
    private func toggleItemCompletion(_ item: GroceryItem) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            mealPlanManager.updateGroceryItem(item, isChecked: !item.isCheckedOff)
        }
    }
}

// MARK: - Supporting Views

struct CostSummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    var isCount: Bool = false
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            if isCount {
                Text("\(Int(amount))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
            } else {
                Text("LKR \(String(format: "%.0f", amount))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct CategoryFilterChip: View {
    let title: String
    var emoji: String = ""
    let isSelected: Bool
    let count: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: 14))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                
                Text("(\(count))")
                    .font(.system(size: 12))
                    .opacity(0.7)
            }
            .foregroundColor(isSelected ? .white : Color(hex: "4A90E2"))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected
                        ? LinearGradient(colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")], startPoint: .leading, endPoint: .trailing)
                        : Color(hex: "4A90E2").opacity(0.1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
}

struct CategorySection: View {
    let category: IngredientCategory
    let items: [GroceryItem]
    let onItemToggle: (GroceryItem) -> Void
    
    @State private var isExpanded = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Header
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    HStack(spacing: 10) {
                        Text(category.emoji)
                            .font(.system(size: 20))
                        
                        Text(category.rawValue)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "2C3E50"))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Text("\(items.count) items")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Items List
            if isExpanded {
                VStack(spacing: 1) {
                    ForEach(items, id: \.id) { item in
                        GroceryItemRow(item: item) {
                            onItemToggle(item)
                        }
                    }
                }
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                ))
            }
        }
        .padding(.vertical, 8)
    }
}

struct GroceryItemRow: View {
    let item: GroceryItem
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 15) {
                // Checkbox
                Image(systemName: item.isCheckedOff ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(item.isCheckedOff ? Color(hex: "4ECDC4") : .secondary)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: item.isCheckedOff)
                
                // Item Details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(item.isCheckedOff ? .secondary : Color(hex: "2C3E50"))
                            .strikethrough(item.isCheckedOff)
                        
                        Spacer()
                        
                        // Priority Badge
                        if item.priority != .optional {
                            Text(item.priority.rawValue)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(item.priority.color)
                                )
                        }
                    }
                    
                    HStack {
                        Text(item.displayAmount)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(item.isCheckedOff ? .secondary : Color(hex: "4A90E2"))
                        
                        Spacer()
                        
                        Text("LKR \(String(format: "%.0f", item.estimatedCost))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(item.isCheckedOff ? .secondary : Color(hex: "FF6B6B"))
                    }
                    
                    if let notes = item.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .opacity(item.isCheckedOff ? 0.6 : 1.0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        item.isCheckedOff ? Color(hex: "4ECDC4").opacity(0.3) : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(item.isCheckedOff ? 0.98 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: item.isCheckedOff)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Cost Breakdown View

struct CostBreakdownView: View {
    let groceryList: GroceryList
    @Environment(\.dismiss) private var dismiss
    
    private var categoryBreakdown: [(category: IngredientCategory, cost: Double, percentage: Double)] {
        let categoryTotals = Dictionary(grouping: groceryList.items, by: { $0.category })
            .mapValues { items in
                items.reduce(0) { $0 + $1.estimatedCost }
            }
        
        return categoryTotals.map { (category, cost) in
            let percentage = (cost / groceryList.totalEstimatedCost) * 100
            return (category, cost, percentage)
        }.sorted { $0.cost > $1.cost }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Total Cost Header
                    VStack(spacing: 10) {
                        Text("Total Estimated Cost")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("LKR \(String(format: "%.0f", groceryList.totalEstimatedCost))")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: "4A90E2"))
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    )
                    
                    // Category Breakdown
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Cost by Category")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "2C3E50"))
                        
                        ForEach(categoryBreakdown, id: \.category) { item in
                            CategoryCostRow(
                                category: item.category,
                                cost: item.cost,
                                percentage: item.percentage
                            )
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "F8F9FF"), Color(hex: "E8EFFF")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Cost Breakdown")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CategoryCostRow: View {
    let category: IngredientCategory
    let cost: Double
    let percentage: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 10) {
                    Text(category.emoji)
                        .font(.system(size: 18))
                    
                    Text(category.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "2C3E50"))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("LKR \(String(format: "%.0f", cost))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "4A90E2"))
                    
                    Text("\(String(format: "%.1f", percentage))%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            ProgressView(value: percentage / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "4A90E2")))
                .scaleEffect(y: 1.5)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Shopping Tips View

struct ShoppingTipsView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let tips = [
        ShoppingTip(icon: "cart", title: "Shop by Category", description: "Follow the store layout and shop category by category to save time."),
        ShoppingTip(icon: "clock", title: "Best Shopping Times", description: "Shop early morning or late evening to avoid crowds and get freshest items."),
        ShoppingTip(icon: "leaf", title: "Fresh Produce First", description: "Select fresh produce carefully - look for vibrant colors and firm textures."),
        ShoppingTip(icon: "dollarsign.circle", title: "Check Unit Prices", description: "Compare unit prices, not package prices, to get the best value."),
        ShoppingTip(icon: "checkmark.seal", title: "Bring Your List", description: "Stick to your list to avoid impulse purchases and stay within budget."),
        ShoppingTip(icon: "thermometer", title: "Frozen Last", description: "Pick up frozen and refrigerated items last to maintain freshness.")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "FFD93D"))
                        
                        Text("Smart Shopping Tips")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "2C3E50"))
                        
                        Text("Make your grocery shopping more efficient")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    
                    // Tips List
                    ForEach(tips, id: \.title) { tip in
                        ShoppingTipCard(tip: tip)
                    }
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "F8F9FF"), Color(hex: "E8EFFF")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Shopping Tips")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ShoppingTip {
    let icon: String
    let title: String
    let description: String
}

struct ShoppingTipCard: View {
    let tip: ShoppingTip
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: tip.icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "4A90E2"))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(tip.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "2C3E50"))
                
                Text(tip.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Preview

#Preview {
    let sampleGroceryList = GroceryList(
        mealPlanId: UUID(),
        items: [
            GroceryItem(name: "Chicken Breast", category: .protein, totalAmount: 500, unit: "g", estimatedCost: 800, priority: .essential, isCheckedOff: false, stores: ["Keells"], notes: nil),
            GroceryItem(name: "Broccoli", category: .vegetables, totalAmount: 300, unit: "g", estimatedCost: 150, priority: .important, isCheckedOff: true, stores: ["Keells"], notes: nil),
            GroceryItem(name: "Brown Rice", category: .grains, totalAmount: 1, unit: "kg", estimatedCost: 250, priority: .essential, isCheckedOff: false, stores: ["Keells"], notes: nil)
        ],
        totalEstimatedCost: 1200,
        createdAt: Date()
    )
    
    GroceryListView(groceryList: sampleGroceryList)
}
