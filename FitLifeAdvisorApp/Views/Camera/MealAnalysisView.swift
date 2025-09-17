//
//  MealAnalysisView.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.

import SwiftUI

struct MealAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var mealAnalysisManager = MealAnalysisManager.shared
    @StateObject private var mlKitManager = MLKitManager()
    @StateObject private var foodRecognitionService = FoodRecognitionService()
    @State private var capturedImage: UIImage?
    @State private var showingCamera = false
    @State private var analysisResult: MealAnalysisResult?
    @State private var selectedFoodItems: Set<UUID> = []
    @State private var showingSaveDialog = false
    @State private var mealName = ""
    @State private var selectedMealType: MealType = .breakfast
    @State private var isAnalyzing = false
    @State private var animateResults = false
    @State private var showingFoodScanner = false
    @State private var scannedFoodProduct: FoodProduct?
    @State private var showingFoodResult = false
    @State private var scanningMode: ScanMode = .meal
    
    enum ScanMode: String, CaseIterable {
        case meal = "Meal Analysis"
        case barcode = "Barcode Scan"
        case nutrition = "Nutrition Label"
    }
    
    // Add missing properties
    let image: UIImage?
    
    init(image: UIImage? = nil) {
        self.image = image
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Constants.Colors.backgroundGray,
                        Constants.Colors.backgroundGray.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if capturedImage == nil {
                    // Enhanced camera capture interface
                    enhancedCameraInterfaceView
                } else if isAnalyzing {
                    // Modern analysis loading view
                    modernAnalysisLoadingView
                } else if let result = analysisResult {
                    // Beautiful results view
                    modernAnalysisResultView(result: result)
                } else {
                    // Elegant error view
                    modernAnalysisErrorView
                }
            }
            .navigationTitle("Smart Meal Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Constants.Colors.textLight)
                },
                trailing: analysisResult != nil && !selectedFoodItems.isEmpty ? 
                    Button("Save") {
                        showingSaveDialog = true
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Constants.Colors.primaryBlue)
                    : nil
            )
        }
        .sheet(isPresented: $showingFoodScanner) {
            FoodScannerView()
        }
        .sheet(isPresented: $showingFoodResult) {
            if let product = scannedFoodProduct {
                FoodProductResultView(
                    product: product,
                    onAddToLog: { foodProduct in
                        // Add to meal log here
                        showingFoodResult = false
                        scannedFoodProduct = nil
                    },
                    onDismiss: {
                        showingFoodResult = false
                        scannedFoodProduct = nil
                    }
                )
            }
        }
        .sheet(isPresented: $showingCamera) {
            SmartCameraView(image: $capturedImage, isPresented: $showingCamera)
        }
        .sheet(isPresented: $showingSaveDialog) {
            modernSaveMealDialog
        }
        .onAppear {
            if capturedImage == nil {
                showingCamera = true
            } else if let image = capturedImage {
                Task {
                    await performEnhancedAnalysis(image: image)
                }
            }
        }
    }
    
    // MARK: - Enhanced Camera Interface with ML Kit Options
    private var enhancedCameraInterfaceView: some View {
        VStack(spacing: Constants.Spacing.extraLarge) {
            Spacer()
            
            // AI Brain Icon with animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Constants.Colors.primaryBlue.opacity(0.2),
                                Constants.Colors.primaryBlue.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(animateResults ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateResults)
                
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(Constants.Colors.primaryBlue)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Constants.Colors.successGreen)
                }
            }
            
            VStack(spacing: Constants.Spacing.medium) {
                Text("AI-Powered Food Analysis")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                    .multilineTextAlignment(.center)
                
                Text("Choose your scanning mode for the most accurate results")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Spacing.large)
            }
            
            // Scanning Mode Selector
            VStack(spacing: Constants.Spacing.medium) {
                Text("Select Scanning Mode")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Constants.Colors.textDark)
                
                VStack(spacing: Constants.Spacing.small) {
                    ForEach(ScanMode.allCases, id: \.self) { mode in
                        ScanModeButton(
                            mode: mode,
                            isSelected: scanningMode == mode,
                            onTap: { scanningMode = mode }
                        )
                    }
                }
            }
            
            VStack(spacing: Constants.Spacing.medium) {
                // Main scanning button
                Button(action: {
                    switch scanningMode {
                    case .meal:
                        showingCamera = true
                    case .barcode, .nutrition:
                        showingFoodScanner = true
                    }
                }) {
                    HStack(spacing: Constants.Spacing.medium) {
                        Image(systemName: scanningMode == .meal ? "camera.fill" : "barcode.viewfinder")
                            .font(.title2)
                        
                        Text(scanningMode == .meal ? "Capture Meal Photo" : "Start Scanning")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.Spacing.large)
                    .background(
                        LinearGradient(
                            colors: [Constants.Colors.primaryBlue, Constants.Colors.primaryBlue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Constants.Colors.primaryBlue.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(ModernButtonStyle())
                
                // Mode-specific features list
                scanModeFeatures
            }
            
            Spacer()
        }
        .padding(.horizontal, Constants.Spacing.large)
        .onAppear {
            withAnimation(.easeInOut(duration: 1).delay(0.5)) {
                animateResults = true
            }
        }
    }
    
    @ViewBuilder
    private var scanModeFeatures: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            switch scanningMode {
            case .meal:
                MealFeatureRow(icon: "eye.fill", text: "Visual meal recognition", color: .blue)
                MealFeatureRow(icon: "chart.bar.fill", text: "Portion size estimation", color: .green)
                MealFeatureRow(icon: "brain.head.profile", text: "Multiple ingredient detection", color: .purple)
                
            case .barcode:
                MealFeatureRow(icon: "barcode", text: "Instant product lookup", color: .blue)
                MealFeatureRow(icon: "info.circle.fill", text: "Accurate nutritional data", color: .green)
                MealFeatureRow(icon: "timer", text: "Lightning-fast scanning", color: .orange)
                
            case .nutrition:
                MealFeatureRow(icon: "text.viewfinder", text: "Nutrition label text recognition", color: .blue)
                MealFeatureRow(icon: "doc.text.magnifyingglass", text: "Extract key nutrition facts", color: .green)
                MealFeatureRow(icon: "checkmark.seal.fill", text: "Verify product information", color: .purple)
            }
        }
        .padding(.top, Constants.Spacing.medium)
    }
    
    
    // MARK: - Modern Analysis Loading View
    private var modernAnalysisLoadingView: some View {
        VStack(spacing: Constants.Spacing.extraLarge) {
            // Captured image with modern styling
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 280, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [Constants.Colors.primaryBlue.opacity(0.6), Constants.Colors.primaryBlue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: Constants.Colors.primaryBlue.opacity(0.3), radius: 20, x: 0, y: 10)
                    .scaleEffect(animateResults ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateResults)
            }
            
            // Modern AI analysis indicator
            VStack(spacing: Constants.Spacing.large) {
                // Animated AI brain
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Constants.Colors.successGreen.opacity(0.2), Constants.Colors.successGreen.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(animateResults ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateResults)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(Constants.Colors.successGreen)
                        .rotationEffect(.degrees(animateResults ? 360 : 0))
                        .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: animateResults)
                }
                
                VStack(spacing: Constants.Spacing.small) {
                    Text("AI is analyzing your meal...")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text("Identifying ingredients, calculating nutrition, and estimating portions")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Constants.Spacing.large)
                }
                
                // Modern progress indicators
                HStack(spacing: Constants.Spacing.medium) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Constants.Colors.primaryBlue)
                            .frame(width: 12, height: 12)
                            .scaleEffect(animateResults ? 1.2 : 0.8)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: animateResults
                            )
                    }
                }
                .padding(.top, Constants.Spacing.medium)
            }
        }
        .padding(Constants.Spacing.large)
        .onAppear {
            withAnimation {
                animateResults = true
            }
        }
    }
    
    private func analysisResultView(result: MealAnalysisResult) -> some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.large) {
                // Captured image
                imageSection(result: result)
                
                // Analysis confidence
                confidenceSection(result: result)
                
                // Detected food items
                foodItemsSection(result: result)
                
                // Nutrition summary
                nutritionSummarySection(result: result)
                
                // Macro breakdown chart
                macroBreakdownSection(result: result)
            }
            .padding(Constants.Spacing.large)
        }
    }
    
    private func imageSection(result: MealAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Your Meal")
                .font(Constants.Typography.headline)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.textDark)
            
            Image(uiImage: result.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 250)
                .cornerRadius(Constants.cornerRadius)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
    
    private func confidenceSection(result: MealAnalysisResult) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Analysis Confidence")
                    .font(Constants.Typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textDark)
                
                Text("\(Int(result.confidence * 100))% accurate")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Spacer()
            
            // Confidence indicator
            ZStack {
                Circle()
                    .stroke(Constants.Colors.primaryBlue.opacity(0.2), lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: CGFloat(result.confidence))
                    .stroke(Constants.Colors.primaryBlue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(result.confidence * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.primaryBlue)
            }
        }
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    private func foodItemsSection(result: MealAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Detected Food Items")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Text("Tap to select/deselect")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            VStack(spacing: Constants.Spacing.small) {
                ForEach(result.foodItems) { foodItem in
                    FoodItemRow(
                        foodItem: foodItem,
                        isSelected: selectedFoodItems.contains(foodItem.id)
                    ) {
                        toggleFoodItemSelection(foodItem.id)
                    }
                }
            }
        }
    }
    
    private func nutritionSummarySection(result: MealAnalysisResult) -> some View {
        let selectedItems = result.foodItems.filter { selectedFoodItems.contains($0.id) }
        let totalNutrition = calculateSelectedNutrition(from: selectedItems)
        
        return VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Nutrition Summary")
                .font(Constants.Typography.headline)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.textDark)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Constants.Spacing.medium) {
                NutritionCard(
                    title: "Calories",
                    value: "\(Int(totalNutrition.calories))",
                    unit: "kcal",
                    color: Constants.Colors.warningOrange,
                    icon: "flame.fill"
                )
                
                NutritionCard(
                    title: "Protein",
                    value: totalNutrition.formatted(totalNutrition.protein),
                    unit: "g",
                    color: Constants.Colors.primaryBlue,
                    icon: "bolt.fill"
                )
                
                NutritionCard(
                    title: "Carbs",
                    value: totalNutrition.formatted(totalNutrition.carbs),
                    unit: "g",
                    color: Constants.Colors.successGreen,
                    icon: "leaf.fill"
                )
                
                NutritionCard(
                    title: "Fat",
                    value: totalNutrition.formatted(totalNutrition.fat),
                    unit: "g",
                    color: Constants.Colors.errorRed,
                    icon: "drop.fill"
                )
            }
        }
    }
    
    private func macroBreakdownSection(result: MealAnalysisResult) -> some View {
        let selectedItems = result.foodItems.filter { selectedFoodItems.contains($0.id) }
        let totalNutrition = calculateSelectedNutrition(from: selectedItems)
        let breakdown = totalNutrition.macroBreakdown
        
        return VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Macronutrient Breakdown")
                .font(Constants.Typography.headline)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.textDark)
            
            VStack(spacing: Constants.Spacing.small) {
                MacroBar(
                    title: "Protein",
                    percentage: breakdown.protein,
                    color: Constants.Colors.primaryBlue
                )
                
                MacroBar(
                    title: "Carbs",
                    percentage: breakdown.carbs,
                    color: Constants.Colors.successGreen
                )
                
                MacroBar(
                    title: "Fat",
                    percentage: breakdown.fat,
                    color: Constants.Colors.errorRed
                )
            }
            .padding(Constants.Spacing.medium)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
    }
    
    private var analysisErrorView: some View {
        VStack(spacing: Constants.Spacing.large) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.warningOrange)
            
            Text("Analysis Failed")
                .font(Constants.Typography.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.textDark)
            
            Text(mealAnalysisManager.errorMessage ?? "Unable to analyze the image. Please try again with a clearer photo.")
                .font(Constants.Typography.body)
                .foregroundColor(Constants.Colors.textLight)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await performAnalysis()
                }
            }
            .font(Constants.Typography.body.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, Constants.Spacing.large)
            .padding(.vertical, Constants.Spacing.medium)
            .background(Constants.Colors.primaryBlue)
            .cornerRadius(Constants.cornerRadius)
        }
        .padding(Constants.Spacing.large)
    }
    
    private var saveMealDialog: some View {
        NavigationView {
            VStack(spacing: Constants.Spacing.large) {
                // Meal name input
                VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                    Text("Meal Name")
                        .font(Constants.Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textDark)
                    
                    TextField("Enter meal name", text: $mealName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Meal type selector
                VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                    Text("Meal Type")
                        .font(Constants.Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Picker("Meal Type", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            HStack {
                                Image(systemName: mealType.icon)
                                Text(mealType.rawValue)
                            }
                            .tag(mealType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Spacer()
                
                // Save button
                Button("Save Meal") {
                    if let result = analysisResult {
                        let updatedResult = MealAnalysisResult(
                            image: result.image,
                            foodItems: result.foodItems.map { item in
                                var updatedItem = item
                                updatedItem.isSelected = selectedFoodItems.contains(item.id)
                                return updatedItem
                            },
                            totalNutrition: calculateSelectedNutrition(from: result.foodItems.filter { selectedFoodItems.contains($0.id) }),
                            confidence: result.confidence,
                            analysisTime: result.analysisTime
                        )
                        
                        mealAnalysisManager.saveMeal(
                            updatedResult,
                            name: mealName.isEmpty ? "My Meal" : mealName,
                            mealType: selectedMealType
                        )
                        
                        showingSaveDialog = false
                        dismiss()
                    }
                }
                .font(Constants.Typography.body.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.Spacing.medium)
                .background(Constants.Colors.primaryBlue)
                .cornerRadius(Constants.cornerRadius)
                .disabled(selectedFoodItems.isEmpty)
            }
            .padding(Constants.Spacing.large)
            .navigationTitle("Save Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingSaveDialog = false
                    }
                }
            }
        }
    }
    
    private func performEnhancedAnalysis(image: UIImage) async {
        isAnalyzing = true
        
        // Use the meal analysis manager for food analysis
        Task {
            let result = await mealAnalysisManager.analyzeFood(from: image)
            DispatchQueue.main.async {
                switch result {
                case .success(let analysisResult):
                    self.analysisResult = analysisResult
                    self.selectedFoodItems = Set(analysisResult.foodItems.map { $0.id })
                case .failure(_):
                    break
                }
                self.isAnalyzing = false
            }
        }
    }
    
    // MARK: - Helper Functions
    private func performAnalysis() async {
        guard let image = capturedImage else { return }
        await performEnhancedAnalysis(image: image)
    }
    
    private func toggleFoodItemSelection(_ id: UUID) {
        if selectedFoodItems.contains(id) {
            selectedFoodItems.remove(id)
        } else {
            selectedFoodItems.insert(id)
        }
    }
    
    private func calculateSelectedNutrition(from foodItems: [FoodItem]) -> NutritionInfo {
        return NutritionInfo(
            calories: foodItems.reduce(0) { $0 + $1.nutrition.calories },
            protein: foodItems.reduce(0) { $0 + $1.nutrition.protein },
            carbs: foodItems.reduce(0) { $0 + $1.nutrition.carbs },
            fat: foodItems.reduce(0) { $0 + $1.nutrition.fat },
            fiber: foodItems.reduce(0) { $0 + $1.nutrition.fiber },
            sugar: foodItems.reduce(0) { $0 + $1.nutrition.sugar },
            sodium: foodItems.reduce(0) { $0 + $1.nutrition.sodium },
            cholesterol: foodItems.reduce(0) { $0 + $1.nutrition.cholesterol }
        )
    }
}

// MARK: - Missing View Methods Extension
extension MealAnalysisView {
    
    @ViewBuilder
    private func modernAnalysisResultView(result: MealAnalysisResult) -> some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.large) {
                // Analysis Results Content
                Text("Analysis Complete!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.successGreen)
                
                ForEach(result.foodItems) { item in
                    VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                        Text(item.name)
                            .font(.headline)
                            .foregroundColor(Constants.Colors.textDark)
                        
                        Text("Calories: \(Int(item.nutrition.calories))")
                            .font(.subheadline)
                            .foregroundColor(Constants.Colors.textLight)
                    }
                    .padding()
                    .background(Constants.Colors.cardBackground)
                    .cornerRadius(Constants.cornerRadius)
                }
                
                Button(action: { showingSaveDialog = true }) {
                    Text("Save Meal")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.Colors.primaryBlue)
                        .cornerRadius(Constants.cornerRadius)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var modernAnalysisErrorView: some View {
        VStack(spacing: Constants.Spacing.large) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.warningOrange)
            
            Text("Analysis Failed")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.textDark)
            
            Text("Unable to analyze the image. Please try again with a clearer photo.")
                .font(.body)
                .foregroundColor(Constants.Colors.textLight)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { capturedImage = nil }) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Constants.Colors.primaryBlue)
                    .cornerRadius(Constants.cornerRadius)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    @ViewBuilder
    private var modernSaveMealDialog: some View {
        NavigationView {
            VStack(spacing: Constants.Spacing.large) {
                Text("Save Your Meal")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                TextField("Meal Name", text: $mealName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Picker("Meal Type", selection: $selectedMealType) {
                    ForEach(MealType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                Button(action: {
                    // Save logic here
                    showingSaveDialog = false
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.Colors.successGreen)
                        .cornerRadius(Constants.cornerRadius)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Save Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingSaveDialog = false
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct ScanModeButton: View {
    let mode: MealAnalysisView.ScanMode
    let isSelected: Bool
    let onTap: () -> Void
    
    var modeIcon: String {
        switch mode {
        case .meal: return "camera.macro"
        case .barcode: return "barcode.viewfinder"
        case .nutrition: return "text.viewfinder"
        }
    }
    
    var modeDescription: String {
        switch mode {
        case .meal: return "Analyze complete meals with AI"
        case .barcode: return "Scan product barcodes instantly"
        case .nutrition: return "Read nutrition labels automatically"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Constants.Spacing.medium) {
                // Mode icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Constants.Colors.primaryBlue : Constants.Colors.backgroundGray)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: modeIcon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? .white : Constants.Colors.textLight)
                }
                
                // Mode info
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text(modeDescription)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Constants.Colors.primaryBlue : Constants.Colors.textLight)
            }
            .padding(Constants.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Constants.Colors.primaryBlue.opacity(0.1) : .white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Constants.Colors.primaryBlue : Constants.Colors.backgroundGray, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MealFeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Constants.Spacing.small) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.textDark)
            
            Spacer()
        }
    }
}

struct FoodItemRow: View {
    let foodItem: FoodItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Selection indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? Constants.Colors.primaryBlue : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Constants.Colors.primaryBlue, lineWidth: 2)
                        )
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                
                // Food info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(foodItem.name)
                            .font(Constants.Typography.body)
                            .fontWeight(.medium)
                            .foregroundColor(Constants.Colors.textDark)
                        
                        Spacer()
                        
                        Text("\(Int(foodItem.nutrition.calories)) cal")
                            .font(Constants.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.warningOrange)
                    }
                    
                    HStack {
                        Text(foodItem.portion.servingSize)
                            .font(Constants.Typography.caption)
                            .foregroundColor(Constants.Colors.textLight)
                        
                        Spacer()
                        
                        Text("Confidence: \(Int(foodItem.confidence * 100))%")
                            .font(Constants.Typography.caption)
                            .foregroundColor(Constants.Colors.textLight)
                    }
                }
                
                Spacer()
            }
            .padding(Constants.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(isSelected ? Constants.Colors.primaryBlue.opacity(0.1) : Constants.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .stroke(isSelected ? Constants.Colors.primaryBlue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NutritionCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: Constants.Spacing.small) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(Constants.Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(unit)
                    .font(Constants.Typography.caption)
                    .foregroundColor(color)
                    .fontWeight(.medium)
                
                Text(title)
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Spacer()
        }
        .frame(height: 100)
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct MacroBar: View {
    let title: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(Constants.Typography.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Text("\(Int(percentage))%")
                    .font(Constants.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(color.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * (percentage / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    MealAnalysisView()
}
