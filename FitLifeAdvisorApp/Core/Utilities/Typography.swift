//
//  Typography.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import SwiftUI

struct Typography {
    // MARK: - Font Styles
    static let largeTitle = Font.system(size: 32, weight: .bold, design: .default)
    static let title = Font.system(size: 24, weight: .bold, design: .default)
    static let headline = Font.system(size: 20, weight: .medium, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let caption = Font.system(size: 14, weight: .regular, design: .default)
    static let small = Font.system(size: 12, weight: .regular, design: .default)
    
    // MARK: - Font Weights
    enum Weight {
        case regular
        case medium
        case semibold
        case bold
        
        var value: Font.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }
}

// MARK: - Usage Examples in Preview
struct TypographyPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Large Title")
                .font(Typography.largeTitle)
            
            Text("Title")
                .font(Typography.title)
            
            Text("Headline")
                .font(Typography.headline)
            
            Text("Body text for regular content")
                .font(Typography.body)
            
            Text("Caption text")
                .font(Typography.caption)
            
            Text("Small text")
                .font(Typography.small)
        }
        .padding()
    }
}

#Preview {
    TypographyPreview()
}
