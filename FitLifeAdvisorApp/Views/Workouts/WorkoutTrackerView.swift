//
//  WorkoutTrackerView.swift
//  FitLifeAdvisorApp
//
//


//AI-powered workout tracking interface

import SwiftUI

struct WorkoutTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWorkoutType: WorkoutType = .strength
    @State private var isWorkoutActive = false
    @State private var workoutDuration: TimeInterval = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    enum WorkoutType: String, CaseIterable {
        case strength = "Strength"
        case cardio = "Cardio"
        case yoga = "Yoga"
        case hiit = "HIIT"
        case pilates = "Pilates"
        case running = "Running"
        
        var icon: String {
            switch self {
            case .strength: return "dumbbell.fill"
            case .cardio: return "heart.fill"
            case .yoga: return "figure.mind.and.body"
            case .hiit: return "flame.fill"
            case .pilates: return "figure.core.training"
            case .running: return "figure.run"
            }
        }
        
        var color: Color {
            switch self {
            case .strength: return Color(hex: "FF6B6B")
            case .cardio: return Color(hex: "4ECDC4")
            case .yoga: return Color(hex: "A8E6CF")
            case .hiit: return Color(hex: "FFD93D")
            case .pilates: return Color(hex: "6C5CE7")
            case .running: return Color(hex: "667eea")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.black, Color(hex: "1A1A2E")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 15) {
                            Text("🏋️‍♂️ Smart Workout")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("AI-powered personal training")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Workout Type Selection
                        workoutTypeSelection
                        
                        // Timer/Status Card
                        workoutStatusCard
                        
                        // Quick Actions
                        if !isWorkoutActive {
                            quickWorkoutActions
                        }
                        
                        // AI Recommendations
                        aiRecommendations
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "00E5FF"))
                }
            }
            .onReceive(timer) { _ in
                if isWorkoutActive {
                    workoutDuration += 1
                }
            }
        }
    }
    
    private var workoutTypeSelection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Choose Workout Type")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(WorkoutType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedWorkoutType = type
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(selectedWorkoutType == type ? .white : type.color)
                            
                            Text(type.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedWorkoutType == type ? .white : .white.opacity(0.8))
                        }
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedWorkoutType == type ? type.color.opacity(0.3) : Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedWorkoutType == type ? type.color : Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
    }
    
    private var workoutStatusCard: some View {
        VStack(spacing: 20) {
            if isWorkoutActive {
                // Active workout display
                VStack(spacing: 15) {
                    Text("Workout in Progress")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(timeString(from: workoutDuration))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(selectedWorkoutType.color)
                        .monospacedDigit()
                    
                    HStack(spacing: 30) {
                        Button("Pause") {
                            isWorkoutActive = false
                        }
                        .buttonStyle(WorkoutButtonStyle(color: .orange))
                        
                        Button("Finish") {
                            isWorkoutActive = false
                            workoutDuration = 0
                        }
                        .buttonStyle(WorkoutButtonStyle(color: .green))
                    }
                }
            } else {
                // Start workout
                VStack(spacing: 15) {
                    Image(systemName: selectedWorkoutType.icon)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(selectedWorkoutType.color)
                    
                    Text("Ready for \(selectedWorkoutType.rawValue)?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Button("Start Workout") {
                        isWorkoutActive = true
                        workoutDuration = 0
                    }
                    .buttonStyle(WorkoutButtonStyle(color: selectedWorkoutType.color))
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var quickWorkoutActions: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                QuickActionRow(title: "7-Minute HIIT", subtitle: "High intensity fat burn", icon: "flame.fill", color: .orange)
                QuickActionRow(title: "Morning Yoga", subtitle: "Gentle stretch routine", icon: "figure.mind.and.body", color: .green)
                QuickActionRow(title: "Core Blast", subtitle: "15-minute ab workout", icon: "figure.core.training", color: .purple)
            }
        }
    }
    
    private var aiRecommendations: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(Color(hex: "00E5FF"))
                Text("AI Recommendations")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                RecommendationRow(
                    title: "Perfect timing for cardio",
                    description: "Your heart rate is optimal for fat burning",
                    color: Color(hex: "4ECDC4")
                )
                
                RecommendationRow(
                    title: "Rest day suggestion",
                    description: "You've worked out 4 days straight, consider active recovery",
                    color: Color(hex: "FFD93D")
                )
            }
        }
    }
    
    private func timeString(from duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct WorkoutButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct QuickActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct RecommendationRow: View {
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 4, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    WorkoutTrackerView()
}
