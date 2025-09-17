//
//  HelpSupportView.swift
//  FitLifeAdvisorApp
//
//  Help and Support Center
//

import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: HelpCategory = .general
    @State private var showingContactForm = false
    @State private var expandedFAQ: String? = nil
    
    enum HelpCategory: String, CaseIterable {
        case general = "General"
        case account = "Account"
        case nutrition = "Nutrition"
        case workouts = "Workouts"
        case privacy = "Privacy"
        case technical = "Technical"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.large) {
                    // Header
                    helpHeader
                    
                    // Search Bar
                    searchBar
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // FAQ Categories
                    faqCategoriesSection
                    
                    // FAQ Items
                    faqSection
                    
                    // Contact Section
                    contactSection
                }
                .padding(.bottom, Constants.Spacing.extraLarge)
            }
            .background(Constants.Colors.backgroundGray)
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
        .sheet(isPresented: $showingContactForm) {
            ContactSupportView()
        }
    }
    
    private var helpHeader: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.indigo, .indigo.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 4) {
                Text("How can we help?")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.textDark)
                
                Text("Find answers to common questions or contact our support team")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, Constants.Spacing.large)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(Constants.Colors.textLight)
            
            TextField("Search for help topics...", text: $searchText)
                .font(.system(size: 16, weight: .medium))
        }
        .padding(Constants.Spacing.medium)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        .padding(.horizontal, Constants.Spacing.large)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Quick Actions")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
                .padding(.horizontal, Constants.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.medium) {
                    HelpQuickActionCard(
                        title: "Contact Support",
                        subtitle: "Get help from our team",
                        icon: "envelope.fill",
                        color: .blue
                    ) {
                        showingContactForm = true
                    }
                    
                    HelpQuickActionCard(
                        title: "User Guide",
                        subtitle: "Learn how to use FitLife",
                        icon: "book.fill",
                        color: .green
                    ) {
                        // TODO: Open user guide
                    }
                    
                    HelpQuickActionCard(
                        title: "Video Tutorials",
                        subtitle: "Watch step-by-step guides",
                        icon: "play.circle.fill",
                        color: .red
                    ) {
                        // TODO: Open video tutorials
                    }
                    
                    HelpQuickActionCard(
                        title: "Community Forum",
                        subtitle: "Connect with other users",
                        icon: "person.3.fill",
                        color: .purple
                    ) {
                        // TODO: Open community forum
                    }
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
    
    private var faqCategoriesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Browse by Category")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
                .padding(.horizontal, Constants.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.small) {
                    ForEach(HelpCategory.allCases, id: \.self) { category in
                        HelpCategoryChip(
                            title: category.rawValue,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, Constants.Spacing.large)
            }
        }
    }
    
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text("Frequently Asked Questions")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
                .padding(.horizontal, Constants.Spacing.large)
            
            VStack(spacing: Constants.Spacing.small) {
                ForEach(faqItems(for: selectedCategory), id: \.question) { faq in
                    FAQItem(
                        question: faq.question,
                        answer: faq.answer,
                        isExpanded: expandedFAQ == faq.question
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            expandedFAQ = expandedFAQ == faq.question ? nil : faq.question
                        }
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.large)
        }
    }
    
    private var contactSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Text("Still need help?")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Constants.Colors.textDark)
            
            Text("Our support team is here to help you with any questions or issues.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Constants.Colors.textLight)
                .multilineTextAlignment(.center)
            
            VStack(spacing: Constants.Spacing.small) {
                Button(action: {
                    showingContactForm = true
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Contact Support")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Constants.Colors.primaryBlue)
                    .cornerRadius(12)
                }
                
                HStack(spacing: Constants.Spacing.large) {
                    Button(action: {
                        // TODO: Open email app
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                            Text("Email")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Constants.Colors.primaryBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Constants.Colors.primaryBlue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        // TODO: Open Twitter
                    }) {
                        HStack {
                            Image(systemName: "at")
                            Text("Twitter")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Constants.Colors.primaryBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Constants.Colors.primaryBlue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        // TODO: Call support
                    }) {
                        HStack {
                            Image(systemName: "phone")
                            Text("Call")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Constants.Colors.primaryBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Constants.Colors.primaryBlue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(Constants.Spacing.large)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, Constants.Spacing.large)
    }
    
    private func faqItems(for category: HelpCategory) -> [FAQItemData] {
        switch category {
        case .general:
            return [
                FAQItemData(
                    question: "How do I get started with FitLife?",
                    answer: "Welcome to FitLife! Start by setting up your profile with your personal information and fitness goals. Then you can begin logging meals, tracking workouts, and monitoring your progress."
                ),
                FAQItemData(
                    question: "Is FitLife free to use?",
                    answer: "FitLife offers both free and premium features. The basic meal logging, workout tracking, and progress monitoring are free. Premium features include advanced analytics, personalized meal plans, and priority support."
                ),
                FAQItemData(
                    question: "How accurate is the meal analysis?",
                    answer: "Our AI-powered meal analysis uses advanced image recognition technology and is constantly improving. While we strive for high accuracy, we recommend reviewing the results and making adjustments as needed."
                )
            ]
        case .account:
            return [
                FAQItemData(
                    question: "How do I change my email address?",
                    answer: "Go to Profile > Personal Information and tap on your email field. Enter your new email address and we'll send you a verification link to confirm the change."
                ),
                FAQItemData(
                    question: "I forgot my password. How can I reset it?",
                    answer: "On the login screen, tap 'Forgot Password' and enter your email address. We'll send you a link to reset your password securely."
                )
            ]
        case .nutrition:
            return [
                FAQItemData(
                    question: "How do I log a meal?",
                    answer: "Tap the camera icon on your dashboard, take a photo of your meal, and our AI will analyze the food items and provide nutritional information."
                )
            ]
        case .workouts, .privacy, .technical:
            return [
                FAQItemData(
                    question: "Coming soon...",
                    answer: "More FAQs for this category will be added soon."
                )
            ]
        }
    }
}

// MARK: - Contact Support View
struct ContactSupportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var subject = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showingSuccessMessage = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: Constants.Spacing.large) {
                Text("Contact Support")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Constants.Colors.textDark)
                
                TextField("Subject", text: $subject)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextEditor(text: $message)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                
                Button("Send Message") {
                    // TODO: Send message
                    dismiss()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Constants.Colors.primaryBlue)
                .cornerRadius(12)
                .disabled(subject.isEmpty || message.isEmpty)
                
                Spacer()
            }
            .padding(Constants.Spacing.large)
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
}

// MARK: - Supporting Data Types
struct FAQItemData {
    let question: String
    let answer: String
}

// MARK: - Supporting Views
struct HelpQuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Constants.Colors.textLight)
                }
            }
            .frame(width: 140, height: 100, alignment: .topLeading)
            .padding(Constants.Spacing.medium)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct HelpCategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : Constants.Colors.primaryBlue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Constants.Colors.primaryBlue : Constants.Colors.primaryBlue.opacity(0.1))
                .cornerRadius(20)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    let isExpanded: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack {
                    Text(question)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textDark)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                }
                .padding(Constants.Spacing.medium)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                    Divider()
                        .padding(.horizontal, Constants.Spacing.medium)
                    
                    Text(answer)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Constants.Colors.textLight)
                        .padding(.horizontal, Constants.Spacing.medium)
                        .padding(.bottom, Constants.Spacing.medium)
                }
            }
        }
        .background(.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

#Preview {
    HelpSupportView()
}