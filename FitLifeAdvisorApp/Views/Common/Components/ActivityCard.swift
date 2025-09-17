//
//  ActivityCard.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import SwiftUI

struct ActivityCard: View {
    let title: String
    let subtitle: String
    let time: String
    let icon: String
    let color: Color
    let calories: String?
    
    init(title: String, subtitle: String, time: String, icon: String, color: Color, calories: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.time = time
        self.icon = icon
        self.color = color
        self.calories = calories
    }
    
    var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            // Icon container
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Constants.Typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textDark)
                
                Text(subtitle)
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            Spacer()
            
            // Right side info
            VStack(alignment: .trailing, spacing: 4) {
                Text(time)
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
                
                if let calories = calories {
                    Text(calories)
                        .font(Constants.Typography.small)
                        .foregroundColor(color)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

