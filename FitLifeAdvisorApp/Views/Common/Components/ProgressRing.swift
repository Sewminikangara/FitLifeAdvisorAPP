//
//  ProgressRing.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGSize
    let color: Color
    let backgroundColor: Color
    
    init(progress: Double,
         lineWidth: CGFloat = 8,
         size: CGSize = CGSize(width: 80, height: 80),
         color: Color = Constants.Colors.primaryBlue,
         backgroundColor: Color = Color.gray.opacity(0.2)) {
        self.progress = min(max(progress, 0.0), 1.0)
        self.lineWidth = lineWidth
        self.size = size
        self.color = color
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
                .frame(width: size.width, height: size.height)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: size.width, height: size.height)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: progress)
        }
    }
}
