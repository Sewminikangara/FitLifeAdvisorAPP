//
//  FaceIDTestView.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.

import SwiftUI
import LocalAuthentication

struct FaceIDTestView: View {
    @State private var statusMessage = "Ready to test Face ID"
    @State private var isAvailable = false
    @State private var biometricType = "Unknown"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Face ID Debug Test")
                .font(.largeTitle)
                .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Status: \(statusMessage)")
                Text("Available: \(isAvailable ? "YES" : "NO")")
                Text("Type: \(biometricType)")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button("Check Face ID Availability") {
                checkFaceIDStatus()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Test Face ID Authentication") {
                testFaceIDAuth()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(!isAvailable)
        }
        .padding()
        .onAppear {
            checkFaceIDStatus()
        }
    }
    
    func checkFaceIDStatus() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isAvailable = true
            
            switch context.biometryType {
            case .faceID:
                biometricType = "Face ID"
                statusMessage = "Face ID is available!"
            case .touchID:
                biometricType = "Touch ID"
                statusMessage = "Touch ID is available!"
            default:
                biometricType = "None"
                statusMessage = "Biometric authentication available but type unknown"
            }
        } else {
            isAvailable = false
            statusMessage = "Not available: \(error?.localizedDescription ?? "Unknown error")"
            biometricType = "None"
        }
    }
    
    func testFaceIDAuth() {
        let context = LAContext()
        let reason = "Test Face ID authentication"
        
        statusMessage = "Requesting Face ID authentication..."
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    statusMessage = "✅ Face ID authentication successful!"
                } else {
                    statusMessage = "❌ Face ID failed: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
        }
    }
}

#Preview {
    FaceIDTestView()
}
