//
//  WorkoutManager.swift
//  FitLifeAdvisorApp
//created by Sewmini 010 on 2025-08-28.
//

import Foundation
import CoreLocation
import CoreMotion
import HealthKit
import Combine
import AVFoundation

// MARK: - Workout Models
struct ActiveWorkout {
    let id = UUID()
    let type: HKWorkoutActivityType
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval {
        let endTime = self.endTime ?? Date()
        return endTime.timeIntervalSince(startTime)
    }
    var calories: Double = 0
    var distance: Double = 0
    var avgHeartRate: Double = 0
    var maxHeartRate: Double = 0
    var route: [CLLocation] = []
    var heartRateData: [HeartRatePoint] = []
    var splits: [WorkoutSplit] = []
    var metadata: [String: Any] = [:]
}

struct WorkoutSplit {
    let splitNumber: Int
    let distance: Double // in meters
    let time: TimeInterval
    let pace: Double // seconds per km
    let heartRate: Double
    let location: CLLocation?
}

enum WorkoutState {
    case idle
    case starting
    case active
    case paused
    case ending
    case completed
}

enum WorkoutDetectionType {
    case manual
    case automatic
    case imported
}

// MARK: - Location & Motion Permissions
enum LocationPermissionStatus {
    case notDetermined
    case denied
    case restricted
    case authorizedWhenInUse
    case authorizedAlways
}

// MARK: - Main Workout Manager
@MainActor
class WorkoutManager: NSObject, ObservableObject {
    static let shared = WorkoutManager()
    
    // MARK: - Published Properties
    @Published var currentWorkout: ActiveWorkout?
    @Published var workoutState: WorkoutState = .idle
    @Published var isGPSEnabled = false
    @Published var locationPermissionStatus: LocationPermissionStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var routeLocations: [CLLocation] = []
    
    // Real-time metrics
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentPace: Double = 0 // seconds per km
    @Published var currentSpeed: Double = 0 // m/s
    @Published var totalDistance: Double = 0
    @Published var estimatedCalories: Double = 0
    @Published var currentHeartRate: Double = 0
    
    // Workout detection
    @Published var isAutoDetectionEnabled = true
    @Published var detectedActivityType: HKWorkoutActivityType?
    @Published var detectionConfidence: Double = 0.0
    
    // Audio feedback
    @Published var isAudioFeedbackEnabled = true
    @Published var feedbackInterval: TimeInterval = 300 // 5 minutes
    
