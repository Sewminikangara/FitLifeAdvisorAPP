//
//  FaceIDSimulatorGuide.swift
//  FitLifeAdvisorApp
//
//  Face ID Simulator Setup and Testing Guide
//

import SwiftUI
import LocalAuthentication

struct FaceIDSimulatorGuide: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var testResult = ""
    @State private var showingResults = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "faceid")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Face ID Simulator Setup")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Enable and test Face ID in iOS Simulator")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Setup Instructions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("📱 Simulator Setup Steps")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        setupStep("1", "Open iOS Simulator", "Launch your app in Xcode Simulator")
                        setupStep("2", "Enable Face ID", "Device → Face ID → Enrolled")
                        setupStep("3", "Test Authentication", "Use the buttons below to test")
                        
                        Text("🎭 Testing Face ID")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top)
                        
                        setupStep("✅", "Successful Auth", "Device → Face ID → Matching Face")
                        setupStep("❌", "Failed Auth", "Device → Face ID → Non-matching Face")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Current Status
                    VStack(spacing: 10) {
                        Text("Current Status")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        statusRow("Face ID Available", authManager.checkBiometricAvailability() == .faceID)
                        statusRow("Face ID Enabled", authManager.isBiometricEnabled)
                        statusRow("User Authenticated", authManager.isAuthenticated)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Test Buttons
                    VStack(spacing: 15) {
                        Text("🧪 Test Face ID")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Button(action: testFaceIDAvailability) {
                            HStack {
                                Image(systemName: "checkmark.shield")
                                Text("Check Face ID Availability")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: testFaceIDAuthentication) {
                            HStack {
                                Image(systemName: "faceid")
                                Text("Test Face ID Authentication")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: enableFaceID) {
                            HStack {
                                Image(systemName: "gear")
                                Text("Enable Face ID in App")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    // Test Results
                    if showingResults {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Test Results")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(testResult)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .font(.system(.body, design: .monospaced))
                        }
                        .padding()
                    }
                    
                    // Troubleshooting
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🔧 Troubleshooting")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        troubleshootingItem("Face ID not working?", "Make sure you've enabled it in Device → Face ID → Enrolled")
                        troubleshootingItem("Authentication failing?", "Try Device → Face ID → Matching Face during auth")
                        troubleshootingItem("Button not responding?", "Ensure the simulator window is active and focused")
                        troubleshootingItem("Still not working?", "Restart simulator and re-enable Face ID")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Face ID Testing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func setupStep(_ number: String, _ title: String, _ description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.blue.opacity(0.1)))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private func statusRow(_ title: String, _ status: Bool) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: status ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(status ? .green : .red)
            
            Text(status ? "YES" : "NO")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(status ? .green : .red)
        }
    }
    
    private func troubleshootingItem(_ problem: String, _ solution: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(problem)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(solution)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Test Functions
    
    private func testFaceIDAvailability() {
        let context = LAContext()
        var error: NSError?
        
        var results = "Face ID Availability Test:\n\n"
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            results += "✅ Biometric authentication is available\n"
            
            switch context.biometryType {
            case .faceID:
                results += "✅ Face ID is available\n"
            case .touchID:
                results += "⚠️  Touch ID is available (not Face ID)\n"
            case .opticID:
                results += "✅ Optic ID is available\n"
            default:
                results += "❓ Unknown biometric type\n"
            }
        } else {
            results += "❌ Biometric authentication not available\n"
            results += "Error: \(error?.localizedDescription ?? "Unknown")\n"
            
            if let laError = error as? LAError {
                switch laError.code {
                case .biometryNotAvailable:
                    results += "💡 Solution: Enable Face ID in Simulator (Device → Face ID → Enrolled)\n"
                case .biometryNotEnrolled:
                    results += "💡 Solution: Set up Face ID in iOS Settings → Face ID & Passcode\n"
                default:
                    results += "💡 Check simulator settings and try again\n"
                }
            }
        }
        
        results += "\nApp Settings:\n"
        results += "• Face ID Enabled in App: \(authManager.isBiometricEnabled)\n"
        results += "• User Authenticated: \(authManager.isAuthenticated)\n"
        
        testResult = results
        showingResults = true
    }
    
    private func testFaceIDAuthentication() {
        guard authManager.checkBiometricAvailability() == .faceID else {
            testResult = "❌ Face ID not available. Please enable in simulator first.\n\n1. Device → Face ID → Enrolled"
            showingResults = true
            return
        }
        
        testResult = "🔄 Starting Face ID authentication...\n\nIn Simulator:\n• Device → Face ID → Matching Face (for success)\n• Device → Face ID → Non-matching Face (for failure)"
        showingResults = true
        
        authManager.authenticateWithBiometrics()
        
        // Update results after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if authManager.isAuthenticated {
                testResult += "\n\n✅ Face ID authentication successful!"
            } else if let error = authManager.authenticationError {
                testResult += "\n\n❌ Face ID authentication failed:\n\(error)"
            }
        }
    }
    
    private func enableFaceID() {
        authManager.enableBiometricAuthentication()
        testResult = "✅ Face ID enabled in app settings!\n\nYou can now use Face ID to authenticate."
        showingResults = true
    }
}

#Preview {
    FaceIDSimulatorGuide()
        .environmentObject(AuthenticationManager())
}
