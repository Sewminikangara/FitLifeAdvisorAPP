//
//  ProductionWorkoutView.swift
//  FitLifeAdvisorApp
//
//  Created by sewmini010 on 11/09/2025.



//   Workout View with Real GPS, Timer & HealthKit

import SwiftUI
import HealthKit
import MapKit

struct ProductionWorkoutView: View {
    @StateObject private var workoutManager = WorkoutManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var recommendationEngine = RecommendationEngine.shared
    
    @State private var selectedWorkoutType: HKWorkoutActivityType = .running
    @State private var showingWorkoutSelection = false
    @State private var showingPermissionAlert = false
    @State private var showingWorkoutComplete = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    // Quick-start support
    private let initialWorkoutType: HKWorkoutActivityType?
    private let autoStart: Bool

    init(initialWorkoutType: HKWorkoutActivityType? = nil, autoStart: Bool = false) {
        self._selectedWorkoutType = State(initialValue: initialWorkoutType ?? .running)
        self.initialWorkoutType = initialWorkoutType
        self.autoStart = autoStart
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.04, blue: 0.04),
                        Color(red: 0.1, green: 0.1, blue: 0.18),
                        Color(red: 0.09, green: 0.13, blue: 0.24)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Navigation header
                    workoutNavigationHeader
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Current workout status or start options
                            if workoutManager.workoutState == .idle {
                                workoutSelectionSection
                                recommendationsSection
                                recentWorkoutsSection
                            } else {
                                activeWorkoutSection
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .onAppear {
            setupView()
        }
        .alert("Permissions Required", isPresented: $showingPermissionAlert) {
            Button("Settings") { openSettings() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("FitLife needs access to HealthKit and Location services for accurate workout tracking.")
        }
        .sheet(isPresented: $showingWorkoutComplete) {
            WorkoutCompletionView()
        }
    }
    
    //View Components
    
    private var workoutNavigationHeader: some View {
        HStack {
            Text("Workouts")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { showingPermissionAlert = true }) {
                Image(systemName: workoutManager.locationPermissionStatus == .authorizedWhenInUse ? "location.fill" : "location.slash")
                    .font(.title2)
                    .foregroundColor(workoutManager.locationPermissionStatus == .authorizedWhenInUse ? Color.green : Color.orange)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var workoutSelectionSection: some View {
        VStack(spacing: 16) {
            // Quick start options
            Text("Quick Start")
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(popularWorkoutTypes, id: \.self) { workoutType in
                    WorkoutTypeCard(
                        workoutType: workoutType,
                        isSelected: selectedWorkoutType == workoutType
                    ) {
                        selectedWorkoutType = workoutType
                        startWorkout(workoutType)
                    }
                }
            }
            
            // All workout types button
            Button(action: { showingWorkoutSelection = true }) {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("All Workout Types")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.vertical, 20)
    }
    
    private var recommendationsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(" AI Recommendations")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Spacer()
            }
            
            if recommendationEngine.synergyRecommendations.isEmpty {
                EmptyRecommendationsCard()
            } else {
                ForEach(recommendationEngine.synergyRecommendations.prefix(2), id: \.id) { recommendation in
                    RecommendationCard(recommendation: recommendation) {
                        handleRecommendationAction(recommendation)
                    }
                }
            }
        }
    }
    
