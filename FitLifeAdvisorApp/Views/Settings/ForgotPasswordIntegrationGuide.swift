//
//  ForgotPasswordIntegrationGuide.swift
//  FitLifeAdvisorApp
//
//  Guide for integrating real email services for password reset functionality
//

import SwiftUI

struct ForgotPasswordIntegrationGuide: View {
    @State private var testEmail = "test@example.com"
    @State private var testResult = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Current Status
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📧 Email Service Status")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            statusRow("Email Service", "✅ Implemented")
                            statusRow("Email Validation", "✅ Working")
                            statusRow("Error Handling", "✅ Complete")
                            statusRow("UI Integration", "✅ Connected")
                            statusRow("Production Ready", "⚠️ Needs Backend")
                        }
                        
                        Text("Currently using simulation mode. To enable real email sending, you need to integrate with one of the services below.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Test Email Service
                    VStack(alignment: .leading, spacing: 15) {
                        Text("🧪 Test Email Service")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            TextField("Enter test email", text: $testEmail)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            Button(action: testEmailService) {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Test")
                                }
                            }
                            .disabled(isLoading || testEmail.isEmpty)
                            .buttonStyle(.bordered)
                        }
                        
                        if !testResult.isEmpty {
                            Text(testResult)
                                .font(.caption)
                                .foregroundColor(testResult.contains("✅") ? .green : .red)
                                .padding(.top, 5)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Production Integration Options
                    VStack(alignment: .leading, spacing: 15) {
                        Text("🚀 Production Integration Options")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Firebase Auth
                        integrationOption(
                            title: "Firebase Authentication",
                            subtitle: "Easiest - Handles everything automatically",
                            steps: [
                                "Add Firebase SDK to your project",
                                "Enable Email/Password authentication",
                                "Replace simulation with Auth.auth().sendPasswordReset()",
                                "Firebase handles email templates and delivery"
                            ],
                            pros: ["Built-in email templates", "No server needed", "Free tier available"],
                            cons: ["Vendor lock-in", "Limited customization"]
                        )
                        
                        // SendGrid
                        integrationOption(
                            title: "SendGrid API",
                            subtitle: "Professional email service",
                            steps: [
                                "Sign up for SendGrid account",
                                "Get API key and verify sender domain",
                                "Create email template for password reset",
                                "Implement SendGrid API calls in EmailService"
                            ],
                            pros: ["Professional deliverability", "Custom templates", "Analytics"],
                            cons: ["Requires API key management", "Paid service"]
                        )
                        
                        // Custom Backend
                        integrationOption(
                            title: "Custom Backend API",
                            subtitle: "Full control with your server",
                            steps: [
                                "Create password reset endpoint on your server",
                                "Generate secure reset tokens",
                                "Send emails via your server (SMTP/SES)",
                                "Update EmailService to call your API"
                            ],
                            pros: ["Full control", "Custom logic", "Your branding"],
                            cons: ["More development work", "Server maintenance"]
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Implementation Code Examples
                    VStack(alignment: .leading, spacing: 15) {
                        Text("💻 Quick Implementation")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Firebase (Uncomment in EmailService.swift)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("The EmailService.swift file already contains example implementations. Just uncomment the method you want to use and add the necessary dependencies.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Current Status: Simulation Mode")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Your forgot password feature works perfectly in simulation mode. Users will see success/error messages, but no actual emails are sent. Check the Xcode console to see what would be sent.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Email Integration")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func statusRow(_ title: String, _ status: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
            Spacer()
            Text(status)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
    
    private func integrationOption(
        title: String,
        subtitle: String,
        steps: [String],
        pros: [String],
        cons: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Steps:")
                    .font(.caption)
                    .fontWeight(.medium)
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    Text("\(index + 1). \(step)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(alignment: .top, spacing: 15) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Pros:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    ForEach(pros, id: \.self) { pro in
                        Text("+ \(pro)")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Cons:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    ForEach(cons, id: \.self) { con in
                        Text("- \(con)")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func testEmailService() {
        isLoading = true
        testResult = ""
        
        EmailService.shared.sendPasswordResetEmail(to: testEmail) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success():
                    testResult = "✅ Email service test successful! Check Xcode console for details."
                case .failure(let error):
                    testResult = "❌ Test failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordIntegrationGuide()
}
