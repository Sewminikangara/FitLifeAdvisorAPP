import SwiftUI
import LocalAuthentication

struct PasscodeLoginView: View {
    @ObservedObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Secure Authentication")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Use your device passcode to access FitLife")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    authManager.authenticateWithPasscode()
                }) {
                    HStack {
                        Image(systemName: "key")
                        Text("Authenticate with Passcode")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(25)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationTitle("Authentication")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onChange(of: authManager.isAuthenticated) { authenticated in
            if authenticated {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
