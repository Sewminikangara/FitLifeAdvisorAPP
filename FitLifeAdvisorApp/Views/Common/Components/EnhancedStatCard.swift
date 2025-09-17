//
//  EnhancedStatCard.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import SwiftUI

struct EnhancedStatCard: View {
    let title: String
    let value: String
    let target: String
    let icon: String
    let color: Color
    let progress: Double
    let trend: StatTrend?
    
    enum StatTrend {
        case up(String)
        case down(String)
        case neutral(String)
        
        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return Constants.Colors.successGreen
            case .down: return Constants.Colors.errorRed
            case .neutral: return Constants.Colors.textLight
            }
        }
        
        var text: String {
            switch self {
            case .up(let text), .down(let text), .neutral(let text):
                return text
            }
        }
    }
    
    var body: some View {
        VStack(spacing: Constants.Spacing.small) {
            // Header with icon and title
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
                
                Text(title)
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            // Main value
            HStack {
                Text(value)
                    .font(Constants.Typography.title)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
            }
            
            // Target and progress
            HStack {
                Text("of \(target)")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
                
                Spacer()
                
                // Trend indicator
                if let trend = trend {
                    HStack(spacing: 4) {
                        Image(systemName: trend.icon)
                            .font(.caption2)
                            .foregroundColor(trend.color)
                        
                        Text(trend.text)
                            .font(Constants.Typography.small)
                            .foregroundColor(trend.color)
                    }
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 6)
                        .opacity(0.2)
                        .foregroundColor(color)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width), height: 6)
                        .foregroundColor(color)
                        .cornerRadius(3)
                        .animation(.spring(response: 1.0, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
