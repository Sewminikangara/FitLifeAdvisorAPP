//
//  AccessibilityHelpers.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.

import SwiftUI

//Accessibility IDs for testing & VoiceOver
enum AXID {
    // Common
    static let primaryActionButton = "ax.primaryActionButton"
    static let secondaryActionButton = "ax.secondaryActionButton"
    static let closeButton = "ax.closeButton"
    static let cameraShutter = "ax.cameraShutter"
    static let analyzeButton = "ax.analyzeButton"
    static let analysisResult = "ax.analysisResult"
    static let notificationBanner = "ax.notificationBanner"
}

//View helpers
extension View {
    /// Apply common accessibility modifiers for buttons in one place
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(label))
            .accessibilityHint(hint != nil ? Text(hint!) : Text(""))
            .accessibilityAddTraits(.isButton)
    }

    /// Apply common accessibility modifiers for images that convey meaning
    func accessibleImage(label: String) -> some View {
        self
            .accessibilityLabel(Text(label))
            .accessibilityAddTraits(.isImage)
    }

    /// Marks a container as a single logical element for VoiceOver
    func asSingleAXElement(label: String, value: String? = nil, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(label))
            .accessibilityValue(value != nil ? Text(value!) : Text(""))
            .accessibilityHint(hint != nil ? Text(hint!) : Text(""))
    }

    /// Optional: prioritize order when swiping through elements
    func axPriority(_ priority: Double) -> some View {
        self.accessibilitySortPriority(priority)
    }
}

// MARK: - Dynamic Type convenience
struct ScalableText: View {
    let text: String
    let font: Font
    let weight: Font.Weight

    init(_ text: String, font: Font = .body, weight: Font.Weight = .regular) {
        self.text = text
        self.font = font
        self.weight = weight
    }

    var body: some View {
        Text(text)
            .font(font.weight(weight))
            .minimumScaleFactor(0.85)
            .lineLimit(2)
    }
}
