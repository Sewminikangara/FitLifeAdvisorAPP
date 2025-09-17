//
//  User.swift
//  FitLifeAdvisorApp
//
//  Created by Sewmini 010 on 2025-08-28.
//

import Foundation

struct User: Codable, Identifiable {
    var id: String
    var email: String
    var name: String
    var profileImageURL: String?
    var age: Int?
    var height: Double? // in cm
    var weight: Double? // in kg
    var gender: Gender?
    var fitnessLevel: FitnessLevel?
    var goals: [FitnessGoal]
    var dietaryRestrictions: [DietaryRestriction]
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, email: String, name: String) {
        self.id = id
        self.email = email
        self.name = name
        self.goals = []
        self.dietaryRestrictions = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"
    
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .other: return "Other"
        case .preferNotToSay: return "Prefer not to say"
        }
    }
}

enum FitnessLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case elite = "elite"
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .elite: return "Elite"
        }
    }
}

enum FitnessGoal: String, CaseIterable, Codable {
    case weightLoss = "weight_loss"
    case muscleGain = "muscle_gain"
    case endurance = "endurance"
    case strength = "strength"
    case flexibility = "flexibility"
    case generalHealth = "general_health"
    case performance = "performance"
    case maintenance = "maintenance"
    case healthImprovement = "health_improvement"
    
    var displayName: String {
        switch self {
        case .weightLoss: return "Weight Loss"
        case .muscleGain: return "Muscle Gain"
        case .endurance: return "Endurance"
        case .strength: return "Strength"
        case .flexibility: return "Flexibility"
        case .generalHealth: return "General Health"
        case .performance: return "Athletic Performance"
        case .maintenance: return "Maintain Weight"
        case .healthImprovement: return "Health Improvement"
        }
    }
    
    var icon: String {
        switch self {
        case .weightLoss: return "arrow.down.circle"
        case .muscleGain: return "arrow.up.circle"
        case .endurance: return "figure.run.circle"
        case .strength: return "dumbbell"
        case .flexibility: return "figure.flexibility"
        case .generalHealth: return "heart.circle"
        case .performance: return "star.circle"
        case .maintenance: return "equal.circle"
        case .healthImprovement: return "heart.circle"
        }
    }
}

enum DietaryRestriction: String, CaseIterable, Codable {
    case vegetarian = "vegetarian"
    case vegan = "vegan"
    case glutenFree = "gluten_free"
    case lactoseFree = "lactose_free"
    case nutFree = "nut_free"
    case keto = "keto"
    case paleo = "paleo"
    
    var displayName: String {
        switch self {
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .glutenFree: return "Gluten-Free"
        case .lactoseFree: return "Lactose-Free"
        case .nutFree: return "Nut-Free"
        case .keto: return "Keto"
        case .paleo: return "Paleo"
        }
    }
}
