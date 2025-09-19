//
//  ProfileView.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.


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
                    profileHeaderView
                    
                    quickStatsView
                    
                    menuSectionsView
                    
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
                .environmentObject(AppSettings.shared)
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
        VStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Constants.Colors.primaryBlue,
                    Constants.Colors.primaryBlue.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180) 
            .overlay(
                VStack(spacing: 12) { 
                    Button(action: {
                        showingPersonalInfo = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.3))
                                .frame(width: 90, height: 90) 
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 80, height: 80) 
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
                                                    .font(.system(size: 28, weight: .bold, design: .rounded)) // Smaller font
                                                    .foregroundColor(Constants.Colors.primaryBlue)
                                            }
                                        } else {
                                            Text(String(authManager.currentUser?.name.prefix(1) ?? "U"))
                                                .font(.system(size: 28, weight: .bold, design: .rounded)) // Smaller font
                                                .foregroundColor(Constants.Colors.primaryBlue)
                                        }
                                    }
                                )
                            
                            Circle()
                                .fill(Constants.Colors.primaryBlue)
                                .frame(width: 26, height: 26) 
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 12, weight: .medium)) 
                                        .foregroundColor(.white)
                                )
                                .offset(x: 28, y: 28) 
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // User Info - Compact for phone
                    VStack(spacing: 2) {
                        Text(authManager.currentUser?.name ?? "Welcome Back!")
                            .font(.system(size: 20, weight: .bold, design: .rounded)) // Smaller title
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8) // Auto-scale if text is too long
                        
                        Text(authManager.currentUser?.email ?? "")
                            .font(.system(size: 14, weight: .medium)) // Smaller subtitle
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.horizontal, 16) // Add horizontal padding
                }
                .padding(.top, 20) // Reduced top padding
            )
            .cornerRadius(20) // Slightly smaller corner radius
            .padding(.horizontal, 16) // Add margins for phone
        }
    }
    
    private var quickStatsView: some View {
        VStack(spacing: 12) { // Reduced spacing for phone
            HStack {
                Text("Your Progress")
                    .font(.system(size: 18, weight: .bold, design: .rounded)) // Smaller title
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Button("View Details") {
                }
                .font(.system(size: 13, weight: .medium)) // Smaller button text
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(.horizontal, 16) // Consistent phone padding
            .padding(.top, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) { // Reduced spacing between cards
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
                .padding(.horizontal, 16) // Phone-optimized padding
            }
        }
    }
    
    private var menuSectionsView: some View {
        VStack(spacing: Constants.Spacing.large) {
            // Account & Settings Section
            menuSection(
                title: "Account & Settings",
                items: [
                    MenuItemData(icon: "person.circle.fill", title: "Personal Information", subtitle: "Update your profile details", action: { showingPersonalInfo = true }),
                    MenuItemData(icon: "target", title: "Goals & Preferences", subtitle: "Set your fitness targets", action: { showingGoals = true }),
                    MenuItemData(icon: "bell.fill", title: "Notifications", subtitle: "Manage your alerts", action: { showingNotifications = true }),
                    MenuItemData(icon: "lock.shield.fill", title: "Privacy & Security", subtitle: "Manage your data privacy", action: { showingPrivacy = true }),
                    MenuItemData(icon: "questionmark.circle.fill", title: "Help & Support", subtitle: "Get help and contact us", action: { showingHelp = true })
                ]
            )
            
            // App Features Section
            menuSection(
                title: "App Features",
                items: [
                    MenuItemData(icon: "chart.line.uptrend.xyaxis", title: "Progress Analytics", subtitle: "View detailed insights", action: { /* TODO */ }),
                    MenuItemData(icon: "gear", title: "App Settings", subtitle: "Customize your experience", action: { showingSettings = true }),
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
        VStack(spacing: 8) { // Reduced spacing for phone
            HStack {
                Image(systemName: icon)
                    .font(.title3) // Smaller icon for phone
                    .foregroundColor(color)
                
                Spacer()
                
                Text(trend)
                    .font(.system(size: 10, weight: .medium)) // Smaller trend text
                    .foregroundColor(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(color.opacity(0.1))
                    .cornerRadius(6)
            }
            
            Spacer()
            
            VStack(spacing: 1) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded)) // Smaller value for phone
                    .foregroundColor(Constants.Colors.textDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(unit)
                    .font(.system(size: 11, weight: .medium)) // Smaller unit text
                    .foregroundColor(Constants.Colors.textLight)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(title)
                .font(.system(size: 12, weight: .medium)) // Smaller title
                .foregroundColor(Constants.Colors.textDark)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 120, height: 100) // Smaller card size for phone
        .padding(12) // Reduced padding
        .background(.white)
        .cornerRadius(12) // Smaller corner radius
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2) // Lighter shadow
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
    @State private var phoneNumber: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var targetWeight: String = ""
    @State private var gender: String = "Not specified"
    @State private var activityLevel: String = "Moderate"
    @State private var fitnessGoal: String = "Maintain weight"
    @State private var dietType: String = "Regular"
    @State private var preferredUnits: String = "Metric"
    @State private var workoutDays: String = "3-4 days"
    @State private var aboutMe: String = ""
    
    let genderOptions = ["Male", "Female", "Other", "Not specified"]
    let activityLevels = ["Sedentary", "Light", "Moderate", "Active", "Very Active"]
    let fitnessGoals = ["Lose weight", "Maintain weight", "Gain weight", "Build muscle", "Improve fitness"]
    let dietTypes = ["Regular", "Vegetarian", "Vegan", "Keto", "Paleo", "Mediterranean", "Other"]
    let unitOptions = ["Metric (kg, cm)", "Imperial (lb, ft)"]
    let workoutDayOptions = ["1-2 days", "3-4 days", "5-6 days", "Daily"]
    
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
        VStack(spacing: 20) { 
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Basic Information")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Constants.Colors.textDark)
                    .padding(.horizontal, 16)
                
                VStack(spacing: 16) {
                    ModernTextField(title: "Full Name", text: $name, placeholder: "Enter your full name", icon: "person.fill")
                    
                    ModernTextField(title: "Phone Number", text: $phoneNumber, placeholder: "+1 (555) 123-4567", icon: "phone.fill", keyboardType: .phonePad)
                    
                    HStack(spacing: 12) {
                        ModernTextField(title: "Age", text: $age, placeholder: "25", icon: "calendar", keyboardType: .numberPad)
                        
                        ModernPickerField(title: "Gender", selection: $gender, options: genderOptions, icon: "person.2.fill")
                    }
                    
                    HStack(spacing: 12) {
                        ModernTextField(title: "Height", text: $height, placeholder: "170 cm", icon: "ruler", keyboardType: .numberPad)
                        
                        ModernTextField(title: "Weight", text: $weight, placeholder: "70 kg", icon: "scalemass", keyboardType: .decimalPad)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Health Information Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Health Information")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Constants.Colors.textDark)
                    .padding(.horizontal, 16)
                
                VStack(spacing: 16) {
                    ModernPickerField(title: "Activity Level", selection: $activityLevel, options: activityLevels, icon: "figure.run")
                    
                    ModernPickerField(title: "Fitness Goal", selection: $fitnessGoal, options: fitnessGoals, icon: "target")
                    
                    HStack(spacing: 12) {
                        ModernTextField(title: "Target Weight", text: $targetWeight, placeholder: "65 kg", icon: "arrow.down.to.line", keyboardType: .decimalPad)
                        
                        ModernPickerField(title: "Diet Type", selection: $dietType, options: dietTypes, icon: "leaf.fill")
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Preferences Section  
            VStack(alignment: .leading, spacing: 16) {
                Text("Preferences")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Constants.Colors.textDark)
                    .padding(.horizontal, 16)
                
                VStack(spacing: 16) {
                    ModernPickerField(title: "Units", selection: $preferredUnits, options: unitOptions, icon: "ruler")
                    
                    ModernPickerField(title: "Workout Days", selection: $workoutDays, options: workoutDayOptions, icon: "calendar.badge.plus")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About Me")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Constants.Colors.textDark)
                        
                        TextEditor(text: $aboutMe)
                            .frame(height: 80)
                            .padding(12)
                            .background(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 16)
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
        dismiss()
    }
}

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
