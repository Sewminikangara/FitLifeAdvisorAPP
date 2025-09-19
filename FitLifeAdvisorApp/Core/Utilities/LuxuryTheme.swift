//
//  LuxuryTheme.swift
//  FitLifeAdvisorApp
//


import SwiftUI

struct LuxuryTheme {
    
    struct Colors {
        // Background Colors
        static let primaryBackground = Color(hex: "0A0A0A")
        static let secondaryBackground = Color(hex: "1A1A2E")
        static let tertiaryBackground = Color(hex: "16213E")
        static let surfaceBackground = Color(hex: "0F0F23")
        
        // Accent Colors
        static let goldPrimary = Color(hex: "FFD700")
        static let goldSecondary = Color(hex: "FFA500")
        static let aiBlue = Color(hex: "00E5FF")
        static let aiBlueSecondary = Color(hex: "0091EA")
        
        // Feature Colors
        static let nutritionRed = Color(hex: "FF6B6B")
        static let nutritionOrange = Color(hex: "FF8E53")
        static let scanTeal = Color(hex: "4ECDC4")
        static let scanGreen = Color(hex: "44A08D")
        static let workoutPurple = Color(hex: "667eea")
        static let workoutViolet = Color(hex: "764ba2")
        static let recipePink = Color(hex: "f093fb")
        static let recipeRed = Color(hex: "f5576c")
        
        // Text Colors
        static let primaryText = Color.white
        static let secondaryText = Color.white.opacity(0.8)
        static let tertiaryText = Color.white.opacity(0.6)
        static let placeholderText = Color.white.opacity(0.4)
        
        // Surface Colors
        static let cardBackground = Color.white.opacity(0.1)
        static let cardBorder = Color.white.opacity(0.2)
        static let glassBackground = Color.white.opacity(0.05)
    }
    
    // Typography
    struct Typography {
        static let largeTitle = Font.system(size: 36, weight: .bold)
        static let title1 = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .bold)
        static let title3 = Font.system(size: 20, weight: .semibold)
        static let headline = Font.system(size: 18, weight: .semibold)
        static let body = Font.system(size: 16, weight: .medium)
        static let callout = Font.system(size: 14, weight: .medium)
        static let caption = Font.system(size: 12, weight: .medium)
        static let caption2 = Font.system(size: 10, weight: .medium)
    }
    
    // Spacing
    struct Spacing {
        static let xxxSmall: CGFloat = 4
        static let xxSmall: CGFloat = 8
        static let xSmall: CGFloat = 12
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 40
        static let xxxLarge: CGFloat = 48
    }
    
    //  Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let xxLarge: CGFloat = 24
    }
    
    // Shadow
    struct Shadow {
        static let soft = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.2)
        static let strong = Color.black.opacity(0.3)
        static let luxury = Color.black.opacity(0.4)
    }
}

extension View {
    func luxuryBackground() -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: LuxuryTheme.Colors.primaryBackground, location: 0.0),
                    .init(color: LuxuryTheme.Colors.secondaryBackground, location: 0.3),
                    .init(color: LuxuryTheme.Colors.tertiaryBackground, location: 0.7),
                    .init(color: LuxuryTheme.Colors.surfaceBackground, location: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    func luxuryCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.large)
                    .fill(
                        LinearGradient(
                            colors: [
                                LuxuryTheme.Colors.cardBackground,
                                LuxuryTheme.Colors.glassBackground
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.large)
                            .stroke(LuxuryTheme.Colors.cardBorder, lineWidth: 1)
                    )
            )
            .shadow(color: LuxuryTheme.Shadow.medium, radius: 15, x: 0, y: 8)
    }
    
    func luxuryGlassCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.xLarge)
                    .fill(
                        LinearGradient(
                            colors: [
                                LuxuryTheme.Colors.cardBackground,
                                LuxuryTheme.Colors.glassBackground
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.xLarge)
                            .stroke(LuxuryTheme.Colors.cardBorder, lineWidth: 1)
                    )
            )
            .shadow(color: LuxuryTheme.Shadow.strong, radius: 20, x: 0, y: 10)
    }
}

struct LuxuryButtonStyle: ButtonStyle {
    let colors: [Color]
    let cornerRadius: CGFloat
    
    init(colors: [Color] = [LuxuryTheme.Colors.goldPrimary, LuxuryTheme.Colors.goldSecondary], 
         cornerRadius: CGFloat = LuxuryTheme.CornerRadius.medium) {
        self.colors = colors
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 10, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct LuxuryGhostButtonStyle: ButtonStyle {
    let borderColor: Color
    let cornerRadius: CGFloat
    
    init(borderColor: Color = LuxuryTheme.Colors.goldPrimary,
         cornerRadius: CGFloat = LuxuryTheme.CornerRadius.medium) {
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(borderColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor.opacity(0.5), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct LuxuryTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(LuxuryTheme.Typography.body)
            .foregroundColor(LuxuryTheme.Colors.primaryText)
            .padding(LuxuryTheme.Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.medium)
                    .fill(LuxuryTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: LuxuryTheme.CornerRadius.medium)
                            .stroke(LuxuryTheme.Colors.cardBorder, lineWidth: 1)
                    )
            )
    }
}

struct LuxuryNavigationStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(LuxuryTheme.Colors.primaryBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
        } else {
            content
                .navigationBarTitleDisplayMode(.inline)
                .background(LuxuryTheme.Colors.primaryBackground)
        }
    }
}

extension View {
    func luxuryNavigationStyle() -> some View {
        self.modifier(LuxuryNavigationStyle())
    }
}

struct LuxuryTabViewStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accentColor(LuxuryTheme.Colors.goldPrimary)
            .background(
                LinearGradient(
                    colors: [
                        LuxuryTheme.Colors.primaryBackground,
                        LuxuryTheme.Colors.secondaryBackground
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
    }
}

extension View {
    func luxuryTabViewStyle() -> some View {
        self.modifier(LuxuryTabViewStyle())
    }
}

extension LuxuryTheme {
    struct Gradients {
        static let primaryBackground = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Colors.primaryBackground, location: 0.0),
                .init(color: Colors.secondaryBackground, location: 0.3),
                .init(color: Colors.tertiaryBackground, location: 0.7),
                .init(color: Colors.surfaceBackground, location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let goldGradient = LinearGradient(
            colors: [Colors.goldPrimary, Colors.goldSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let aiGradient = LinearGradient(
            colors: [Colors.aiBlue, Colors.aiBlueSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let nutritionGradient = LinearGradient(
            colors: [Colors.nutritionRed, Colors.nutritionOrange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let scanGradient = LinearGradient(
            colors: [Colors.scanTeal, Colors.scanGreen],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let workoutGradient = LinearGradient(
            colors: [Colors.workoutPurple, Colors.workoutViolet],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let recipeGradient = LinearGradient(
            colors: [Colors.recipePink, Colors.recipeRed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cardGradient = LinearGradient(
            colors: [Colors.cardBackground, Colors.glassBackground],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
