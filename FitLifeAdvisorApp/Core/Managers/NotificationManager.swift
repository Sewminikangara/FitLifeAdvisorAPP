//
//  NotificationManager.swift
//  FitLifeAdvisorApp
//
//  Created by AI Assistant on 2025-09-09.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var permissionGranted = false
    @Published var notificationSettings: UNNotificationSettings?
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkNotificationPermission()
    }
    
    // MARK: - Permission Management
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge, .provisional]
            )
            
            await MainActor.run {
                self.permissionGranted = granted
            }
            
            if granted {
                await registerForRemoteNotifications()
            }
            
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationSettings = settings
                self.permissionGranted = settings.authorizationStatus == .authorized || 
                                        settings.authorizationStatus == .provisional
            }
        }
    }
    
    @MainActor
    func registerForRemoteNotifications() async {
        guard permissionGranted else { return }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - Local Notifications
    
    func scheduleWorkoutReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Time for Your Workout! 💪"
        content.body = "Don't forget to log your workout in FitLife Advisor"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "WORKOUT_REMINDER"
        content.userInfo = ["type": "workout_reminder"]
        
        // Schedule for tomorrow at 6 PM
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "workout_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling workout reminder: \(error)")
            } else {
                print("Workout reminder scheduled successfully")
            }
        }
    }
    
    func scheduleMealReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Meal Time! 🍽️"
        content.body = "Remember to log your meal and track your nutrition"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "MEAL_REMINDER"
        content.userInfo = ["type": "meal_reminder"]
        
        // Schedule for daily at 12 PM (lunch time)
        var dateComponents = DateComponents()
        dateComponents.hour = 12
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "meal_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling meal reminder: \(error)")
            } else {
                print("Meal reminder scheduled successfully")
            }
        }
    }
    
    func scheduleWeightTrackingReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Check-in 📊"
        content.body = "Time to log your weight and track your progress!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "WEIGHT_REMINDER"
        content.userInfo = ["type": "weight_reminder"]
        
        // Schedule for every Sunday at 9 AM
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weight_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling weight tracking reminder: \(error)")
            } else {
                print("Weight tracking reminder scheduled successfully")
            }
        }
    }
    
    func scheduleGoalAchievementNotification(goalType: String, progress: Double) {
        guard progress >= 1.0 else { return } // Only notify when goal is achieved
        
        let content = UNMutableNotificationContent()
        content.title = "🎉 Goal Achieved!"
        content.body = "Congratulations! You've reached your \(goalType) goal!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "GOAL_ACHIEVEMENT"
        content.userInfo = ["type": "goal_achievement", "goal": goalType]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "goal_\(goalType)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling goal achievement notification: \(error)")
            } else {
                print("Goal achievement notification scheduled for \(goalType)")
            }
        }
    }
    
    func scheduleCustomNotification(title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "CUSTOM_NOTIFICATION"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(
            identifier: "custom_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling custom notification: \(error)")
            } else {
                print("Custom notification scheduled successfully")
            }
        }
    }
    
    // MARK: - Notification Management
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    func getDeliveredNotifications() async -> [UNNotification] {
        return await UNUserNotificationCenter.current().deliveredNotifications()
    }
    
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func removeNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func clearAllDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    // MARK: - Badge Management
    
    func updateBadgeCount(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
    func clearBadge() {
        updateBadgeCount(0)
    }
    
    // MARK: - Setup Notification Categories
    
    func setupNotificationCategories() {
        let workoutAction = UNNotificationAction(
            identifier: "WORKOUT_ACTION",
            title: "Start Workout",
            options: [.foreground]
        )
        
        let mealAction = UNNotificationAction(
            identifier: "MEAL_ACTION", 
            title: "Log Meal",
            options: [.foreground]
        )
        
        let weightAction = UNNotificationAction(
            identifier: "WEIGHT_ACTION",
            title: "Log Weight",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Remind Later",
            options: []
        )
        
        let workoutCategory = UNNotificationCategory(
            identifier: "WORKOUT_REMINDER",
            actions: [workoutAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        let mealCategory = UNNotificationCategory(
            identifier: "MEAL_REMINDER",
            actions: [mealAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        let weightCategory = UNNotificationCategory(
            identifier: "WEIGHT_REMINDER",
            actions: [weightAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        let goalCategory = UNNotificationCategory(
            identifier: "GOAL_ACHIEVEMENT",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            workoutCategory,
            mealCategory, 
            weightCategory,
            goalCategory
        ])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier
        
        // Handle different notification types and actions
        switch actionIdentifier {
        case "WORKOUT_ACTION":
            handleWorkoutAction(userInfo: userInfo)
        case "MEAL_ACTION":
            handleMealAction(userInfo: userInfo)
        case "WEIGHT_ACTION":
            handleWeightAction(userInfo: userInfo)
        case "SNOOZE_ACTION":
            handleSnoozeAction(userInfo: userInfo)
        case UNNotificationDefaultActionIdentifier:
            handleDefaultAction(userInfo: userInfo)
        default:
            break
        }
        
        completionHandler()
    }
    
    private func handleWorkoutAction(userInfo: [AnyHashable: Any]) {
        // Navigate to workout logging screen
        NotificationCenter.default.post(name: .navigateToWorkout, object: nil, userInfo: userInfo)
    }
    
    private func handleMealAction(userInfo: [AnyHashable: Any]) {
        // Navigate to meal logging screen
        NotificationCenter.default.post(name: .navigateToMealLog, object: nil, userInfo: userInfo)
    }
    
    private func handleWeightAction(userInfo: [AnyHashable: Any]) {
        // Navigate to weight logging screen
        NotificationCenter.default.post(name: .navigateToWeightLog, object: nil, userInfo: userInfo)
    }
    
    private func handleSnoozeAction(userInfo: [AnyHashable: Any]) {
        // Reschedule notification for 1 hour later
        if let notificationType = userInfo["type"] as? String {
            switch notificationType {
            case "workout_reminder":
                scheduleCustomNotification(
                    title: "Workout Reminder ⏰",
                    body: "It's time for your delayed workout!",
                    timeInterval: 3600 // 1 hour
                )
            case "meal_reminder":
                scheduleCustomNotification(
                    title: "Meal Reminder 🍽️",
                    body: "Don't forget to log your meal!",
                    timeInterval: 3600
                )
            default:
                break
            }
        }
    }
    
    private func handleDefaultAction(userInfo: [AnyHashable: Any]) {
        // Handle tap on notification (open app to relevant screen)
        if let notificationType = userInfo["type"] as? String {
            switch notificationType {
            case "workout_reminder":
                NotificationCenter.default.post(name: .navigateToWorkout, object: nil)
            case "meal_reminder":
                NotificationCenter.default.post(name: .navigateToMealLog, object: nil)
            case "weight_reminder":
                NotificationCenter.default.post(name: .navigateToWeightLog, object: nil)
            case "goal_achievement":
                NotificationCenter.default.post(name: .navigateToProgress, object: nil)
            default:
                break
            }
        }
    }
    
    // MARK: - Smart Notification Methods
    func scheduleMotivationalNotification(title: String, body: String, delay: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "MOTIVATION"
        content.userInfo = ["type": "motivation"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let identifier = "motivation_\(Date().timeIntervalSince1970)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling motivational notification: \(error)")
            }
        }
    }
    
    func scheduleStreakCelebrationNotification(streakDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Amazing Streak!"
        content.body = "You're on fire! \(streakDays) days of consistent progress. Keep it going!"
        content.sound = .default
        content.categoryIdentifier = "STREAK_CELEBRATION"
        content.userInfo = ["type": "streak_celebration", "streakDays": streakDays]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "streak_\(streakDays)_\(Date().timeIntervalSince1970)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling streak celebration notification: \(error)")
            }
        }
    }
    
    func scheduleWeeklyProgressSummary() {
        let content = UNMutableNotificationContent()
        content.title = "📊 Weekly Progress Summary"
        content.body = "Check out your weekly achievements and plan for the week ahead!"
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_SUMMARY"
        content.userInfo = ["type": "weekly_summary"]
        
        // Schedule for Sunday at 6 PM
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 18
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = "weekly_summary"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling weekly summary notification: \(error)")
            }
        }
    }
}

// MARK: - Notification Names for Navigation
extension Notification.Name {
    static let navigateToWorkout = Notification.Name("navigateToWorkout")
    static let navigateToMealLog = Notification.Name("navigateToMealLog")
    static let navigateToWeightLog = Notification.Name("navigateToWeightLog")
    static let navigateToProgress = Notification.Name("navigateToProgress")
}