    private var recentWorkoutsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Workouts")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Spacer()
                Button("View All") {
                    // Navigate to full workout history
                }
                .foregroundColor(Color(red: 0, green: 0.9, blue: 1))
            }
            
            if healthKitManager.recentWorkouts.isEmpty {
                EmptyWorkoutsCard()
            } else {
                ForEach(healthKitManager.recentWorkouts.prefix(3), id: \.id) { workout in
                    RecentWorkoutCard(workout: workout)
                }
            }
        }
    }
    
    private var activeWorkoutSection: some View {
        VStack(spacing: 24) {
            // Workout status card
            ActiveWorkoutStatusCard(
                workoutManager: workoutManager,
                onPause: { workoutManager.pauseWorkout() },
                onResume: { workoutManager.resumeWorkout() },
                onEnd: { 
                    workoutManager.endWorkout()
                    showingWorkoutComplete = true
                }
            )
            
            // Real-time metrics
            WorkoutMetricsGrid(workoutManager: workoutManager)
            
            // GPS map (if enabled)
            if workoutManager.isGPSEnabled && !workoutManager.routeLocations.isEmpty {
                WorkoutMapView(
                    routeLocations: workoutManager.routeLocations,
                    currentLocation: workoutManager.currentLocation
                )
                .frame(height: 200)
                .cornerRadius(16)
            }
            
            // Heart rate chart
            if !(workoutManager.currentWorkout?.heartRateData.isEmpty ?? true) {
                HeartRateChart(heartRateData: workoutManager.currentWorkout?.heartRateData ?? [])
                    .frame(height: 120)
            }
        }
    }
    
    //  Helper Properties
    
    private var popularWorkoutTypes: [HKWorkoutActivityType] {
        [.running, .walking, .cycling, .functionalStrengthTraining, .yoga, .swimming]
    }
    
    //Actions
    
    private func setupView() {
        Task {
            // Request permissions
            if !healthKitManager.isAuthorized {
                try? await healthKitManager.requestAuthorization()
            }

            if workoutManager.locationPermissionStatus == .notDetermined {
                workoutManager.requestLocationPermission()
            }

            // Load data
            await healthKitManager.loadAllHealthData()
            await recommendationEngine.analyzeUserData()

            // Auto-start if requested and authorized
            if autoStart, let type = initialWorkoutType, workoutManager.workoutState == .idle, healthKitManager.isAuthorized {
                await MainActor.run {
                    selectedWorkoutType = type
                    startWorkout(type)
                }
            }
        }
    }
    
    private func startWorkout(_ type: HKWorkoutActivityType) {
        guard healthKitManager.isAuthorized else {
            showingPermissionAlert = true
            return
        }
        
        let enableGPS = [.running, .walking, .cycling].contains(type)
        workoutManager.startWorkout(type: type, enableGPS: enableGPS)
    }
    
    private func handleRecommendationAction(_ recommendation: FitnessRecommendation) {
        // Handle recommendation tap - could show details or execute action
        print("Handling recommendation: \(recommendation.title)")
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// Supporting Views

struct WorkoutTypeCard: View {
    let workoutType: HKWorkoutActivityType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: workoutType.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(Color(red: 1, green: 0.84, blue: 0))
                
                Text(workoutType.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color(red: 1, green: 0.84, blue: 0) : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct ActiveWorkoutStatusCard: View {
    @ObservedObject var workoutManager: WorkoutManager
    let onPause: () -> Void
    let onResume: () -> Void
    let onEnd: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Workout type and duration
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workoutManager.currentWorkout?.type.displayName ?? "Workout")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text(workoutManager.workoutState.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text(formatDuration(workoutManager.elapsedTime))
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0, green: 0.9, blue: 1))
            }
            
            // Control buttons
            HStack(spacing: 16) {
                // Pause/Resume button
                Button(action: workoutManager.workoutState == .active ? onPause : onResume) {
                    Image(systemName: workoutManager.workoutState == .active ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color(red: 1, green: 0.84, blue: 0))
                        )
                }
                
                Spacer()
                
                // End workout button
                Button(action: onEnd) {
                    Text("End Workout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.red)
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct WorkoutMetricsGrid: View {
    @ObservedObject var workoutManager: WorkoutManager
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            MetricCard(
                title: "Distance",
                value: formatDistance(workoutManager.totalDistance),
                icon: "location",
                color: Color(red: 0, green: 0.9, blue: 1)
            )
            
            MetricCard(
                title: "Calories",
                value: "\(Int(workoutManager.estimatedCalories))",
                icon: "flame.fill",
                color: Color.orange
            )
            
            MetricCard(
                title: "Heart Rate",
                value: "\(Int(workoutManager.currentHeartRate))",
                unit: "BPM",
                icon: "heart.fill",
                color: Color.red
            )
            
            MetricCard(
                title: "Pace",
                value: formatPace(workoutManager.currentPace),
                icon: "speedometer",
                color: Color.green
            )
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String?
    let icon: String
    let color: Color
    
    init(title: String, value: String, unit: String? = nil, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.unit = unit
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    if let unit = unit {
                        Text(unit)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(16)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct WorkoutMapView: View {
    let routeLocations: [CLLocation]
    let currentLocation: CLLocation?
    
    @State private var region = MKCoordinateRegion()
    
    private var identifiableLocations: [IdentifiableLocation] {
        routeLocations.enumerated().map { index, location in
            IdentifiableLocation(id: index, location: location)
        }
    }
    
    var body: some View {
        Map(coordinateRegion: .constant(region), annotationItems: identifiableLocations) { item in
            MapPin(coordinate: item.location.coordinate, tint: .blue)
        }
        .onAppear {
            updateRegion()
        }
        .onChange(of: routeLocations) { _ in
            updateRegion()
        }
    }
    
    private func updateRegion() {
        guard let firstLocation = routeLocations.first else { return }
        
        var minLat = firstLocation.coordinate.latitude
        var maxLat = firstLocation.coordinate.latitude
        var minLon = firstLocation.coordinate.longitude
        var maxLon = firstLocation.coordinate.longitude
        
        for location in routeLocations {
            minLat = min(minLat, location.coordinate.latitude)
            maxLat = max(maxLat, location.coordinate.latitude)
            minLon = min(minLon, location.coordinate.longitude)
            maxLon = max(maxLon, location.coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.01, (maxLat - minLat) * 1.2),
            longitudeDelta: max(0.01, (maxLon - minLon) * 1.2)
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
}

struct HeartRateChart: View {
    let heartRateData: [HeartRatePoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Heart Rate")
                .font(.headline)
                .foregroundColor(.white)
            
            // Simplified chart (in production, use Charts framework)
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay(
                    Text("Heart Rate Chart")
                        .foregroundColor(.white.opacity(0.7))
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct RecommendationCard: View {
    let recommendation: FitnessRecommendation
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(recommendation.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text(recommendation.priority.displayName)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(priorityColor(recommendation.priority))
                        )
                }
                
                Text(recommendation.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                HStack {
                    Text("Confidence: \(Int(recommendation.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text(recommendation.timeframe)
                        .font(.caption)
                        .foregroundColor(Color(red: 0, green: 0.9, blue: 1))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    private func priorityColor(_ priority: RecommendationPriority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .green
        case .high: return .orange
        case .critical: return .red
        }
    }
}

struct RecentWorkoutCard: View {
    let workout: WorkoutData
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: workout.type.icon)
                .font(.title2)
                .foregroundColor(Color(red: 1, green: 0.84, blue: 0))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.type.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text(formatDuration(workout.duration))
                    Text("•")
                    Text(formatDistance(workout.totalDistance))
                    Text("•")
                    Text("\(Int(workout.totalEnergyBurned)) cal")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text(relativeDateString(workout.startDate))
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct EmptyRecommendationsCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))
            
            Text("Building AI Insights")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Complete more workouts and log meals to receive personalized recommendations.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct EmptyWorkoutsCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No Recent Workouts")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Start your first workout to see your history here.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct WorkoutCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("🎉")
                .font(.system(size: 80))
            
            Text("Workout Complete!")
                .font(.title.bold())
                .foregroundColor(.white)
            
            Text("Great job! Your workout has been saved to Apple Health.")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button("Done") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 1, green: 0.84, blue: 0))
            )
        }
        .padding(32)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.04),
                    Color(red: 0.1, green: 0.1, blue: 0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// Extensions

extension WorkoutState {
    var description: String {
        switch self {
        case .idle: return "Ready to start"
        case .starting: return "Starting..."
        case .active: return "Active"
        case .paused: return "Paused"
        case .ending: return "Ending..."
        case .completed: return "Completed"
        }
    }
}

//  Helper Functions

private func formatDuration(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = Int(duration) % 3600 / 60
    let seconds = Int(duration) % 60
    
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else {
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private func formatDistance(_ distance: Double) -> String {
    if distance >= 1000 {
        return String(format: "%.2f km", distance / 1000.0)
    } else {
        return String(format: "%.0f m", distance)
    }
}

private func formatPace(_ pace: Double) -> String {
    guard pace > 0 && pace.isFinite else { return "--:--" }
    let minutes = Int(pace) / 60
    let seconds = Int(pace) % 60
    return String(format: "%d:%02d", minutes, seconds)
}

private func relativeDateString(_ date: Date) -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: date, relativeTo: Date())
}

struct IdentifiableLocation: Identifiable {
    let id: Int
    let location: CLLocation
}

#Preview {
    ProductionWorkoutView()
}
