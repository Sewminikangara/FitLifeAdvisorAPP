//
//  FoodProductResultView.swift
//  FitLifeAdvisorApp
//
//  Display scanned food product results with nutrition information
//

import SwiftUI

struct FoodProductResultView: View {
    let product: FoodProduct
    let onAddToLog: (FoodProduct) -> Void
    let onDismiss: () -> Void
    
    @State private var servingQuantity: Double = 1.0
    
    var adjustedNutrition: NutritionInfo {
        let multiplier = servingQuantity
        return NutritionInfo(
            calories: product.nutrition.calories * multiplier,
            protein: product.nutrition.protein * multiplier,
            carbs: product.nutrition.carbs * multiplier,
            fat: product.nutrition.fat * multiplier,
            fiber: product.nutrition.fiber * multiplier,
            sugar: product.nutrition.sugar * multiplier,
            sodium: product.nutrition.sodium * multiplier,
            cholesterol: product.nutrition.cholesterol * multiplier
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.large) {
                    // Product Header
                    VStack(spacing: Constants.Spacing.medium) {
                        // Category Icon
                        ZStack {
                            Circle()
                                .fill(product.category.color.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Text(product.category.emoji)
                                .font(.system(size: 40))
                        }
                        
                        VStack(spacing: Constants.Spacing.small) {
                            Text(product.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Constants.Colors.textDark)
                                .multilineTextAlignment(.center)
                            
                            Text(product.brand)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textLight)
                            
                            if let barcode = product.barcode {
                                Text("Barcode: \(barcode)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Constants.Colors.textLight)
                                    .padding(.horizontal, Constants.Spacing.medium)
                                    .padding(.vertical, Constants.Spacing.small)
                                    .background(Constants.Colors.backgroundGray)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, Constants.Spacing.large)
                    
                    // Serving Size Adjuster
                    VStack(spacing: Constants.Spacing.medium) {
                        Text("Serving Size")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Constants.Colors.textDark)
                        
                        VStack(spacing: Constants.Spacing.small) {
                            Text(product.servingSize)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Constants.Colors.textLight)
                            
                            HStack(spacing: Constants.Spacing.medium) {
                                Button(action: {
                                    if servingQuantity > 0.5 {
                                        servingQuantity -= 0.5
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Constants.Colors.primaryBlue)
                                }
                                
                                Text("\(servingQuantity, specifier: "%.1f")")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Constants.Colors.textDark)
                                    .frame(minWidth: 60)
                                
                                Button(action: {
                                    if servingQuantity < 10 {
                                        servingQuantity += 0.5
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Constants.Colors.primaryBlue)
                                }
                            }
                        }
                        .padding(.horizontal, Constants.Spacing.large)
                        .padding(.vertical, Constants.Spacing.medium)
                        .background(.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, Constants.Spacing.large)
                    
                    // Nutrition Information
                    NutritionInfoCard(nutrition: adjustedNutrition)
                        .padding(.horizontal, Constants.Spacing.large)
                    
                    // Macro Breakdown
                    MacroBreakdownView(nutrition: adjustedNutrition)
                        .padding(.horizontal, Constants.Spacing.large)
                    
                    Spacer(minLength: 100) // Space for bottom button
                }
            }
            .navigationTitle("Food Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
            }
            .overlay(
                // Add to Log Button
                VStack {
                    Spacer()
                    
                    Button(action: {
                        var adjustedProduct = product
                        adjustedProduct.nutrition = adjustedNutrition
                        onAddToLog(adjustedProduct)
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Add to Meal Log")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Constants.Spacing.medium)
                        .background(Constants.Colors.successGreen)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, Constants.Spacing.large)
                    .padding(.bottom, Constants.Spacing.large)
                    .background(.white.opacity(0.95))
                }
            )
        }
    }
}

// MARK: - Nutrition Info Card
struct NutritionInfoCard: View {
    let nutrition: NutritionInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Nutrition Facts")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Constants.Colors.textDark)
            
            VStack(spacing: Constants.Spacing.small) {
                NutritionRow(
                    label: "Calories",
                    value: "\(Int(nutrition.calories))",
                    unit: "kcal",
                    isHighlighted: true
                )
                
                Divider()
                
                NutritionRow(
                    label: "Protein",
                    value: String(format: "%.1f", nutrition.protein),
                    unit: "g"
                )
                
                NutritionRow(
                    label: "Carbohydrates",
                    value: String(format: "%.1f", nutrition.carbs),
                    unit: "g"
                )
                
                NutritionRow(
                    label: "Total Fat",
                    value: String(format: "%.1f", nutrition.fat),
                    unit: "g"
                )
                
                NutritionRow(
                    label: "Dietary Fiber",
                    value: String(format: "%.1f", nutrition.fiber),
                    unit: "g"
                )
                
                NutritionRow(
                    label: "Sugars",
                    value: String(format: "%.1f", nutrition.sugar),
                    unit: "g"
                )
                
                NutritionRow(
                    label: "Sodium",
                    value: String(format: "%.1f", nutrition.sodium),
                    unit: "mg"
                )
            }
        }
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Nutrition Row
struct NutritionRow: View {
    let label: String
    let value: String
    let unit: String
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: isHighlighted ? 16 : 14, weight: isHighlighted ? .semibold : .medium))
                .foregroundColor(Constants.Colors.textDark)
            
