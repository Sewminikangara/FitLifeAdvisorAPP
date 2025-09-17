//
//  NotificationBanner.swift
//  FitLifeAdvisorApp
//
//  Created by AI Assistant on 2025-09-09.
//

import SwiftUI

struct NotificationBanner: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showBanner = false
    @State private var bannerMessage = ""
    @State private var bannerType: BannerType = .info
    
    enum BannerType {
        case success, warning, error, info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    var body: some View {
        VStack {
            if showBanner {
                HStack {
                    Image(systemName: bannerType.icon)
                        .foregroundColor(bannerType.color)
                    
                    Text(bannerMessage)
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("×") {
                        withAnimation {
                            showBanner = false
                        }
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(bannerType.color.opacity(0.1))
                .cornerRadius(8)
                .transition(.move(edge: .top))
            }
            
            Spacer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showNotificationBanner)) { notification in
            if let userInfo = notification.userInfo,
               let message = userInfo["message"] as? String,
               let typeString = userInfo["type"] as? String {
                
                let type: BannerType = {
                    switch typeString {
                    case "success": return .success
                    case "warning": return .warning
                    case "error": return .error
                    default: return .info
                    }
                }()
                
                showNotificationBanner(message: message, type: type)
            }
        }
    }
    
    private func showNotificationBanner(message: String, type: BannerType) {
        bannerMessage = message
        bannerType = type
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showBanner = true
        }
        
        // Auto-hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showBanner = false
            }
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let showNotificationBanner = Notification.Name("showNotificationBanner")
}

// MARK: - Helper for showing banners
extension NotificationManager {
    func showBanner(message: String, type: String = "info") {
        NotificationCenter.default.post(
            name: .showNotificationBanner,
            object: nil,
            userInfo: ["message": message, "type": type]
        )
    }
}
