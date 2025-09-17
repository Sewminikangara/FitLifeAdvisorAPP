//
//  ProfileView.swift
//  FitLifeAdvisorApp
//
//  Enhanced Modern Profile View
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingSettings = false
    @State private var showingPersonalInfo = false
    @State private var showingGoals = false
    @State private var showingPrivacy = false
    @State private var showingHelp = false
    @State private var showingNotifications = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Modern Profile Header with Gradient Background
                    profileHeaderView
                    
                    // Quick Stats Section
                    quickStatsView
                    
                    // Menu Sections
                    menuSectionsView
                    
                    // Sign Out Section
                    signOutSectionView
                }
            }
            .background(Constants.Colors.backgroundGray)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingSettings) {
            ModernSettingsView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingPersonalInfo) {
            ModernPersonalInfoView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingGoals) {
            GoalsPreferencesView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacySecurityView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showingHelp) {
            HelpSupportView()
        }
    }
    
    private var profileHeaderView: some View {
        VStack(spacing: Constants.Spacing.medium) {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Constants.Colors.primaryBlue,
                    Constants.Colors.primaryBlue.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            .overlay(
                VStack(spacing: Constants.Spacing.medium) {
                    // Profile Avatar with Premium Design
                    Button(action: {
                        showingPersonalInfo = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.3))
                                .frame(width: 110, height: 110)
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Group {
                                        if let profileImageURL = authManager.currentUser?.profileImageURL {
                                            AsyncImage(url: URL(string: profileImageURL)) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .clipShape(Circle())
                                            } placeholder: {
                                                Text(String(authManager.currentUser?.name.prefix(1) ?? "U"))
                                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                                    .foregroundColor(Constants.Colors.primaryBlue)
                                            }
                                        } else {
                                            Text(String(authManager.currentUser?.name.prefix(1) ?? "U"))
                                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                                .foregroundColor(Constants.Colors.primaryBlue)
                                        }
                                    }
                                )
                            
                            // Edit Indicator
                            Circle()
                                .fill(Constants.Colors.primaryBlue)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 35, y: 35)
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // User Info
                    VStack(spacing: 4) {
                        Text(authManager.currentUser?.name ?? "Welcome Back!")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(authManager.currentUser?.email ?? "")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.top, Constants.Spacing.large)
            )
            .cornerRadius(24)
        }
    }
    
    private var quickStatsView: some View {
        VStack(spacing: Constants.Spacing.medium) {
            HStack {
                Text("Your Progress")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Button("View Details") {
                    // TODO: Navigate to detailed progress
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(.horizontal, Constants.Spacing.large)
            .padding(.top, Constants.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.medium) {
                    ModernStatCard(
                        title: "Streak",
                        value: "12",
                        unit: "days",
                        icon: "flame.fill",
                        color: Color.orange,
                        trend: "+3 this week"
                    )
                    
                    ModernStatCard(
                        title: "Meals",
                        value: "48",
                        unit: "logged",
                        icon: "fork.knife",
                        color: Color.green,
                        trend: "6 this week"
                    )
                    
                    ModernStatCard(
                        title: "Workouts",
                        value: "8",
                        unit: "completed",
                        icon: "figure.run",
                        color: Constants.Colors.primaryBlue,
                        trend: "2 this week"
                    )
                    
                    ModernStatCard(
                        title: "Weight",
                        value: "68.5",
                        unit: "kg",
                        icon: "scalemass",
                        color: Color.purple,
                        trend: "-0.5kg"
                    )
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
    
    private var menuSectionsView: some View {
        VStack(spacing: Constants.Spacing.large) {
            // Health & Fitness Section
            menuSection(
                title: "Health & Fitness",
                items: [
                    MenuItemData(icon: "person.circle.fill", title: "Personal Information", subtitle: "Update your profile details", action: { showingPersonalInfo = true }),
                    MenuItemData(icon: "target", title: "Goals & Preferences", subtitle: "Set your fitness targets", action: { showingGoals = true }),
                    MenuItemData(icon: "chart.line.uptrend.xyaxis", title: "Progress Analytics", subtitle: "View detailed insights", action: { /* TODO */ })
                ]
            )
            
            // App Settings Section
            menuSection(
                title: "App Settings",
                items: [
                    MenuItemData(icon: "bell.fill", title: "Notifications", subtitle: "Manage your alerts", action: { showingNotifications = true }),
                    MenuItemData(icon: "lock.shield.fill", title: "Privacy & Security", subtitle: "Manage your data privacy", action: { showingPrivacy = true }),
                    MenuItemData(icon: "gear", title: "App Settings", subtitle: "Customize your experience", action: { showingSettings = true })
                ]
            )
            
            // Support Section
            menuSection(
                title: "Support",
                items: [
                    MenuItemData(icon: "questionmark.circle.fill", title: "Help & Support", subtitle: "Get help and contact us", action: { showingHelp = true }),
                    MenuItemData(icon: "star.fill", title: "Rate FitLife", subtitle: "Share your feedback", action: { /* TODO: Open App Store */ }),
                    MenuItemData(icon: "square.and.arrow.up", title: "Share App", subtitle: "Invite friends to FitLife", action: { /* TODO: Share sheet */ })
                ]
            )
        }
        .padding(.top, Constants.Spacing.large)
    }
    
    private var signOutSectionView: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Divider()
                .padding(.horizontal, Constants.Spacing.large)
            
            Button(action: {
                authManager.signOut()
            }) {
                HStack {
                    Image(systemName: "arrow.right.square.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                    
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(Constants.Spacing.medium)
                .background(Color.red.opacity(0.05))
                .cornerRadius(12)
            }
            .padding(.horizontal, Constants.Spacing.large)
            .padding(.bottom, Constants.Spacing.extraLarge)
        }
    }
    
    private func menuSection(title: String, items: [MenuItemData]) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
                .padding(.horizontal, Constants.Spacing.large)
            
            VStack(spacing: Constants.Spacing.small) {
                ForEach(items.indices, id: \.self) { index in
                    ModernMenuItem(item: items[index])
                        .padding(.horizontal, Constants.Spacing.large)
                }
            }
        }
    }
}

struct MenuItemData {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
}

struct ModernStatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let trend: String
    
    var body: some View {
        VStack(spacing: Constants.Spacing.small) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(trend)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(unit)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Spacer()
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.textDark)
        }
        .frame(width: 140, height: 120)
        .padding(Constants.Spacing.medium)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

struct ModernMenuItem: View {
    let item: MenuItemData
    
    var body: some View {
        Button(action: item.action) {
            HStack(spacing: Constants.Spacing.medium) {
                Image(systemName: item.icon)
                    .font(.title2)
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text(item.subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Constants.Colors.textLight)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
            .padding(Constants.Spacing.medium)
            .background(.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Modern Personal Info View
struct ModernPersonalInfoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var gender: String = "Not specified"
    @State private var activityLevel: String = "Moderate"
    
    let genderOptions = ["Male", "Female", "Other", "Not specified"]
    let activityLevels = ["Sedentary", "Light", "Moderate", "Active", "Very Active"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.large) {
                    // Profile Image Section
                    profileImageSection
                    
                    // Personal Info Form
                    personalInfoForm
                    
                    // Action Buttons
                    actionButtons
                }
                .padding(.bottom, Constants.Spacing.extraLarge)
            }
            .background(Constants.Colors.backgroundGray)
            .navigationTitle("Personal Information")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
        .onAppear {
            loadUserData()
        }
    }
    
    private var profileImageSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Button(action: {
                // TODO: Image picker
            }) {
                ZStack {
                    Circle()
                        .fill(Constants.Colors.primaryBlue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    if let profileImageURL = authManager.currentUser?.profileImageURL {
                        AsyncImage(url: URL(string: profileImageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } placeholder: {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.title)
                                    .foregroundColor(Constants.Colors.primaryBlue)
                                
                                Text("Add Photo")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Constants.Colors.primaryBlue)
                            }
                        }
                    } else {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.title)
                                .foregroundColor(Constants.Colors.primaryBlue)
                            
                            Text("Add Photo")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Constants.Colors.primaryBlue)
                        }
                    }
                    
                    Circle()
                        .fill(Constants.Colors.primaryBlue)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 40, y: 40)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            
            Text("Tap to add or change profile photo")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.textLight)
        }
        .padding(.top, Constants.Spacing.large)
    }
    
    private var personalInfoForm: some View {
        VStack(spacing: Constants.Spacing.large) {
            VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                Text("Basic Information")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Constants.Colors.textDark)
                    .padding(.horizontal, Constants.Spacing.large)
                
                VStack(spacing: Constants.Spacing.medium) {
                    ModernTextField(title: "Full Name", text: $name, placeholder: "Enter your full name", icon: "person.fill")
                    
                    HStack(spacing: Constants.Spacing.medium) {
                        ModernTextField(title: "Age", text: $age, placeholder: "25", icon: "calendar", keyboardType: .numberPad)
                        
                        ModernPickerField(title: "Gender", selection: $gender, options: genderOptions, icon: "person.2.fill")
                    }
                    
                    HStack(spacing: Constants.Spacing.medium) {
                        ModernTextField(title: "Height", text: $height, placeholder: "170 cm", icon: "ruler", keyboardType: .numberPad)
                        
                        ModernTextField(title: "Weight", text: $weight, placeholder: "70 kg", icon: "scalemass", keyboardType: .decimalPad)
                    }
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
            
            VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                Text("Fitness Information")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Constants.Colors.textDark)
                    .padding(.horizontal, Constants.Spacing.large)
                
                ModernPickerField(title: "Activity Level", selection: $activityLevel, options: activityLevels, icon: "figure.run")
                    .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Button(action: saveUserInfo) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                    
                    Text("Save Changes")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Constants.Colors.primaryBlue, Constants.Colors.primaryBlue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(name.isEmpty)
            .opacity(name.isEmpty ? 0.6 : 1.0)
            
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
            }
        }
        .padding(.horizontal, Constants.Spacing.large)
    }
    
    private func loadUserData() {
        name = authManager.currentUser?.name ?? ""
        age = authManager.currentUser?.age?.description ?? ""
        height = authManager.currentUser?.height?.description ?? ""
        weight = authManager.currentUser?.weight?.description ?? ""
    }
    
    private func saveUserInfo() {
        // TODO: Save user information
        dismiss()
    }
}

// MARK: - Supporting Views
struct ModernTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.textDark)
            
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding()
            .background(.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        }
    }
}

struct ModernPickerField: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.textDark)
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(Constants.Colors.primaryBlue)
                        .frame(width: 20)
                    
                    Text(selection)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
                .padding()
                .background(.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
            }
        }
    }
}
