//
//  NotificationSettingsView.swift
//  FitLifeAdvisorApp
//
//  Created by sewmini010 on 2025-09-09.
//

import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var workoutReminders = false
    @State private var mealReminders = false
    @State private var weightReminders = false
    @State private var goalAchievements = true
    @State private var motivationalMessages = true
    @State private var weeklyProgress = true
    @State private var mealPlanUpdates = false
    @State private var socialUpdates = false
    @State private var systemUpdates = true
    @State private var emailNotifications = true
    @State private var pushNotifications = true
    @State private var badgeCount = true
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var quietHoursEnabled = false
    @State private var quietStartTime = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    @State private var quietEndTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    @State private var showPermissionAlert = false
    @State private var customNotificationText = ""
    @State private var showCustomNotification = false
    
    var body: some View {
        NavigationView {
            Form {
                // Permission Status Section
                Section(header: Text("Permission Status")) {
                    HStack {
                        Image(systemName: notificationManager.permissionGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(notificationManager.permissionGranted ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Notifications")
                                .font(.body)
                            Text(notificationManager.permissionGranted ? "Enabled" : "Disabled")
                                .font(.caption)
                                .foregroundColor(notificationManager.permissionGranted ? .green : .red)
                        }
                        
                        Spacer()
                        
                        if !notificationManager.permissionGranted {
                            Button("Enable") {
                                Task {
                                    let granted = await notificationManager.requestNotificationPermission()
                                    if granted {
                                        notificationManager.setupNotificationCategories()
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                }
                
                // Main Notification Types
                Section(header: Text("Notification Types")) {
                    NotificationToggleRow(
                        icon: "bell.fill",
                        title: "Push Notifications",
                        subtitle: "Receive notifications on this device",
                        isOn: $pushNotifications,
                        color: .blue
                    )
                    
                    NotificationToggleRow(
                        icon: "envelope.fill",
                        title: "Email Notifications",
                        subtitle: "Receive notifications via email",
                        isOn: $emailNotifications,
                        color: .green
                    )
                    
                    NotificationToggleRow(
                        icon: "app.badge.fill",
                        title: "Badge Count",
                        subtitle: "Show notification count on app icon",
                        isOn: $badgeCount,
                        color: .red
                    )
                }
                
                // Fitness Reminders
                Section(header: Text("Fitness & Health Reminders")) {
                    NotificationToggleRow(
                        icon: "figure.run",
                        title: "Workout Reminders",
                        subtitle: "Daily workout notifications",
                        isOn: $workoutReminders,
                        color: .orange
                    ) {
                        if workoutReminders && notificationManager.permissionGranted {
                            notificationManager.scheduleWorkoutReminder()
                        } else {
                            notificationManager.removeNotification(withIdentifier: "workout_reminder")
                        }
                    }
                    
                    NotificationToggleRow(
                        icon: "fork.knife",
                        title: "Meal Reminders",
                        subtitle: "Meal logging and planning reminders",
                        isOn: $mealReminders,
                        color: .green
                    ) {
                        if mealReminders && notificationManager.permissionGranted {
                            notificationManager.scheduleMealReminder()
                        } else {
                            notificationManager.removeNotification(withIdentifier: "meal_reminder")
                        }
                    }
                    
                    NotificationToggleRow(
                        icon: "scalemass.fill",
                        title: "Weight Tracking",
                        subtitle: "Weekly weight check-in reminders",
                        isOn: $weightReminders,
                        color: .purple
                    ) {
                        if weightReminders && notificationManager.permissionGranted {
                            notificationManager.scheduleWeightTrackingReminder()
                        } else {
                            notificationManager.removeNotification(withIdentifier: "weight_reminder")
                        }
                    }
                    
                    NotificationToggleRow(
                        icon: "target",
                        title: "Goal Achievements",
                        subtitle: "Celebrate your milestones",
                        isOn: $goalAchievements,
                        color: .blue
                    )
                }
                
                // Content & Updates
                Section(header: Text("Content & Updates")) {
                    NotificationToggleRow(
                        icon: "heart.fill",
                        title: "Motivational Messages",
                        subtitle: "Daily inspiration and tips",
                        isOn: $motivationalMessages,
                        color: .pink
                    )
                    
                    NotificationToggleRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Weekly Progress",
                        subtitle: "Your weekly fitness summary",
                        isOn: $weeklyProgress,
                        color: .blue
                    )
                    
                    NotificationToggleRow(
                        icon: "list.clipboard.fill",
                        title: "Meal Plan Updates",
                        subtitle: "New meal plans and recipes",
                        isOn: $mealPlanUpdates,
                        color: .green
                    )
                    
                    NotificationToggleRow(
                        icon: "person.2.fill",
                        title: "Social Updates",
                        subtitle: "Friend activities and challenges",
                        isOn: $socialUpdates,
                        color: .orange
                    )
                    
                    NotificationToggleRow(
                        icon: "gear",
                        title: "System Updates",
                        subtitle: "App updates and maintenance",
                        isOn: $systemUpdates,
                        color: .gray
                    )
                }
                
                // Notification Preferences
                Section(header: Text("Notification Preferences")) {
                    NotificationToggleRow(
                        icon: "speaker.wave.3.fill",
                        title: "Sound",
                        subtitle: "Play sound with notifications",
                        isOn: $soundEnabled,
                        color: .blue
                    )
                    
                    NotificationToggleRow(
                        icon: "iphone.radiowaves.left.and.right",
                        title: "Vibration",
                        subtitle: "Vibrate when notifications arrive",
                        isOn: $vibrationEnabled,
                        color: .blue
                    )
                    
                    Toggle("Quiet Hours", isOn: $quietHoursEnabled)
                    
                    if quietHoursEnabled {
                        HStack {
                            Text("From")
                            Spacer()
                            DatePicker("Start Time", selection: $quietStartTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        
                        HStack {
                            Text("To")
                            Spacer()
                            DatePicker("End Time", selection: $quietEndTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                }
                
                // Quick Actions Section
                Section(header: Text("Quick Actions")) {
                    Button(action: {
                        notificationManager.scheduleCustomNotification(
                            title: "🧪 Test Notification",
                            body: "This is a test notification from FitLife Advisor!",
                            timeInterval: 2
                        )
                    }) {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(.blue)
                            Text("Send Test Notification")
                            Spacer()
                        }
                    }
                    .disabled(!notificationManager.permissionGranted)
                    
                    Button(action: {
                        showCustomNotification = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Schedule Custom Notification")
                            Spacer()
                        }
                    }
                    .disabled(!notificationManager.permissionGranted)
                    
                    Button(action: {
                        notificationManager.removeAllPendingNotifications()
                        notificationManager.clearAllDeliveredNotifications()
                        notificationManager.clearBadge()
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                            Text("Clear All Notifications")
                            Spacer()
                        }
                    }
                }
                
                // Statistics Section
                Section(header: Text("Statistics & History")) {
                    NavigationLink(destination: NotificationHistoryView()) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text("Notification History")
                            Spacer()
                        }
                    }
                    
                    HStack {
                        Image(systemName: "number.circle.fill")
                            .foregroundColor(.red)
                        Text("Badge Count")
                        Spacer()
                        Text("\(UIApplication.shared.applicationIconBadgeNumber)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadSettings()
                notificationManager.checkNotificationPermission()
            }
            .onChange(of: pushNotifications) { _ in saveSettings() }
            .onChange(of: emailNotifications) { _ in saveSettings() }
            .onChange(of: badgeCount) { _ in saveSettings() }
            .onChange(of: motivationalMessages) { _ in saveSettings() }
            .onChange(of: weeklyProgress) { _ in saveSettings() }
            .onChange(of: mealPlanUpdates) { _ in saveSettings() }
            .onChange(of: socialUpdates) { _ in saveSettings() }
            .onChange(of: systemUpdates) { _ in saveSettings() }
            .onChange(of: soundEnabled) { _ in saveSettings() }
            .onChange(of: vibrationEnabled) { _ in saveSettings() }
            .onChange(of: quietHoursEnabled) { _ in saveSettings() }
            .sheet(isPresented: $showCustomNotification) {
                CustomNotificationView()
            }
        }
    }
    
    private func loadSettings() {
        workoutReminders = UserDefaults.standard.bool(forKey: "workout_reminders")
        mealReminders = UserDefaults.standard.bool(forKey: "meal_reminders")
        weightReminders = UserDefaults.standard.bool(forKey: "weight_reminders")
        goalAchievements = UserDefaults.standard.bool(forKey: "goal_achievements")
        motivationalMessages = UserDefaults.standard.bool(forKey: "motivational_messages")
        weeklyProgress = UserDefaults.standard.bool(forKey: "weekly_progress")
        mealPlanUpdates = UserDefaults.standard.bool(forKey: "meal_plan_updates")
        socialUpdates = UserDefaults.standard.bool(forKey: "social_updates")
        systemUpdates = UserDefaults.standard.bool(forKey: "system_updates")
        emailNotifications = UserDefaults.standard.bool(forKey: "email_notifications")
        pushNotifications = UserDefaults.standard.bool(forKey: "push_notifications")
        badgeCount = UserDefaults.standard.bool(forKey: "badge_count")
        soundEnabled = UserDefaults.standard.bool(forKey: "sound_enabled")
        vibrationEnabled = UserDefaults.standard.bool(forKey: "vibration_enabled")
        quietHoursEnabled = UserDefaults.standard.bool(forKey: "quiet_hours_enabled")
        
        // Set defaults if first time
        if !UserDefaults.standard.bool(forKey: "settings_initialized") {
            goalAchievements = true
            motivationalMessages = true
            weeklyProgress = true
            systemUpdates = true
            emailNotifications = true
            pushNotifications = true
            badgeCount = true
            soundEnabled = true
            vibrationEnabled = true
            UserDefaults.standard.set(true, forKey: "settings_initialized")
            saveSettings()
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(workoutReminders, forKey: "workout_reminders")
        UserDefaults.standard.set(mealReminders, forKey: "meal_reminders")
        UserDefaults.standard.set(weightReminders, forKey: "weight_reminders")
        UserDefaults.standard.set(goalAchievements, forKey: "goal_achievements")
        UserDefaults.standard.set(motivationalMessages, forKey: "motivational_messages")
        UserDefaults.standard.set(weeklyProgress, forKey: "weekly_progress")
        UserDefaults.standard.set(mealPlanUpdates, forKey: "meal_plan_updates")
        UserDefaults.standard.set(socialUpdates, forKey: "social_updates")
        UserDefaults.standard.set(systemUpdates, forKey: "system_updates")
        UserDefaults.standard.set(emailNotifications, forKey: "email_notifications")
        UserDefaults.standard.set(pushNotifications, forKey: "push_notifications")
        UserDefaults.standard.set(badgeCount, forKey: "badge_count")
        UserDefaults.standard.set(soundEnabled, forKey: "sound_enabled")
        UserDefaults.standard.set(vibrationEnabled, forKey: "vibration_enabled")
        UserDefaults.standard.set(quietHoursEnabled, forKey: "quiet_hours_enabled")
    }
}

// MARK: - Supporting Views
struct NotificationToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let color: Color
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .onChange(of: isOn) { _ in
                    action?()
                }
        }
        .padding(.vertical, 2)
    }
}

struct CustomNotificationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var message = ""
    @State private var selectedTime: Date = Date().addingTimeInterval(60)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notification Details")) {
                    TextField("Title", text: $title)
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $message)
                            .frame(minHeight: 80)
                        if message.isEmpty {
                            Text("Message")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }
                    }
                }
                
                Section(header: Text("Schedule")) {
                    DatePicker("Delivery Time", selection: $selectedTime, in: Date()...)
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                Section {
                    Button("Schedule Notification") {
                        let timeInterval = selectedTime.timeIntervalSinceNow
                        NotificationManager.shared.scheduleCustomNotification(
                            title: title,
                            body: message,
                            timeInterval: timeInterval
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || message.isEmpty)
                }
            }
            .navigationTitle("Custom Notification")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: 
                Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
}

struct NotificationHistoryView: View {
    @State private var pendingNotifications: [UNNotificationRequest] = []
    @State private var deliveredNotifications: [UNNotification] = []
    
    var body: some View {
        List {
            Section(header: Text("Pending Notifications (\(pendingNotifications.count))")) {
                if pendingNotifications.isEmpty {
                    Text("No pending notifications")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(pendingNotifications, id: \.identifier) { notification in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(notification.content.title)
                                .font(.headline)
                            Text(notification.content.body)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
                                Text("Scheduled: \(formatTrigger(trigger))")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                NotificationManager.shared.removeNotification(withIdentifier: notification.identifier)
                                loadNotifications()
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Recent Notifications (\(deliveredNotifications.count))")) {
                if deliveredNotifications.isEmpty {
                    Text("No recent notifications")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(deliveredNotifications, id: \.request.identifier) { notification in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(notification.request.content.title)
                                .font(.headline)
                            Text(notification.request.content.body)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Delivered: \(notification.date, formatter: dateFormatter)")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        .navigationTitle("Notification History")
        .onAppear {
            loadNotifications()
        }
        .refreshable {
            loadNotifications()
        }
    }
    
    private func loadNotifications() {
        Task {
            let pending = await NotificationManager.shared.getPendingNotifications()
            let delivered = await NotificationManager.shared.getDeliveredNotifications()
            
            await MainActor.run {
                self.pendingNotifications = pending
                self.deliveredNotifications = delivered
            }
        }
    }
    
    private func formatTrigger(_ trigger: UNCalendarNotificationTrigger) -> String {
        let components = trigger.dateComponents
        if let hour = components.hour, let minute = components.minute {
            return String(format: "%02d:%02d", hour, minute)
        }
        return "Unknown"
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    NotificationSettingsView()
}
