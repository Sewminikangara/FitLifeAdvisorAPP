//
//  AppSettings.swift
//  FitLifeAdvisorApp
//
//  App-wide settings management including dark mode
//

import SwiftUI
import Combine

enum AppColorScheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@MainActor
class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    // MARK: - Published Properties
    @Published var colorScheme: AppColorScheme {
        didSet {
            saveColorScheme()
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")
        }
    }
    
    @Published var biometricEnabled: Bool {
        didSet {
            UserDefaults.standard.set(biometricEnabled, forKey: "biometric_enabled")
            // Also sync with AuthenticationManager's key for backward compatibility
            UserDefaults.standard.set(biometricEnabled, forKey: "biometric_authentication_enabled")
        }
    }
    
    @Published var analyticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(analyticsEnabled, forKey: "analytics_enabled")
        }
    }
    
    // MARK: - Computed Properties
    var isDarkMode: Bool {
        get { colorScheme == .dark }
        set { colorScheme = newValue ? .dark : .light }
    }
    
    // MARK: - Initialization
    private init() {
        // Load saved color scheme
        let savedScheme = UserDefaults.standard.string(forKey: "app_color_scheme") ?? AppColorScheme.system.rawValue
        self.colorScheme = AppColorScheme(rawValue: savedScheme) ?? .system
        
        // Load other settings with defaults
        self.notificationsEnabled = UserDefaults.standard.object(forKey: "notifications_enabled") != nil ? 
                                   UserDefaults.standard.bool(forKey: "notifications_enabled") : true
        
        // Sync with existing biometric setting if available
        self.biometricEnabled = UserDefaults.standard.bool(forKey: "biometric_authentication_enabled") ||
                               UserDefaults.standard.bool(forKey: "biometric_enabled")
        
        self.analyticsEnabled = UserDefaults.standard.object(forKey: "analytics_enabled") != nil ? 
                               UserDefaults.standard.bool(forKey: "analytics_enabled") : true
    }
    
    // MARK: - Private Methods
    private func saveColorScheme() {
        UserDefaults.standard.set(colorScheme.rawValue, forKey: "app_color_scheme")
    }
    
    // MARK: - Public Methods
    func resetToDefaults() {
        colorScheme = .system
        notificationsEnabled = true
        biometricEnabled = false
        analyticsEnabled = true
    }
}