    // MARK: - Core Services
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    private let healthKitManager = HealthKitManager.shared
    private let audioEngine = AVAudioEngine()
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - Timers & Background
    private var workoutTimer: Timer?
    private var lastLocationUpdate: Date?
    private var lastSplit: WorkoutSplit?
    private var splitDistance: Double = 1000 // 1km splits
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
        setupMotionManager()
        setupAudioFeedback()
        startActivityDetection()
    }
    
    // MARK: - Location Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5.0 // Update every 5 meters
        locationManager.allowsBackgroundLocationUpdates = false // Will enable during workout
        
        updateLocationPermissionStatus()
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    private func updateLocationPermissionStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationPermissionStatus = .notDetermined
        case .denied:
            locationPermissionStatus = .denied
        case .restricted:
            locationPermissionStatus = .restricted
        case .authorizedWhenInUse:
            locationPermissionStatus = .authorizedWhenInUse
        case .authorizedAlways:
            locationPermissionStatus = .authorizedAlways
        @unknown default:
            locationPermissionStatus = .denied
        }
    }
    
    // MARK: - Motion & Activity Detection Setup
    private func setupMotionManager() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 10.0 // 10 Hz
        motionManager.accelerometerUpdateInterval = 1.0 / 50.0 // 50 Hz
        motionManager.gyroUpdateInterval = 1.0 / 50.0 // 50 Hz
    }
    
    private func startActivityDetection() {
        guard isAutoDetectionEnabled && motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            self.processMotionData(motion)
        }
    }
    
    private func processMotionData(_ motion: CMDeviceMotion) {
        // Simple activity detection based on acceleration patterns
        let acceleration = motion.userAcceleration
        let magnitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
        
        // Basic activity classification
        if magnitude > 0.5 {
            // High movement - running
            detectedActivityType = .running
            detectionConfidence = min(magnitude / 2.0, 1.0)
        } else if magnitude > 0.2 {
            // Medium movement - walking
            detectedActivityType = .walking
            detectionConfidence = min(magnitude / 0.5, 1.0)
        } else {
            // Low movement - stationary
            detectedActivityType = nil
            detectionConfidence = 0.0
        }
        
        // Auto-start workout if confidence is high enough
        if detectionConfidence > 0.8 && workoutState == .idle && isAutoDetectionEnabled {
            suggestWorkoutStart()
        }
    }
    
    // MARK: - Workout Controls
    func startWorkout(type: HKWorkoutActivityType, enableGPS: Bool = true) {
        guard workoutState == .idle else { return }
        
        workoutState = .starting
        isGPSEnabled = enableGPS
        
        // Create new workout
        currentWorkout = ActiveWorkout(
            type: type,
            startTime: Date()
        )
        
        // Start location tracking if enabled
        if enableGPS && (locationPermissionStatus == .authorizedWhenInUse || locationPermissionStatus == .authorizedAlways) {
            startLocationTracking()
        }
        
        // Start workout timer
        startWorkoutTimer()
        
        // Start heart rate monitoring
        startHeartRateMonitoring()
        
        // Audio feedback
        announceWorkoutStart(type)
        
        workoutState = .active
        
        print("🏃‍♀️ Workout started: \(type.displayName)")
    }
    
    func pauseWorkout() {
        guard workoutState == .active else { return }
        
        workoutState = .paused
        stopLocationTracking()
        stopWorkoutTimer()
        
        announceWorkoutPaused()
        print("⏸️ Workout paused")
    }
    
    func resumeWorkout() {
        guard workoutState == .paused else { return }
        
        workoutState = .active
        
        if isGPSEnabled {
            startLocationTracking()
        }
        startWorkoutTimer()
        
        announceWorkoutResumed()
        print("▶️ Workout resumed")
    }
    
    func endWorkout() {
        guard let workout = currentWorkout else { return }
        
        workoutState = .ending
        
        // Stop all tracking
        stopLocationTracking()
        stopWorkoutTimer()
        stopHeartRateMonitoring()
        
        // Finalize workout data
        var finalWorkout = workout
        finalWorkout.endTime = Date()
        finalWorkout.calories = estimatedCalories
        finalWorkout.distance = totalDistance
        finalWorkout.route = routeLocations
        
        // Save to HealthKit
        Task {
            await saveWorkoutToHealthKit(finalWorkout)
        }
        
        // Audio feedback
        announceWorkoutCompleted(finalWorkout)
        
        // Reset state
        resetWorkoutState()
        workoutState = .completed
        
        print("✅ Workout completed: \(finalWorkout.duration) seconds, \(finalWorkout.distance) meters")
    }
    
    private func resetWorkoutState() {
        currentWorkout = nil
        elapsedTime = 0
        currentPace = 0
        currentSpeed = 0
        totalDistance = 0
        estimatedCalories = 0
        routeLocations.removeAll()
        lastLocationUpdate = nil
        lastSplit = nil
        workoutState = .idle
    }
    
    // MARK: - Location Tracking
    private func startLocationTracking() {
        guard locationPermissionStatus != .denied && locationPermissionStatus != .restricted else {
            print("❌ Location permission denied")
            return
        }
        
        // Enable background location during workout
        if locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) {
            locationManager.allowsBackgroundLocationUpdates = true
        }
        
        locationManager.startUpdatingLocation()
        print("📍 GPS tracking started")
    }
    
    private func stopLocationTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        print("📍 GPS tracking stopped")
    }
    
    // MARK: - Workout Timer
    private func startWorkoutTimer() {
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateWorkoutMetrics()
        }
    }
    
    private func stopWorkoutTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }
    
    private func updateWorkoutMetrics() {
        guard let workout = currentWorkout, workoutState == .active else { return }
        
        elapsedTime = workout.duration
        
        // Update calories (basic estimation)
        updateCalorieEstimation()
        
        // Calculate pace and speed
        if totalDistance > 0 && elapsedTime > 0 {
            currentPace = (elapsedTime / (totalDistance / 1000.0)) // seconds per km
            currentSpeed = totalDistance / elapsedTime // m/s
        }
        
        // Check for splits
        checkForNewSplit()
        
        // Audio feedback
        if isAudioFeedbackEnabled && Int(elapsedTime) % Int(feedbackInterval) == 0 && elapsedTime > 0 {
            provideAudioFeedback()
        }
    }
    
    // MARK: - Calorie Estimation
    private func updateCalorieEstimation() {
        guard let workout = currentWorkout else { return }
        
        // Basic MET (Metabolic Equivalent) calculation
        let bodyWeight = healthKitManager.todaysMetrics.bodyWeight // kg
        let weightToUse = bodyWeight > 0 ? bodyWeight : 70.0 // Default 70kg
        
        let met: Double
        switch workout.type {
        case .running:
            // MET varies by speed: 6 mph = 9.8 METs, 8 mph = 11.8 METs
            let speedKmh = currentSpeed * 3.6
            met = max(8.0, min(15.0, 6.0 + (speedKmh - 6.0) * 0.5))
        case .walking:
            let speedKmh = currentSpeed * 3.6
            met = max(3.0, min(6.0, 2.0 + speedKmh * 0.5))
        case .cycling:
            let speedKmh = currentSpeed * 3.6
            met = max(4.0, min(16.0, speedKmh * 0.5))
        case .swimming:
            met = 8.0
        case .functionalStrengthTraining, .traditionalStrengthTraining:
            met = 6.0
        case .yoga:
            met = 2.5
        default:
            met = 5.0
        }
        
        // Calories = METs × weight(kg) × time(hours)
        let hours = elapsedTime / 3600.0
        estimatedCalories = met * weightToUse * hours
    }
    
    // MARK: - Heart Rate Monitoring
    private func startHeartRateMonitoring() {
        // Request real-time heart rate from HealthKit or connected devices
        // This would integrate with Apple Watch or other heart rate monitors
        
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] timer in
            guard let self = self, self.workoutState == .active else {
                timer.invalidate()
                return
            }
            
            // Simulate heart rate for now (in production, this would be real data)
            self.simulateHeartRate()
        }
    }
    
    private func stopHeartRateMonitoring() {
        // Stop heart rate monitoring
    }
    
    private func simulateHeartRate() {
        // Simulate realistic heart rate based on workout intensity
        guard let workout = currentWorkout else { return }
        
        let baseHR = healthKitManager.todaysMetrics.restingHeartRate > 0 ? 
                     healthKitManager.todaysMetrics.restingHeartRate : 60.0
        
        let intensity: Double
        switch workout.type {
        case .running:
            intensity = 1.5 + (currentSpeed / 5.0) // Higher intensity for faster running
        case .walking:
            intensity = 1.2 + (currentSpeed / 2.0)
        case .cycling:
            intensity = 1.3 + (currentSpeed / 8.0)
        case .functionalStrengthTraining, .traditionalStrengthTraining:
            intensity = 1.4
        default:
            intensity = 1.3
        }
        
        currentHeartRate = baseHR * intensity + Double.random(in: -5...5)
        currentHeartRate = max(60, min(200, currentHeartRate)) // Reasonable bounds
        
        // Add to workout data
        if var workout = currentWorkout {
            workout.heartRateData.append(HeartRatePoint(heartRate: currentHeartRate, timestamp: Date()))
        }
    }
    
    // MARK: - Splits & Milestones
    private func checkForNewSplit() {
        guard totalDistance >= splitDistance else { return }
        
        let splitNumber = Int(totalDistance / splitDistance)
        let lastSplitNumber = lastSplit?.splitNumber ?? 0
        
        if splitNumber > lastSplitNumber {
            createNewSplit(splitNumber)
        }
    }
    
    private func createNewSplit(_ splitNumber: Int) {
        let splitTime = elapsedTime - (lastSplit?.time ?? 0)
        let splitPace = splitTime / (splitDistance / 1000.0) // seconds per km
        
        let newSplit = WorkoutSplit(
            splitNumber: splitNumber,
            distance: splitDistance,
            time: splitTime,
            pace: splitPace,
            heartRate: currentHeartRate,
            location: currentLocation
        )
        
        currentWorkout?.splits.append(newSplit)
        lastSplit = newSplit
        
        // Announce split
        announceSplit(newSplit)
        
        print("📊 Split \(splitNumber): \(formatPace(splitPace))")
    }
    
    // MARK: - Audio Feedback
    private func setupAudioFeedback() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        } catch {
            print("❌ Audio session setup failed: \(error)")
        }
    }
    
    private func announceWorkoutStart(_ type: HKWorkoutActivityType) {
        guard isAudioFeedbackEnabled else { return }
        speak("Workout started. \(type.displayName) tracking active.")
    }
    
    private func announceWorkoutPaused() {
        guard isAudioFeedbackEnabled else { return }
        speak("Workout paused.")
    }
    
    private func announceWorkoutResumed() {
        guard isAudioFeedbackEnabled else { return }
        speak("Workout resumed.")
    }
    
    private func announceWorkoutCompleted(_ workout: ActiveWorkout) {
        guard isAudioFeedbackEnabled else { return }
        
        let timeString = formatDuration(workout.duration)
        let distanceString = formatDistance(workout.distance)
        let caloriesString = "\(Int(workout.calories))"
        
        speak("Workout completed. Time: \(timeString). Distance: \(distanceString). Calories: \(caloriesString).")
    }
    
    private func announceSplit(_ split: WorkoutSplit) {
        guard isAudioFeedbackEnabled else { return }
        
        let paceString = formatPace(split.pace)
        speak("Split \(split.splitNumber). Pace: \(paceString).")
    }
    
    private func provideAudioFeedback() {
        guard isAudioFeedbackEnabled else { return }
        
        let timeString = formatDuration(elapsedTime)
        let distanceString = formatDistance(totalDistance)
        let paceString = formatPace(currentPace)
        let heartRateString = "\(Int(currentHeartRate))"
        
        speak("Time: \(timeString). Distance: \(distanceString). Pace: \(paceString). Heart rate: \(heartRateString).")
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }
    
    // MARK: - Auto-detection & Suggestions
    private func suggestWorkoutStart() {
        guard let activityType = detectedActivityType else { return }
        
        // In a real app, this would show a notification or alert
        print("🤖 Auto-detected \(activityType.displayName) activity. Suggesting workout start.")
        
        // Could automatically start workout or show user prompt
        // For now, just log the detection
    }
    
    // MARK: - HealthKit Integration
    private func saveWorkoutToHealthKit(_ workout: ActiveWorkout) async {
        do {
            try await healthKitManager.saveWorkout(
                type: workout.type,
                startDate: workout.startTime,
                endDate: workout.endTime ?? Date(),
                totalEnergyBurned: workout.calories,
                totalDistance: workout.distance,
                metadata: workout.metadata
            )
            print("✅ Workout saved to HealthKit")
        } catch {
            print("❌ Failed to save workout to HealthKit: \(error)")
        }
    }
    
    // MARK: - Formatting Helpers
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
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d:%02d per km", minutes, seconds)
    }
    
    private func formatSpeed(_ speed: Double) -> String {
        let kmh = speed * 3.6
        return String(format: "%.1f km/h", kmh)
    }
}

// MARK: - CLLocationManagerDelegate
extension WorkoutManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, workoutState == .active else { return }
        
        currentLocation = location
        
        // Filter out inaccurate locations
        guard location.horizontalAccuracy < 50 && location.horizontalAccuracy > 0 else { return }
        
        // Add to route
        routeLocations.append(location)
        
        // Calculate distance
        if let lastLocation = routeLocations.dropLast().last {
            let segmentDistance = location.distance(from: lastLocation)
            totalDistance += segmentDistance
        }
        
        lastLocationUpdate = Date()
        
        print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateLocationPermissionStatus()
        print("📍 Location authorization changed: \(status.rawValue)")
    }
}
