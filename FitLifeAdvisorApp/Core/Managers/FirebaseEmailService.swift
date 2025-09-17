//
//  FirebaseEmailService.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.
//

import Foundation

// Conditional Firebase imports - only if Firebase SDK is available
#if canImport(Firebase)
import Firebase
#endif

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

class FirebaseEmailService: NSObject, ObservableObject {
    static let shared = FirebaseEmailService()
    
    @Published var isConfigured = false
    
    override init() {
        super.init()
        checkFirebaseConfiguration()
    }
    
    private func checkFirebaseConfiguration() {
        #if canImport(Firebase)
        // Check if Firebase is configured
        if FirebaseApp.app() != nil {
            isConfigured = true
            print("✅ Firebase is configured and ready for real emails")
        } else {
            isConfigured = false
            print("⚠️ Firebase not configured - using simulation mode")
        }
        #else
        isConfigured = false
        print("📦 Firebase SDK not installed - using simulation mode")
        print("💡 To enable real emails: Add Firebase SDK via Swift Package Manager")
        #endif
    }
    
    // MARK: - Real Firebase Password Reset
    
    func sendRealPasswordResetEmail(to email: String, completion: @escaping (Result<Void, EmailError>) -> Void) {
        guard isConfigured else {
            print("⚠️ Firebase not configured, falling back to simulation")
            // Fall back to simulation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion(.failure(.firebaseError("Firebase SDK not installed. Add Firebase SDK to enable real emails.")))
            }
            return
        }
        
        #if canImport(FirebaseAuth)
        print("🔥 Sending REAL password reset email via Firebase to: \(email)")
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Firebase email error: \(error.localizedDescription)")
                    
                    // Handle specific Firebase errors
                    if let authError = error as NSError? {
                        switch authError.code {
                        case AuthErrorCode.userNotFound.rawValue:
                            completion(.failure(.userNotFound))
                        case AuthErrorCode.invalidEmail.rawValue:
                            completion(.failure(.invalidEmail))
                        case AuthErrorCode.networkError.rawValue:
                            completion(.failure(.networkError))
                        default:
                            completion(.failure(.firebaseError(error.localizedDescription)))
                        }
                    } else {
                        completion(.failure(.firebaseError(error.localizedDescription)))
                    }
                } else {
                    print("✅ REAL password reset email sent successfully to: \(email)")
                    print("📧 User should receive email at: \(email)")
                    completion(.success(()))
                }
            }
        }
        #else
        completion(.failure(.firebaseError("Firebase SDK not available")))
        #endif
    }
    
    // MARK: - Setup Instructions
    
    func getSetupInstructions() -> [String] {
        return [
            "1. Go to https://console.firebase.google.com",
            "2. Create a new project or select existing",
            "3. Add iOS app with your bundle ID",
            "4. Download GoogleService-Info.plist",
            "5. Add it to your Xcode project",
            "6. Enable Authentication > Email/Password",
            "7. Add Firebase SDK to your project",
            "8. Initialize Firebase in your app"
        ]
    }
}

// MARK: - Quick Firebase Setup Extension

extension FirebaseEmailService {
    
    // Test if we can send real emails
    func testRealEmailCapability(completion: @escaping (Bool, String) -> Void) {
        #if canImport(FirebaseAuth)
        if isConfigured {
            // Try a test with a non-existent email to see if Firebase responds
            Auth.auth().sendPasswordReset(withEmail: "test-nonexistent@example.com") { error in
                if let error = error {
                    let message = error.localizedDescription
                    if message.contains("user-not-found") {
                        completion(true, "✅ Firebase is working! (user-not-found is expected)")
                    } else {
                        completion(false, "❌ Firebase error: \(message)")
                    }
                } else {
                    completion(true, "✅ Firebase is working!")
                }
            }
        } else {
            completion(false, "❌ Firebase not configured")
        }
        #else
        completion(false, "❌ Firebase SDK not installed. Add Firebase SDK via Swift Package Manager to enable real emails.")
        #endif
    }
}
