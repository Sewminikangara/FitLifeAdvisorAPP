//
//  SimpleEmailService.swift
//  FitLifeAdvisorApp
//
//  Simple email service using native iOS Mail functionality (for demonstration)
//

import Foundation
import MessageUI

class SimpleEmailService: NSObject, ObservableObject {
    static let shared = SimpleEmailService()
    
    @Published var canSendMail = false
    
    override init() {
        super.init()
        canSendMail = MFMailComposeViewController.canSendMail()
        print("📧 Mail capability: \(canSendMail ? "Available" : "Not available")")
    }
    
    // MARK: - Simple Email Demo
    
    func sendPasswordResetEmailDemo(to email: String, completion: @escaping (Result<Void, EmailError>) -> Void) {
        print("📧 Demo: Sending password reset email to \(email)")
        
        // Simulate realistic email sending process
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            // Validate email
            guard self.isValidEmail(email) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidEmail))
                }
                return
            }
            
            // Simulate different outcomes based on email
            let outcome = self.simulateEmailOutcome(for: email)
            
            DispatchQueue.main.async {
                switch outcome {
                case .success:
                    print("✅ SUCCESS: Password reset email sent to \(email)")
                    print("📧 Email Details:")
                    print("   From: noreply@fitlifeadvisor.com")
                    print("   To: \(email)")
                    print("   Subject: Reset Your FitLife Advisor Password")
                    print("   Reset Link: https://fitlifeadvisor.com/reset?token=\(self.generateToken())")
                    print("   🎯 In a real app, this email would be in the user's inbox!")
                    completion(.success(()))
                    
                case .userNotFound:
                    print("⚠️ User not found: \(email)")
                    completion(.failure(.userNotFound))
                    
                case .networkError:
                    print("❌ Network error for: \(email)")
                    completion(.failure(.networkError))
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func generateToken() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(32).lowercased()
    }
    
    private enum EmailOutcome {
        case success
        case userNotFound
        case networkError
    }
    
    private func simulateEmailOutcome(for email: String) -> EmailOutcome {
        // Special handling for your email - always succeed
        if email.lowercased() == "sewminikangara1@gmail.com" {
            return .success
        }
        
        // For other emails, simulate realistic outcomes
        let outcomes: [EmailOutcome] = [.success, .success, .success, .userNotFound] // 75% success rate
        return outcomes.randomElement() ?? .success
    }
    
    // MARK: - Mail Compose (iOS Native)
    
    func composePasswordResetEmail(for email: String) -> MFMailComposeViewController? {
        guard canSendMail else { return nil }
        
        let mailController = MFMailComposeViewController()
        mailController.setSubject("Password Reset Request - FitLife Advisor")
        mailController.setToRecipients([email])
        
        let resetToken = generateToken()
        let resetLink = "https://fitlifeadvisor.com/reset?token=\(resetToken)"
        
        let emailBody = """
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                <div style="text-align: center; margin-bottom: 30px;">
                    <h1 style="color: #4A90E2;">🏃‍♂️ FitLife Advisor</h1>
                </div>
                
                <h2>Reset Your Password</h2>
                
                <p>Hi there,</p>
                
                <p>We received a request to reset your password for your FitLife Advisor account associated with <strong>\(email)</strong>.</p>
                
                <div style="text-align: center; margin: 30px 0;">
                    <a href="\(resetLink)" 
                       style="background-color: #4A90E2; color: white; padding: 15px 30px; text-decoration: none; border-radius: 25px; display: inline-block; font-weight: bold;">
                        Reset My Password
                    </a>
                </div>
                
                <p>Or copy and paste this link into your browser:</p>
                <p style="word-break: break-all; background-color: #f5f5f5; padding: 10px; border-radius: 5px;">
                    \(resetLink)
                </p>
                
                <p><strong>Important:</strong> This link will expire in 24 hours for security reasons.</p>
                
                <p>If you didn't request this password reset, please ignore this email. Your password will remain unchanged.</p>
                
                <hr style="margin: 30px 0; border: none; border-top: 1px solid #eee;">
                
                <p style="font-size: 12px; color: #666;">
                    This email was sent by FitLife Advisor. If you have any questions, please contact our support team.
                </p>
            </div>
        </body>
        </html>
        """
        
        mailController.setMessageBody(emailBody, isHTML: true)
        
        return mailController
    }
}
