//
//  MealPlanGenerationView.swift
//  FitLifeAdvisorApp
//
//  Advanced meal plan configuration interface
//

import SwiftUI

struct MealPlanGenerationView: View {
    @Binding var selectedGoal: NutritionGoal
    @Binding var selectedDifficulty: MealPlan.DifficultyLevel
    @Binding var planDuration: Int
    @Binding var targetCalories: String
    @Binding var dietaryRestrictions: [String]
    @Binding var dislikedIngredients: [String]
    
    let onGenerate: () -> Void
    
    @State private var showingAdvancedOptions = false
    @State private var animateCards = false
    @State private var newRestriction = ""
    @State private var showingRestrictionInput = false
    @State private var newDislikedIngredient = ""
    @State private var showingIngredientInput = false
    
    // Predefined options
    private let commonRestrictions = [
        "Gluten-Free", "Dairy-Free", "Nut-Free", "Shellfish-Free",
        "Vegetarian", "Vegan", "Halal", "Kosher", "Low Sodium"
    ]
    
    private let commonDislikes = [
        "Mushrooms", "Onions", "Garlic", "Cilantro", "Spicy Food",
        "Fish", "Eggs", "Cheese", "Tomatoes", "Beans"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                headerSection
                
                goalSelectionSection
                
                basicOptionsSection
                
                advancedOptionsToggle
                
                if showingAdvancedOptions {
                    advancedOptionsSection
                }
                
                generateButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "F8F9FF"), Color(hex: "E8EFFF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateCards = true
            }
        }
        .sheet(isPresented: $showingRestrictionInput) {
            restrictionInputSheet
        }
        .sheet(isPresented: $showingIngredientInput) {
            ingredientInputSheet
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("AI Meal Plan Generator")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "2C3E50"))
                
                Text("Tell us about your goals and preferences, and we'll create the perfect meal plan for you.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
        }
        .scaleEffect(animateCards ? 1.0 : 0.9)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6), value: animateCards)
    }
    
    // MARK: - Goal Selection Section
    
    private var goalSelectionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "What's Your Goal?", subtitle: "Choose your primary nutrition objective")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                ForEach(NutritionGoal.allCases, id: \.self) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: selectedGoal == goal
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedGoal = goal
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(animateCards ? 1.0 : 0.95)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: animateCards)
    }
    
    // MARK: - Basic Options Section
    
    private var basicOptionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Plan Details", subtitle: "Customize your meal plan duration and difficulty")
            
            VStack(spacing: 20) {
                // Duration Selection
                VStack(alignment: .leading, spacing: 12) {
                    Label("Plan Duration", systemImage: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "2C3E50"))
                    
                    HStack(spacing: 12) {
                        ForEach([3, 7, 14, 21], id: \.self) { days in
                            DurationCard(
                                days: days,
                                isSelected: planDuration == days
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    planDuration = days
                                }
                            }
                        }
                    }
                }
                
                // Difficulty Selection
                VStack(alignment: .leading, spacing: 12) {
                    Label("Cooking Difficulty", systemImage: "chef.hat")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "2C3E50"))
                    
                    HStack(spacing: 12) {
                        ForEach(MealPlan.DifficultyLevel.allCases, id: \.self) { difficulty in
                            DifficultyCard(
                                difficulty: difficulty,
                                isSelected: selectedDifficulty == difficulty
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selectedDifficulty = difficulty
                                }
                            }
                        }
                    }
                }
                
                // Calorie Target (Optional)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("Daily Calorie Target", systemImage: "flame")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "2C3E50"))
                        
                        Spacer()
                        
                        Text("Optional")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                    
                    TextField("Auto-calculate based on goals", text: $targetCalories)
                        .keyboardType(.numberPad)
                        .textFieldStyle(CustomTextFieldStyle())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(animateCards ? 1.0 : 0.95)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateCards)
    }
    
    // MARK: - Advanced Options Toggle
    
    private var advancedOptionsToggle: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showingAdvancedOptions.toggle()
            }
        }) {
            HStack {
                Image(systemName: "gearshape.2")
                    .font(.system(size: 18))
                
                Text("Advanced Options")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Image(systemName: showingAdvancedOptions ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(Color(hex: "4A90E2"))
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(hex: "4A90E2"), lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: "4A90E2").opacity(0.05))
                    )
            )
        }
    }
    
    // MARK: - Advanced Options Section
    
    private var advancedOptionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Dietary Preferences", subtitle: "Customize based on restrictions and dislikes")
            
            VStack(spacing: 25) {
                // Dietary Restrictions
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Label("Dietary Restrictions", systemImage: "exclamationmark.shield")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "2C3E50"))
                        
                        Spacer()
                        
                        Button(action: {
                            showingRestrictionInput = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "4A90E2"))
                        }
                    }
                    
                    // Selected restrictions
                    if !dietaryRestrictions.isEmpty {
                        WrappedHStack(items: dietaryRestrictions) { restriction in
                            TagView(text: restriction, isSelected: true) {
                                dietaryRestrictions.removeAll { $0 == restriction }
                            }
                        }
                    }
                    
                    // Common restrictions
                    WrappedHStack(items: commonRestrictions.filter { !dietaryRestrictions.contains($0) }) { restriction in
                        TagView(text: restriction, isSelected: false) {
                            dietaryRestrictions.append(restriction)
                        }
                    }
                }
                
                Divider()
                
                // Disliked Ingredients
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Label("Ingredients to Avoid", systemImage: "hand.raised")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "2C3E50"))
                        
                        Spacer()
                        
                        Button(action: {
                            showingIngredientInput = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "4A90E2"))
                        }
                    }
                    
                    // Selected dislikes
                    if !dislikedIngredients.isEmpty {
                        WrappedHStack(items: dislikedIngredients) { ingredient in
                            TagView(text: ingredient, isSelected: true, color: Color(hex: "FF6B6B")) {
                                dislikedIngredients.removeAll { $0 == ingredient }
                            }
                        }
                    }
                    
                    // Common dislikes
                    WrappedHStack(items: commonDislikes.filter { !dislikedIngredients.contains($0) }) { ingredient in
                        TagView(text: ingredient, isSelected: false, color: Color(hex: "FF6B6B")) {
                            dislikedIngredients.append(ingredient)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
    }
    
    // MARK: - Generate Button
    
    private var generateButton: some View {
        Button(action: onGenerate) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                
                Text("Generate My Meal Plan")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color(hex: "4A90E2").opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(animateCards ? 1.0 : 0.9)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateCards)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Input Sheets
    
    private var restrictionInputSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter dietary restriction", text: $newRestriction)
                    .textFieldStyle(CustomTextFieldStyle())
                
                Button("Add Restriction") {
                    if !newRestriction.isEmpty && !dietaryRestrictions.contains(newRestriction) {
                        dietaryRestrictions.append(newRestriction)
                        newRestriction = ""
                        showingRestrictionInput = false
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(newRestriction.isEmpty)
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Add Restriction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingRestrictionInput = false
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
    
    private var ingredientInputSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter ingredient to avoid", text: $newDislikedIngredient)
                    .textFieldStyle(CustomTextFieldStyle())
                
                Button("Add Ingredient") {
                    if !newDislikedIngredient.isEmpty && !dislikedIngredients.contains(newDislikedIngredient) {
                        dislikedIngredients.append(newDislikedIngredient)
                        newDislikedIngredient = ""
                        showingIngredientInput = false
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(newDislikedIngredient.isEmpty)
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingIngredientInput = false
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "2C3E50"))
            
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
}

struct GoalCard: View {
    let goal: NutritionGoal
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(goal.emoji)
                    .font(.system(size: 32))
                
                VStack(spacing: 4) {
                    Text(goal.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? .white : Color(hex: "2C3E50"))
                        .multilineTextAlignment(.center)
                    
                    Text(goal.description)
                        .font(.system(size: 11))
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        isSelected
                        ? LinearGradient(colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color(hex: "F8F9FF")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                isSelected ? Color.clear : Color(hex: "E2E8F0"),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: isSelected ? Color(hex: "4A90E2").opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
}

struct DurationCard: View {
    let days: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text("\(days)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isSelected ? .white : Color(hex: "4A90E2"))
                
                Text(days == 1 ? "Day" : "Days")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected
                        ? LinearGradient(colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : Color(hex: "F8F9FF")
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.clear : Color(hex: "E2E8F0"),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
}

struct DifficultyCard: View {
    let difficulty: MealPlan.DifficultyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(difficulty.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : Color(hex: "4A90E2"))
                
                Text(difficulty.description)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected
                        ? LinearGradient(colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : Color(hex: "F8F9FF")
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.clear : Color(hex: "E2E8F0"),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
}

struct TagView: View {
    let text: String
    let isSelected: Bool
    var color: Color = Color(hex: "4A90E2")
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(text)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : color)
                
                if isSelected {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected
                        ? color
                        : color.opacity(0.1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color.clear : color.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WrappedHStack<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 8) {
            HStack {
                ForEach(items, id: \.self) { item in
                    content(item)
                }
                Spacer()
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "F8F9FF"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "E2E8F0"), lineWidth: 1)
                    )
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        MealPlanGenerationView(
            selectedGoal: .constant(.balanced),
            selectedDifficulty: .constant(.intermediate),
            planDuration: .constant(7),
            targetCalories: .constant(""),
            dietaryRestrictions: .constant(["Vegetarian"]),
            dislikedIngredients: .constant(["Mushrooms"])
        ) {
            print("Generate meal plan")
        }
        .navigationTitle("Create Meal Plan")
        .navigationBarTitleDisplayMode(.large)
    }
}
