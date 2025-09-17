import SwiftUI

struct WelcomeView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var showingLogin = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("FitLife")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your personal fitness companion")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Authentication Buttons
                VStack(spacing: 20) {
                    // Biometric Authentication Button
                    Button(action: {
                        authManager.authenticateWithBiometrics()
                    }) {
                        HStack {
                            Image(systemName: biometricIcon)
                                .font(.title2)
                            Text("Sign in with \(biometricText)")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(authManager.checkBiometricAvailability() == .none)
                    
                    // Alternative Login Button
                    Button(action: {
                        showingLogin = true
                    }) {
                        HStack {
                            Image(systemName: "person.circle")
                                .font(.title2)
                            Text("Sign in with Passcode")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .alert("Authentication Error", isPresented: .constant(authManager.authenticationError != nil)) {
            Button("OK") {
                authManager.authenticationError = nil
            }
        } message: {
            Text(authManager.authenticationError ?? "")
        }
        .sheet(isPresented: $showingLogin) {
            PasscodeLoginView(authManager: authManager)
        }
    }
    
    private var biometricIcon: String {
        switch authManager.checkBiometricAvailability() {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return "lock"
        }
    }
    
    private var biometricText: String {
        switch authManager.checkBiometricAvailability() {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .none:
            return "Biometrics"
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}