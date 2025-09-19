//
//  RealEmailSetupGuide.swift
//  FitLifeAdvisorApp
//
//

import SwiftUI

struct RealEmailSetupGuide: View {
    @State private var currentStep = 0
    @State private var testEmail = "sewminikangara1@gmail.com"
    @State private var testResult = ""
    @State private var isLoading = false
    
    private let setupSteps = [
        SetupStep(
            title: "1. Go to Firebase Console",
            description: "Visit https://console.firebase.google.com and sign in with your Google account",
            action: "Open Console",
            url: "https://console.firebase.google.com",
            details: "Sign in with your Google account, then click 'Create a project'"
        ),
        SetupStep(
            title: "2. Create or Select Project",
            description: "Create a new Firebase project or select an existing one for your app",
            action: "Project Setup",
            details: "Name your project 'FitLifeAdvisor' or similar"
        ),
        SetupStep(
            title: "3. Add iOS App",
            description: "Add an iOS app to your Firebase project with your bundle identifier",
            action: "Add iOS App",
            details: "Bundle ID: com.yourname.FitLifeAdvisorApp"
        ),
        SetupStep(
            title: "4. Download Config File",
            description: "Download GoogleService-Info.plist and add it to your Xcode project",
            action: "Download & Add",
            details: "Drag the file into your Xcode project root"
        ),
        SetupStep(
            title: "5. Enable Authentication",
            description: "In Firebase Console: Authentication → Sign-in method → Email/Password → Enable",
            action: "Enable Auth",
            details: "Turn on both Email/Password and Email link options"
        ),
        SetupStep(
            title: "6. Add Firebase SDK",
            description: "Add Firebase SDK to your Xcode project via Swift Package Manager",
            action: "Add Package",
            details: "URL: https://github.com/firebase/firebase-ios-sdk"
        ),
        SetupStep(
            title: "7. Initialize Firebase",
            description: "Add Firebase.configure() to your app's initialization code",
            action: "Add Code",
            details: "Add 'import Firebase' and 'FirebaseApp.configure()' in init() method"
        ),
        SetupStep(
            title: "8. Test Real Emails",
            description: "Test sending real password reset emails to your address",
            action: "Test Now",
            details: "Emails will be sent to actual inbox!"
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 15) {
                        Text("📧 Enable Real Email Sending")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Currently in simulation mode. Follow these steps to send real emails to sewminikangara1@gmail.com")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Current Status
                        HStack {
                            Circle()
                                .fill(FirebaseEmailService.shared.isConfigured ? Color.green : Color.orange)
                                .frame(width: 12, height: 12)
                            
                            Text(FirebaseEmailService.shared.isConfigured ? "Firebase Configured - Real Emails Enabled" : "Simulation Mode - No Real Emails")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    
                    // Setup Steps
                    VStack(spacing: 16) {
                        ForEach(Array(setupSteps.enumerated()), id: \.offset) { index, step in
                            SetupStepView(
                                step: step,
                                stepNumber: index + 1,
                                isCompleted: index < currentStep,
                                isCurrent: index == currentStep
                            ) {
                                if step.url != nil {
                                    // Open URL
                                    if let url = URL(string: step.url!) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                
                                if index < setupSteps.count - 1 {
                                    withAnimation {
                                        currentStep = min(currentStep + 1, setupSteps.count - 1)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Test Real Email
                    if currentStep >= setupSteps.count - 1 {
                        VStack(spacing: 15) {
                            Text("🧪 Test Real Email Sending")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                TextField("Your email", text: $testEmail)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                
                                Button(action: testRealEmail) {
                                    if isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Send Real Email")
                                    }
                                }
                                .disabled(isLoading)
                                .buttonStyle(.borderedProminent)
                            }
                            
                            if !testResult.isEmpty {
                                Text(testResult)
                                    .font(.caption)
                                    .foregroundColor(testResult.contains("✅") ? .green : .red)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Quick Alternative
                    VStack(alignment: .leading, spacing: 10) {
                        Text("⚡ Quick Alternative")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Don't want to set up Firebase? You can:")
                            .font(.subheadline)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("• Use a third-party service like SendGrid")
                            Text("• Build your own backend API")
                            Text("• Use email services like Mailgun or AWS SES")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Real Email Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func testRealEmail() {
        isLoading = true
        testResult = ""
        
        EmailService.shared.sendPasswordResetEmail(to: testEmail) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success():
                    testResult = "✅ SUCCESS! Check your inbox at \(testEmail)\n\nThe email should arrive within 1-2 minutes."
                case .failure(let error):
                    testResult = "❌ Error: \(error.localizedDescription)\n\nIf Firebase isn't set up, this is expected."
                }
            }
        }
    }
}

struct SetupStep {
    let title: String
    let description: String
    let action: String
    let url: String?
    let details: String?
    
    init(title: String, description: String, action: String, url: String? = nil, details: String? = nil) {
        self.title = title
        self.description = description
        self.action = action
        self.url = url
        self.details = details
    }
}

struct SetupStepView: View {
    let step: SetupStep
    let stepNumber: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Step indicator
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green : (isCurrent ? Color.blue : Color.gray.opacity(0.3)))
                        .frame(width: 30, height: 30)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.caption.weight(.bold))
                    } else {
                        Text("\(stepNumber)")
                            .foregroundColor(isCurrent ? .white : .gray)
                            .font(.caption.weight(.bold))
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(step.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(step.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(step.action) {
                    action()
                }
                .buttonStyle(.bordered)
                .disabled(isCompleted)
            }
            
            if let details = step.details {
                Text(details)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.leading, 40)
            }
        }
        .padding()
        .background(isCurrent ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    RealEmailSetupGuide()
}
