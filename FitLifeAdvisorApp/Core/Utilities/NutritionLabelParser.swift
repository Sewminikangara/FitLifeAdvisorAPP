//
//  NutritionLabelParser.swift
//  FitLifeAdvisorApp
//
//  Simple nutrition label text parser for unit tests and reuse.
//

import Foundation

enum NutritionLabelParser {
    static func parse(from text: String) -> NutritionInfo? {
        let lower = text.lowercased()

        func number(for patterns: [String]) -> Double {
            for p in patterns {
                if let v = matchNumber(lower, pattern: p) { return v }
            }
            return 0
        }

        let calories = number(for: ["calories\\s*([0-9]+)", "kcal\\s*([0-9]+)"])
        let protein  = number(for: ["protein\\s*([0-9]+)\\s*g"]) 
        let carbs    = number(for: ["carb[s]?\\s*([0-9]+)\\s*g"]) 
        let fat      = number(for: ["fat\\s*([0-9]+)\\s*g"]) 
        let fiber    = number(for: ["fiber\\s*([0-9]+)\\s*g"]) 
        let sugar    = number(for: ["sugar[s]?\\s*([0-9]+)\\s*g"]) 
        let sodiumMg = number(for: ["sodium\\s*([0-9]+)\\s*mg"]) 

        // If nothing matched, return nil
        if calories == 0 && protein == 0 && carbs == 0 && fat == 0 { return nil }

        return NutritionInfo(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar,
            sodium: sodiumMg,
            cholesterol: 0
        )
    }

    private static func matchNumber(_ text: String, pattern: String) -> Double? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
            if let match = regex.firstMatch(in: text, options: [], range: nsRange), match.numberOfRanges > 1 {
                if let range = Range(match.range(at: 1), in: text) {
                    return Double(text[range])
                }
            }
        } catch { return nil }
        return nil
    }
}
