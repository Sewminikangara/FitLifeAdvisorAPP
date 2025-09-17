//
//  CustomButton.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var isLoading: Bool = false
    var isEnabled: Bool = true
    
    enum ButtonStyle {
        case primary
        case secondary
        case danger
        
        var backgroundColor: Color {
            switch self {
            case .primary: return Constants.Colors.primaryBlue
            case .secondary: return Color.clear
            case .danger: return Constants.Colors.errorRed
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return Constants.Colors.primaryBlue
            case .danger: return .white
            }
        }
        
        var borderColor: Color {
            switch self {
            case .primary: return Color.clear
            case .secondary: return Constants.Colors.primaryBlue
            case .danger: return Color.clear
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(Constants.Typography.headline)
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isEnabled ? style.backgroundColor : Color.gray.opacity(0.3))
            .foregroundColor(isEnabled ? style.foregroundColor : Color.gray)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(style.borderColor, lineWidth: style == .secondary ? 2 : 0)
            )
            .cornerRadius(Constants.cornerRadius)
        }
        .disabled(!isEnabled || isLoading)
    }
}
