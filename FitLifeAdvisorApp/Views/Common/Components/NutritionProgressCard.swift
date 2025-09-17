//
//  NutritionProgressCard.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import SwiftUI

struct NutritionProgressCard: View {
    let title: String
    let current: Double
    let target: Double
    let unit: String
    let color: Color
    let icon: String
    
    var progress: Double {
        target > 0 ? min(current / target, 1.0) : 0.0
    }
    
    var progressText: String {
        "\(Int(current))/\(Int(target))\(unit)"
    }
    
    var body: some View {
        VStack(spacing: Constants.Spacing.medium) {
            // Header
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(title)
                        .font(Constants.Typography.caption)
                        .foregroundColor(Constants.Colors.textLight)
                    
                    Text(progressText)
                        .font(Constants.Typography.small)
                        .foregroundColor(Constants.Colors.textDark)
                        .fontWeight(.medium)
                }
            }
            
            // Progress Ring with Center Text
            ZStack {
                ProgressRing(
                    progress: progress,
                    lineWidth: 6,
                    size: CGSize(width: 60, height: 60),
                    color: color
                )
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
            }
        }
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
