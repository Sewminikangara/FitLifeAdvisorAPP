//
//  Constants.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
import SwiftUI

struct Constants {
    // MARK: - Colors
    struct Colors {
        static let primaryBlue = Color(hex: "4A90E2")
        static let successGreen = Color(hex: "7ED321")
        static let accentGreen = Color(hex: "7ED321") // Alias for successGreen
        static let warningOrange = Color(hex: "F5A623")
        static let errorRed = Color(hex: "D0021B")
        static let backgroundGray = Color(hex: "F8F9FA")
        static let textDark = Color(hex: "333333")
        static let textLight = Color.gray
        static let textSecondary = Color.gray // Secondary text color
        static let cardBackground = Color.white
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 32, weight: .bold, design: .default)
        static let title = Font.system(size: 24, weight: .bold, design: .default)
        static let title3 = Font.system(size: 18, weight: .medium, design: .default)
        static let headline = Font.system(size: 20, weight: .medium, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let caption = Font.system(size: 14, weight: .regular, design: .default)
        static let small = Font.system(size: 12, weight: .regular, design: .default)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 12
}
