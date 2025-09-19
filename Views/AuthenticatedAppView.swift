import SwiftUI

struct AuthenticatedAppView: View {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
                    .environmentObject(authManager)
            } else {
                WelcomeView()
                    .environmentObject(authManager)
            }
        }
        .onAppear {
            // Check if user was previously authenticated
            if UserDefaults.standard.bool(forKey: "wasAuthenticated") {
                authManager.authenticateWithBiometrics()
            }
        }
        .onChange(of: authManager.isAuthenticated) { authenticated in
            UserDefaults.standard.set(authenticated, forKey: "wasAuthenticated")
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            // Add more tabs as needed
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            List {
                Section("Security") {
                    Button("Sign Out") {
                        authManager.logout()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}