            Spacer()
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: isHighlighted ? 16 : 14, weight: .bold))
                    .foregroundColor(isHighlighted ? Constants.Colors.primaryBlue : Constants.Colors.textDark)
                
                Text(unit)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
        }
        .padding(.vertical, Constants.Spacing.small / 2)
    }
}

// MARK: - Macro Breakdown View
struct MacroBreakdownView: View {
    let nutrition: NutritionInfo
    
    var macroPercentages: (protein: Double, carbs: Double, fat: Double) {
        let protein = nutrition.protein
        let carbs = nutrition.carbs
        let fat = nutrition.fat
        
        let proteinCals = protein * 4
        let carbsCals = carbs * 4
        let fatCals = fat * 9
        let totalCals = proteinCals + carbsCals + fatCals
        
        guard totalCals > 0 else { return (0, 0, 0) }
        
        return (
            protein: proteinCals / totalCals,
            carbs: carbsCals / totalCals,
            fat: fatCals / totalCals
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Macro Breakdown")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Constants.Colors.textDark)
            
            let percentages = macroPercentages
            
            // Macro Bar
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Constants.Colors.primaryBlue)
                    .frame(height: 8)
                    .frame(width: CGFloat(percentages.protein) * 300)
                
                Rectangle()
                    .fill(Constants.Colors.successGreen)
                    .frame(height: 8)
                    .frame(width: CGFloat(percentages.carbs) * 300)
                
                Rectangle()
                    .fill(Constants.Colors.warningOrange)
                    .frame(height: 8)
                    .frame(width: CGFloat(percentages.fat) * 300)
            }
            .cornerRadius(4)
            
            // Legend
            VStack(spacing: Constants.Spacing.small) {
                MacroLegendRow(
                    color: Constants.Colors.primaryBlue,
                    label: "Protein",
                    percentage: percentages.protein,
                    grams: nutrition.protein
                )
                
                MacroLegendRow(
                    color: Constants.Colors.successGreen,
                    label: "Carbs",
                    percentage: percentages.carbs,
                    grams: nutrition.carbs
                )
                
                MacroLegendRow(
                    color: Constants.Colors.warningOrange,
                    label: "Fat",
                    percentage: percentages.fat,
                    grams: nutrition.fat
                )
            }
        }
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Macro Legend Row
struct MacroLegendRow: View {
    let color: Color
    let label: String
    let percentage: Double
    let grams: Double
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.textDark)
            
            Spacer()
            
            HStack(spacing: Constants.Spacing.small) {
                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                
                Text("(\(String(format: "%.1f", grams))g)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
        }
    }
}

#Preview {
    FoodProductResultView(
        product: FoodProduct(
            id: "123",
            name: "Greek Yogurt",
            brand: "Healthy Choice",
            barcode: "123456789012",
            nutrition: NutritionInfo(
                calories: 130,
                protein: 15.0,
                carbs: 6.0,
                fat: 5.0,
                fiber: 0.0,
                sugar: 6.0,
                sodium: 65.0,
                cholesterol: 20.0
            ),
            servingSize: "1 container (170g)",
            category: FoodCategory.dairy
        ),
        onAddToLog: { _ in },
        onDismiss: { }
    )
}
