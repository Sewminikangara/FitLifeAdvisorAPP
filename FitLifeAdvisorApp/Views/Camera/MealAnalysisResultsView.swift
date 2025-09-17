//
//  MealAnalysisResultsView.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.
//

import SwiftUI
import Charts

struct MealAnalysisResultsView: View {
    let capturedImage: UIImage
    @ObservedObject var aiService: AIFoodRecognitionService
    @State private var selectedFood: RecognizedFood?
    @State private var showingSaveConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with captured image
                    headerSection
                    
                    // Overall Summary Card
                    summaryCard
                    
                    // Confidence and Health Score
                    scoresSection
                    
                    // Detected Foods List
                    detectedFoodsSection
                    
                    // Nutritional Breakdown Chart
                    nutritionalChart
                    
                    // AI Recommendations
                    recommendationsSection
                    
                    // Action Buttons
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Meal Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMealAnalysis()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .alert("Meal Saved!", isPresented: $showingSaveConfirmation) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your meal analysis has been saved to your nutrition history.")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Captured Image
            Image(uiImage: capturedImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 3)
                )
            
            // Analysis Status
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("Analysis Complete")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(aiService.recognizedFoods.count) foods detected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: 16) {
            if let summary = aiService.nutritionalSummary {
                // Total Calories
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Calories")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(summary.totalCalories))")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Health Score
                    VStack(alignment: .trailing) {
                        Text("Health Score")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("\(String(format: "%.1f", summary.healthScore))/10")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            healthScoreIcon(summary.healthScore)
                        }
                    }
                }
                
                Divider()
                
                // Macronutrients
                HStack(spacing: 24) {
                    macroColumn(
                        title: "Protein",
                        value: summary.totalProtein,
                        unit: "g",
                        color: .red
                    )
                    
                    macroColumn(
                        title: "Carbs",
                        value: summary.totalCarbs,
                        unit: "g",
                        color: .blue
                    )
                    
                    macroColumn(
                        title: "Fat",
                        value: summary.totalFat,
                        unit: "g",
                        color: .orange
                    )
                    
                    macroColumn(
                        title: "Fiber",
                        value: summary.totalFiber,
                        unit: "g",
                        color: .green
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
        )
    }
    
    private func macroColumn(title: String, value: Double, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(String(format: "%.1f", value))")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Scores Section
    private var scoresSection: some View {
        HStack(spacing: 16) {
            // Confidence Score
            confidenceCard
            
            // Health Score Details
            healthScoreCard
        }
    }
    
    private var confidenceCard: some View {
        VStack(spacing: 8) {
            Text("AI Confidence")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: aiService.confidence)
                    .stroke(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(aiService.confidence * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
        .frame(maxWidth: .infinity)
    }
    
    private var healthScoreCard: some View {
        VStack(spacing: 8) {
            Text("Health Score")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let summary = aiService.nutritionalSummary {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(healthScoreColor(summary.healthScore))
                            .frame(width: CGFloat(summary.healthScore / 10.0) * 120, height: 20)
                        
                        Spacer()
                    }
                    .frame(width: 120)
                }
                
                HStack {
                    Text("\(String(format: "%.1f", summary.healthScore))/10")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    healthScoreIcon(summary.healthScore)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Detected Foods Section
    private var detectedFoodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detected Foods")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVStack(spacing: 12) {
                ForEach(aiService.recognizedFoods, id: \.id) { food in
                    foodCard(food)
                        .onTapGesture {
                            selectedFood = food
                        }
                }
            }
        }
    }
    
    private func foodCard(_ food: RecognizedFood) -> some View {
        HStack(spacing: 16) {
            // Food Category Icon
            Circle()
                .fill(food.category.color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(food.category.emoji)
                        .font(.title2)
                )
            
            // Food Details
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(food.servingSize)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("\(Int(food.nutrition.calories)) cal")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                    
                    Text("\(Int(food.confidence * 100))% confident")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Nutrition Summary
            VStack(alignment: .trailing, spacing: 2) {
                if let protein = food.nutrition.protein {
                    Text("P: \(String(format: "%.1f", protein))g")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                if let carbs = food.nutrition.carbs {
                    Text("C: \(String(format: "%.1f", carbs))g")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                if let fat = food.nutrition.fat {
                    Text("F: \(String(format: "%.1f", fat))g")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(selectedFood?.id == food.id ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
    
    // MARK: - Nutritional Chart
    private var nutritionalChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Macro Distribution")
                .font(.title2)
                .fontWeight(.bold)
            
            if let summary = aiService.nutritionalSummary {
                let macros = summary.macroDistribution
                
                Chart {
                    SectorMark(
                        angle: .value("Protein", macros.protein),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(.red)
                    .opacity(0.8)
                    
                    SectorMark(
                        angle: .value("Carbs", macros.carbs),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(.blue)
                    .opacity(0.8)
                    
                    SectorMark(
                        angle: .value("Fat", macros.fat),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(.orange)
                    .opacity(0.8)
                }
                .frame(height: 200)
                .chartLegend(position: .bottom)
                
                // Legend
                HStack(spacing: 20) {
                    legendItem(color: .red, label: "Protein", percentage: macros.protein)
                    legendItem(color: .blue, label: "Carbs", percentage: macros.carbs)
                    legendItem(color: .orange, label: "Fat", percentage: macros.fat)
                }
                .padding(.top)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
        )
    }
    
    private func legendItem(color: Color, label: String, percentage: Double) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("\(Int(percentage))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Recommendations Section
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Recommendations")
                .font(.title2)
                .fontWeight(.bold)
            
            if let summary = aiService.nutritionalSummary {
                LazyVStack(spacing: 12) {
                    ForEach(summary.recommendations, id: \.self) { recommendation in
                        recommendationCard(recommendation)
                    }
                }
            }
        }
    }
    
    private func recommendationCard(_ recommendation: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.title3)
            
            Text(recommendation)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Save to Meal History
            Button(action: saveMealAnalysis) {
                HStack {
                    Image(systemName: "bookmark.fill")
                    Text("Save to Meal History")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Share Results
            Button(action: shareResults) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Analysis")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.top)
    }
    
    // MARK: - Helper Functions
    private func healthScoreIcon(_ score: Double) -> some View {
        let icon = score >= 8 ? "face.smiling" : score >= 6 ? "face.dashed" : "face.dashed.fill"
        let color: Color = score >= 8 ? .green : score >= 6 ? .orange : .red
        
        return Image(systemName: icon)
            .foregroundColor(color)
            .font(.title3)
    }
    
    private func healthScoreColor(_ score: Double) -> Color {
        if score >= 8 { return .green }
        if score >= 6 { return .orange }
        return .red
    }
    
    private func saveMealAnalysis() {
        // Save meal analysis to Core Data or local storage
        // This would integrate with your meal tracking system
        showingSaveConfirmation = true
    }
    
    private func shareResults() {
        // Implement sharing functionality
        print("📤 Sharing meal analysis results")
    }
}

#Preview {
    MealAnalysisResultsView(
        capturedImage: UIImage(systemName: "photo") ?? UIImage(),
        aiService: AIFoodRecognitionService()
    )
}
