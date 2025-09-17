//
//  EmailService.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.
//

import Foundation
import MessageUI

class EmailService: NSObject, ObservableObject {
    static let shared = EmailService()
    
    @Published var canSendMail = false
    
    override init() {
        super.init()
        canSendMail = MFMailComposeViewController.canSendMail()
    }
    
    // MARK: - Password Reset Email
    
    func sendPasswordResetEmail(to email: String, completion: @escaping (Result<Void, EmailError>) -> Void) {
        // Validate email format
        guard isValidEmail(email) else {
            completion(.failure(.invalidEmail))
            return
        }
        
        // Try Firebase first if available, otherwise use enhanced simulation
        if FirebaseEmailService.shared.isConfigured {
            print("🔥 Using Firebase for REAL email sending")
            FirebaseEmailService.shared.sendRealPasswordResetEmail(to: email, completion: completion)
        } else {
            print("� Using enhanced email simulation (Firebase not configured)")
            print("� For your email sewminikangara1@gmail.com: Check Xcode console for detailed email info")
            
            // Use enhanced simulation with realistic email details
            SimpleEmailService.shared.sendPasswordResetEmailDemo(to: email, completion: completion)
        }
    }
    
    // MARK: - Email Validation
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Simulated Backend API Call
    
    private func simulatePasswordResetAPI(email: String, completion: @escaping (Result<Void, EmailError>) -> Void) {
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            // Simulate different scenarios
            let scenarios = ["success", "success", "success", "userNotFound"] // 75% success rate
            let randomScenario = scenarios.randomElement() ?? "success"
            
            switch randomScenario {
            case "success":
                // Log the email that would be sent (for testing)
                print("📧 Password reset email would be sent to: \(email)")
                print("🔗 Reset link: https://fitlifeadvisor.com/reset-password?token=\(self.generateResetToken())")
                completion(.success(()))
                
            case "userNotFound":
                completion(.failure(.userNotFound))
                
            default:
                completion(.failure(.networkError))
            }
        }
    }
    
    private func generateResetToken() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    }
    
    // MARK: - Production Integration Examples
    
    /*
    // Example: Firebase Auth Password Reset
    func sendFirebasePasswordReset(email: String, completion: @escaping (Result<Void, EmailError>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(.firebaseError(error.localizedDescription)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Example: SendGrid API Integration
    func sendPasswordResetWithSendGrid(email: String, completion: @escaping (Result<Void, EmailError>) -> Void) {
        let url = URL(string: "https://api.sendgrid.com/v3/mail/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer YOUR_SENDGRID_API_KEY", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let resetToken = generateResetToken()
        let resetLink = "https://yourapp.com/reset-password?token=\(resetToken)"
        
        let emailData: [String: Any] = [
            "personalizations": [
                [
                    "to": [["email": email]],
                    "dynamic_template_data": [
                        "reset_link": resetLink,
                        "user_email": email
                    ]
                ]
            ],
            "from": ["email": "noreply@fitlifeadvisor.com", "name": "FitLife Advisor"],
            "template_id": "YOUR_SENDGRID_TEMPLATE_ID"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: emailData)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(.networkError))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 202 {
                        completion(.success(()))
                    } else {
                        completion(.failure(.apiError("SendGrid API error: \(httpResponse.statusCode)")))
                    }
                }
            }.resume()
        } catch {
            completion(.failure(.networkError))
        }
    }
    
    // Example: Custom Backend API
    func sendPasswordResetWithBackend(email: String, completion: @escaping (Result<Void, EmailError>) -> Void) {
        guard let url = URL(string: "https://your-backend.com/api/auth/forgot-password") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["email": email]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(.networkError))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        completion(.success(()))
                    case 404:
                        completion(.failure(.userNotFound))
                    default:
                        completion(.failure(.apiError("Backend error: \(httpResponse.statusCode)")))
                    }
                }
            }.resume()
        } catch {
            completion(.failure(.networkError))
        }
    }
    */
}

// MARK: - Email Errors

enum EmailError: LocalizedError {
    case invalidEmail
    case userNotFound
    case networkError
    case apiError(String)
    case firebaseError(String)
    case invalidURL
    case cannotSendMail
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .userNotFound:
            return "No account found with this email address"
        case .networkError:
            return "Network error. Please check your connection and try again"
        case .apiError(let message):
            return "Service error: \(message)"
        case .firebaseError(let message):
            return "Authentication error: \(message)"
        case .invalidURL:
            return "Invalid service URL"
        case .cannotSendMail:
            return "Mail services are not available on this device"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidEmail:
            return "Make sure your email address is in the correct format (e.g., user@example.com)"
        case .userNotFound:
            return "Double-check your email address or create a new account"
        case .networkError:
            return "Check your internet connection and try again"
        case .apiError, .firebaseError, .invalidURL:
            return "Please try again later or contact support if the problem persists"
        case .cannotSendMail:
            return "Please set up Mail on your device or use the web version"
        }
    }
}
