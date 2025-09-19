import LocalAuthentication
import Foundation

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authenticationError: String?
    @Published var errorMessage: String = ""
    @Published var isLoading = false
    @Published var user: User?
    @Published var showBiometricSetupAlert = false
    
    // Computed property for compatibility with existing views
    var currentUser: User? {
        return user
    }
    
    private let context = LAContext()
    
    init() {
        // Check if user was previously authenticated and has biometric enabled
        if UserDefaults.standard.bool(forKey: "biometricEnabled") && 
           UserDefaults.standard.bool(forKey: "wasAuthenticated") {
            // Auto-authenticate with biometrics on app launch
            authenticateWithBiometrics()
        }
    }
    
    // Traditional Authentication Methods
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        // Simulate network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Simple validation for demo - replace with real authentication
            if email.contains("@") && password.count >= 6 {
                self.isAuthenticated = true
                self.user = User(email: email, name: "User")
                UserDefaults.standard.set(true, forKey: "wasAuthenticated")
                UserDefaults.standard.set(email, forKey: "userEmail")
                
                // Ask to enable biometric authentication after successful login
                self.promptBiometricSetup()
            } else {
                self.errorMessage = "Invalid email or password"
            }
            self.isLoading = false
        }
    }
    
    func signUp(email: String, password: String, name: String) {
        isLoading = true
        errorMessage = ""
        
        // Simulate network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Simple validation for demo - replace with real authentication
            if email.contains("@") && password.count >= 6 && !name.isEmpty {
                self.isAuthenticated = true
                self.user = User(email: email, name: name)
                UserDefaults.standard.set(true, forKey: "wasAuthenticated")
                UserDefaults.standard.set(email, forKey: "userEmail")
                UserDefaults.standard.set(name, forKey: "userName")
                
                // Ask to enable biometric authentication after successful signup
                self.promptBiometricSetup()
            } else {
                self.errorMessage = "Please check your information and try again"
            }
            self.isLoading = false
        }
    }
    
    // Overloaded method to match LuxuryRegisterView call signature
    func signUp(fullName: String, email: String, password: String) {
        signUp(email: email, password: password, name: fullName)
    }
    
    // Biometric Authentication Methods
    
    func checkBiometricAvailability() -> BiometricType {
        var error: NSError?
        
        // First check if device supports biometric authentication
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            return .none
        }
        
        // Check what type of biometric authentication is available
        switch context.biometryType {
        case .faceID:
            print("Face ID is available")
            return .faceID
        case .touchID:
            print("Touch ID is available") 
            return .touchID
        case .opticID:
            print("Optic ID is available")
            return .faceID // Treat Optic ID like Face ID for UI purposes
        default:
            print("No biometric authentication available")
            return .none
        }
    }
    
    func authenticateWithBiometrics() {
        guard checkBiometricAvailability() != .none else {
            authenticationError = "Biometric authentication not available"
            return
        }
        
        let reason = "Authenticate to access FitLife Advisor"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthenticated = true
                    self?.authenticationError = nil
                    self?.loadUserFromStorage()
                } else {
                    // Handle specific error cases
                    if let error = error as? LAError {
                        switch error.code {
                        case .biometryNotAvailable:
                            self?.authenticationError = "Biometric authentication is not available on this device"
                        case .biometryNotEnrolled:
                            self?.authenticationError = "No biometric authentication is set up on this device"
                        case .biometryLockout:
                            self?.authenticationError = "Biometric authentication is locked. Please try again later"
                        case .userCancel:
                            self?.authenticationError = "Authentication was cancelled"
                        case .userFallback:
                            self?.authenticationError = "User chose to use fallback authentication"
                        default:
                            self?.authenticationError = error.localizedDescription
                        }
                    } else {
                        self?.authenticationError = error?.localizedDescription ?? "Authentication failed"
                    }
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    func authenticateWithPasscode() {
        let reason = "Authenticate to access FitLife Advisor"
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthenticated = true
                    self?.authenticationError = nil
                    self?.loadUserFromStorage()
                } else {
                    self?.authenticationError = error?.localizedDescription ?? "Authentication failed"
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    func enableBiometricAuthentication() {
        let biometricType = checkBiometricAvailability()
        if biometricType != .none {
            UserDefaults.standard.set(true, forKey: "biometricEnabled")
            print("Biometric authentication enabled: \(biometricType)")
        } else {
            print("Cannot enable biometric authentication - not available")
        }
    }
    
    func disableBiometricAuthentication() {
        UserDefaults.standard.set(false, forKey: "biometricEnabled")
        print("Biometric authentication disabled")
    }
    
    var isBiometricEnabled: Bool {
        let enabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
        let available = checkBiometricAvailability() != .none
        print("Biometric enabled: \(enabled), available: \(available)")
        return enabled && available
    }
    
    // Helper Methods
    
    private func loadUserFromStorage() {
        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            let name = UserDefaults.standard.string(forKey: "userName") ?? "User"
            self.user = User(email: email, name: name)
        }
    }
    
    private func promptBiometricSetup() {
        // Show alert asking user if they want to enable biometric authentication
        if checkBiometricAvailability() != .none && !isBiometricEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showBiometricSetupAlert = true
            }
        }
    }
    
    func confirmBiometricSetup() {
        print("User confirmed biometric setup")
        enableBiometricAuthentication()
        showBiometricSetupAlert = false
        
        // Test biometric authentication immediately
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("Testing biometric authentication...")
            self.authenticateWithBiometrics()
        }
    }
    
    func skipBiometricSetup() {
        print("User skipped biometric setup")
        showBiometricSetupAlert = false
    }
    
    func logout() {
        isAuthenticated = false
        authenticationError = nil
        errorMessage = ""
        user = nil
        UserDefaults.standard.set(false, forKey: "wasAuthenticated")
    }
    
    // Alias for logout to match ProfileView usage
    func signOut() {
        logout()
    }
}

enum BiometricType {
    case faceID
    case touchID
    case none
}