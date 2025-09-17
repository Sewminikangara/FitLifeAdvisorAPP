//
//  View+iOS16Compatibility.swift
//  FitLifeAdvisorApp
//
//

import SwiftUI

extension View {
    /// Conditionally applies presentationDetents if available (iOS 16+)
    @ViewBuilder
    func compatiblePresentationDetents(_ detents: Any...) -> some View {
        if #available(iOS 16.0, *) {
            // Note: This is a placeholder - actual implementation would need the real detents
            self
        } else {
            self
        }
    }
    
    /// Conditionally applies view modifiers based on iOS version
    @ViewBuilder
    func conditionalModifier<T: View>(@ViewBuilder modifier: (Self) -> T) -> some View {
        modifier(self)
    }
}

// iOS 16+ compatibility constants
struct iOSCompatibility {
    static let supportsPresentationDetents = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 16
}
