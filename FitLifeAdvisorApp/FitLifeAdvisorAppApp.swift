//
//  FitLifeAdvisorAppApp.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import SwiftUI

@main
struct FitLifeAdvisorAppApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(authManager)
                } else {
                    // Check if user was previously authenticated and has biometric enabled
                    if UserDefaults.standard.bool(forKey: "wasAuthenticated") && authManager.isBiometricEnabled {
                        LuxuryLoginView()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .environmentObject(authManager)
                    } else if UserDefaults.standard.bool(forKey: "wasAuthenticated") {
                        // Returning user without biometric - show luxury login
                        LuxuryLoginView()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .environmentObject(authManager)
                    } else {
                        // New user - show luxury login with register option
                        LuxuryLoginView()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .environmentObject(authManager)
                    }
                }
            }
            .onAppear {
                // Auto-trigger biometric authentication for returning users
                if UserDefaults.standard.bool(forKey: "wasAuthenticated") && 
                   authManager.isBiometricEnabled && 
                   !authManager.isAuthenticated {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        authManager.authenticateWithBiometrics()
                    }
                }
                
                // Setup notifications when app launches
                setupNotifications()
            }
        }
    }
    
    private func setupNotifications() {
        // Setup notification categories
        notificationManager.setupNotificationCategories()
        
        // Request permission if not already granted
        if !notificationManager.permissionGranted {
            Task {
                await notificationManager.requestNotificationPermission()
            }
        }
    }
}
