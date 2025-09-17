//
//  NotificationSettingsView.swift
//  FitLifeAdvisorApp
//
//  Created by AI Assistant on 2025-09-09.
//

import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var workoutReminders = false
    @State private var mealReminders = false
    @State private var weightReminders = false
    @State private var goalAchievements = true
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
                        
                        Text("Notifications")
                        
                        Spacer()
                        
                        Text(notificationManager.permissionGranted ? "Enabled" : "Disabled")
                            .foregroundColor(notificationManager.permissionGranted ? .green : .red)
                    }
                    
                    if !notificationManager.permissionGranted {
                        Button("Enable Notifications") {
                            Task {
                                let granted = await notificationManager.requestNotificationPermission()
                                if granted {
                                    notificationManager.setupNotificationCategories()
                                }
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // Reminder Settings Section
                Section(header: Text("Reminder Settings")) {
                    Toggle("Workout Reminders", isOn: $workoutReminders)
                        .onChange(of: workoutReminders) { enabled in
                            if enabled && notificationManager.permissionGranted {
                                notificationManager.scheduleWorkoutReminder()
                            } else {
                                notificationManager.removeNotification(withIdentifier: "workout_reminder")
                            }
                        }
                    
                    Toggle("Meal Reminders", isOn: $mealReminders)
                        .onChange(of: mealReminders) { enabled in
                            if enabled && notificationManager.permissionGranted {
                                notificationManager.scheduleMealReminder()
                            } else {
                                notificationManager.removeNotification(withIdentifier: "meal_reminder")
                            }
                        }
                    
                    Toggle("Weight Tracking", isOn: $weightReminders)
                        .onChange(of: weightReminders) { enabled in
                            if enabled && notificationManager.permissionGranted {
                                notificationManager.scheduleWeightTrackingReminder()
                            } else {
                                notificationManager.removeNotification(withIdentifier: "weight_reminder")
                            }
                        }
                    
                    Toggle("Goal Achievements", isOn: $goalAchievements)
                }
                
                // Quick Actions Section
                Section(header: Text("Quick Actions")) {
                    Button("Test Notification") {
                        notificationManager.scheduleCustomNotification(
                            title: "🧪 Test Notification",
                            body: "This is a test notification from FitLife Advisor!",
                            timeInterval: 2
                        )
                    }
                    .disabled(!notificationManager.permissionGranted)
                    
                    Button("Schedule Custom Notification") {
                        showCustomNotification = true
                    }
                    .disabled(!notificationManager.permissionGranted)
                    
                    Button("Clear All Notifications") {
                        notificationManager.removeAllPendingNotifications()
                        notificationManager.clearAllDeliveredNotifications()
                        notificationManager.clearBadge()
                    }
                    .foregroundColor(.red)
                }
                
                // Statistics Section
                Section(header: Text("Statistics")) {
                    NavigationLink("View Notification History") {
                        NotificationHistoryView()
                    }
                    
                    HStack {
                        Text("Badge Count")
                        Spacer()
                        Text("\(UIApplication.shared.applicationIconBadgeNumber)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Notifications")
            .onAppear {
                loadSettings()
                notificationManager.checkNotificationPermission()
            }
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
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(workoutReminders, forKey: "workout_reminders")
        UserDefaults.standard.set(mealReminders, forKey: "meal_reminders")
        UserDefaults.standard.set(weightReminders, forKey: "weight_reminders")
        UserDefaults.standard.set(goalAchievements, forKey: "goal_achievements")
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
