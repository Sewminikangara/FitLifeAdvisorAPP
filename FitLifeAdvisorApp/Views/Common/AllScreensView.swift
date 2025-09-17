//
//  AllScreensView.swift
//  FitLifeAdvisorApp
//
//  Central index to navigate to major app screens for QA/demo.
//

import SwiftUI

struct AllScreensView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Dashboard")) {
                    NavigationLink("Luxury Dashboard", destination: LuxuryDashboardView())
                    NavigationLink("Modern Dashboard", destination: ModernDashboardView())
                }
                
                Section(header: Text("Planning")) {
                    NavigationLink("Smart Planning", destination: LuxuryPlanView())
                    NavigationLink("Shopping List (Empty Demo)", destination: ShoppingListView(list: ShoppingList(items: [])))
                }
                
                Section(header: Text("Camera & Meals")) {
                    NavigationLink("Smart Camera", destination: MealCameraView())
                    NavigationLink("Meal Analysis", destination: MealAnalysisView())
                    NavigationLink("Meal Photo Analysis", destination: MealPhotoAnalysisView())
                }
                
                Section(header: Text("Profile")) {
                    NavigationLink("Luxury Profile", destination: LuxuryProfileView())
                    NavigationLink("Settings (Modern)", destination: ModernSettingsView())
                    NavigationLink("Notification Settings", destination: NotificationSettingsView())
                    NavigationLink("Help & Support", destination: HelpSupportView())
                    NavigationLink("Privacy & Security", destination: PrivacySecurityView())
                    NavigationLink("Goals & Preferences", destination: GoalsPreferencesView())
                }
                
                Section(header: Text("Workouts & Map")) {
                    NavigationLink("Workouts", destination: ProductionWorkoutView())
                    NavigationLink("Healthy Places Map", destination: HealthyStoreMapView())
                }
            }
            .navigationTitle("All Screens")
        }
    }
}

#Preview {
    AllScreensView()
}
