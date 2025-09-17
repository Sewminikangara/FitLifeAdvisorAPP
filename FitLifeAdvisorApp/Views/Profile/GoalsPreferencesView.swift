//
//  GoalsPreferencesView.swift
//  FitLifeAdvisorApp
//
//  Goals and Preferences Management
//

import SwiftUI

struct GoalsPreferencesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var weightGoal: String = ""
    @State private var dailyCalories: String = ""
    @State private var weeklyWorkouts: Double = 3
    @State private var waterIntake: Double = 8
    @State private var sleepHours: Double = 8
    
    @State private var selectedGoalType: GoalType = .weightLoss
    @State private var selectedDietType: DietType = .balanced
    @State private var selectedUnits: UnitType = .metric
    
    enum GoalType: String, CaseIterable {
        case weightLoss = "Weight Loss"
        case weightGain = "Weight Gain"
        case maintenance = "Maintain Weight"
        case muscleGain = "Build Muscle"
        case endurance = "Improve Endurance"
    }
    
    enum DietType: String, CaseIterable {
        case balanced = "Balanced"
        case lowCarb = "Low Carb"
        case lowFat = "Low Fat"
        case highProtein = "High Protein"
        case mediterranean = "Mediterranean"
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case keto = "Ketogenic"
    }
    
    enum UnitType: String, CaseIterable {
        case metric = "Metric (kg, cm)"
        case imperial = "Imperial (lbs, ft)"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.large) {
                    // Header
                    goalsHeader
                    
                    // Goals Sections
                    VStack(spacing: Constants.Spacing.large) {
                        // Primary Goal Section
                        primaryGoalSection
                        
                        // Target Values Section
                        targetValuesSection
                        
                        // Diet Preferences Section
                        dietPreferencesSection
                        
                        // Daily Targets Section
                        dailyTargetsSection
                        
                        // Units & Preferences Section
                        unitsPreferencesSection
                        
                        // Save Button
                        saveButton
                    }
                    .padding(.bottom, Constants.Spacing.extraLarge)
                }
            }
            .background(Constants.Colors.backgroundGray)
            .navigationTitle("Goals & Preferences")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private var goalsHeader: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .green.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 4) {
                Text("Set Your Goals")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text("Define your fitness journey and preferences")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, Constants.Spacing.large)
    }
    
    private var primaryGoalSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Primary Goal")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
                .padding(.horizontal, Constants.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.medium) {
                    ForEach(GoalType.allCases, id: \.self) { goal in
                        GoalCard(
                            title: goal.rawValue,
                            icon: iconForGoal(goal),
                            color: colorForGoal(goal),
                            isSelected: selectedGoalType == goal
                        ) {
                            selectedGoalType = goal
                        }
                    }
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
    
    private var targetValuesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Target Values")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
                .padding(.horizontal, Constants.Spacing.large)
            
            VStack(spacing: Constants.Spacing.medium) {
                HStack(spacing: Constants.Spacing.medium) {
                    ModernTextField(
                        title: "Target Weight",
                        text: $weightGoal,
                        placeholder: "70 kg",
                        icon: "scalemass.fill",
                        keyboardType: .decimalPad
                    )
                    
                    ModernTextField(
                        title: "Daily Calories",
                        text: $dailyCalories,
                        placeholder: "2000",
                        icon: "flame.fill",
                        keyboardType: .numberPad
                    )
                }
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    private var dietPreferencesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Diet Preferences")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
                .padding(.horizontal, Constants.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.small) {
                    ForEach(DietType.allCases, id: \.self) { diet in
                        DietChip(
                            title: diet.rawValue,
                            isSelected: selectedDietType == diet
                        ) {
                            selectedDietType = diet
                        }
                    }
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
    
    private var dailyTargetsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Daily Targets")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
                .padding(.horizontal, Constants.Spacing.large)
            
            VStack(spacing: Constants.Spacing.medium) {
                SliderRow(
                    title: "Weekly Workouts",
                    value: $weeklyWorkouts,
                    range: 0...7,
                    step: 1,
                    unit: "days",
                    icon: "figure.run",
                    color: .blue
                )
                
                SliderRow(
                    title: "Water Intake",
                    value: $waterIntake,
                    range: 4...16,
                    step: 1,
                    unit: "glasses",
                    icon: "drop.fill",
                    color: .cyan
                )
                
                SliderRow(
                    title: "Sleep Goal",
                    value: $sleepHours,
                    range: 6...10,
                    step: 0.5,
                    unit: "hours",
                    icon: "moon.fill",
                    color: .purple
                )
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    private var unitsPreferencesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Units & Preferences")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
                .padding(.horizontal, Constants.Spacing.large)
            
            VStack(spacing: Constants.Spacing.small) {
                ForEach(UnitType.allCases, id: \.self) { unit in
                    Button(action: {
                        selectedUnits = unit
                    }) {
                        HStack {
                            Image(systemName: selectedUnits == unit ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(selectedUnits == unit ? Constants.Colors.primaryBlue : Constants.Colors.textLight)
                            
                            Text(unit.rawValue)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textDark)
                            
                            Spacer()
                        }
                        .padding(Constants.Spacing.medium)
                        .background(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    private var saveButton: some View {
        Button(action: saveGoals) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                
                Text("Save Goals & Preferences")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .padding(.horizontal, Constants.Spacing.large)
    }
    
    private func iconForGoal(_ goal: GoalType) -> String {
        switch goal {
        case .weightLoss: return "minus.circle.fill"
        case .weightGain: return "plus.circle.fill"
        case .maintenance: return "equal.circle.fill"
        case .muscleGain: return "figure.strengthtraining.traditional"
        case .endurance: return "figure.run"
        }
    }
    
    private func colorForGoal(_ goal: GoalType) -> Color {
        switch goal {
        case .weightLoss: return .red
        case .weightGain: return .green
        case .maintenance: return .blue
        case .muscleGain: return .orange
        case .endurance: return .purple
        }
    }
    
    private func saveGoals() {
        // TODO: Save goals and preferences
        dismiss()
    }
}

// MARK: - Supporting Views
struct GoalCard: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Constants.Spacing.small) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : color)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : Constants.Colors.textDark)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100, height: 80)
            .background(isSelected ? color : .white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(isSelected ? 0.2 : 0.05), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 1)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct DietChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : Constants.Colors.primaryBlue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Constants.Colors.primaryBlue : Constants.Colors.primaryBlue.opacity(0.1))
                .cornerRadius(20)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Text("\(Int(value)) \(unit)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Slider(value: $value, in: range, step: step)
                .accentColor(color)
        }
        .padding(Constants.Spacing.medium)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

#Preview {
    GoalsPreferencesView()
        .environmentObject(AuthenticationManager())
}
