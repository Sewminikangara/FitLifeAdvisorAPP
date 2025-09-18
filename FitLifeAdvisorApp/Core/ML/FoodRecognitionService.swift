//
//  FoodRecognitionService.swift
//  FitLifeAdvisorApp
//
//

import SwiftUI
import Foundation

// Food Recognition Service
@MainActor
class FoodRecognitionService: ObservableObject {
    @Published var isLoading = false
    @Published var nutritionInfo: NutritionInfo?
    @Published var foodProduct: FoodProduct?
    @Published var errorMessage: String?
    
    private let mlKitManager = MLKitManager()
    
    // Barcode to Food Product
    func fetchFoodProduct(barcode: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Simulate API call to nutrition database
            let product = await mockFoodProductAPI(barcode: barcode)
            
            DispatchQueue.main.async {
                self.foodProduct = product
                self.nutritionInfo = product.nutrition
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch food product: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // Scan Nutrition Label
    func scanNutritionLabel(image: UIImage) {
        isLoading = true
        errorMessage = nil
        
        mlKitManager.recognizeText(from: image) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let textArray):
                    let nutrition = self.mlKitManager.extractNutritionInfo(from: textArray)
                    self.nutritionInfo = nutrition
                    
                    // Create food product from scanned data
                    self.foodProduct = FoodProduct(
                        id: UUID().uuidString,
                        name: "Scanned Nutrition Label",
                        brand: "Scanned Product",
                        barcode: nil,
                        nutrition: nutrition,
                        servingSize: "1 serving",
                        category: .other
                    )
                    
                case .failure(let error):
                    self.errorMessage = "Failed to scan nutrition label: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func mockFoodProductAPI(barcode: String) async -> FoodProduct {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        print("🔍 Looking up barcode: \(barcode)")
        
        // Comprehensive mock database with real product barcodes
        switch barcode {
        // Coca-Cola Products
        case "049000028911", "0490000289111", "049000028928":
            return FoodProduct(
                id: barcode,
                name: "Coca-Cola Classic",
                brand: "Coca-Cola",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 140,
                    protein: 0,
                    carbs: 39,
                    fat: 0,
                    fiber: 0,
                    sugar: 39,
                    sodium: 45,
                    cholesterol: 0
                ),
                servingSize: "1 can (12 fl oz)",
                category: .beverage
            )
            
        // Lay's Potato Chips
        case "028400064507", "0284000645079", "028400064514":
            return FoodProduct(
                id: barcode,
                name: "Lay's Classic Potato Chips",
                brand: "Lay's",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 160,
                    protein: 2,
                    carbs: 15,
                    fat: 10,
                    fiber: 1,
                    sugar: 0,
                    sodium: 170,
                    cholesterol: 0
                ),
                servingSize: "1 oz (28g)",
                category: .snack
            )
            
        // General Mills Cheerios
        case "016000275355", "0160002753553", "016000275362":
            return FoodProduct(
                id: barcode,
                name: "Honey Nut Cheerios",
                brand: "General Mills",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 110,
                    protein: 3,
                    carbs: 22,
                    fat: 1.5,
                    fiber: 2,
                    sugar: 9,
                    sodium: 160,
                    cholesterol: 0
                ),
                servingSize: "3/4 cup (28g)",
                category: .grain
            )
            
        // Pepsi
        case "012000001581", "0120000015818", "012000001598":
            return FoodProduct(
                id: barcode,
                name: "Pepsi Cola",
                brand: "PepsiCo",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 150,
                    protein: 0,
                    carbs: 41,
                    fat: 0,
                    fiber: 0,
                    sugar: 41,
                    sodium: 30,
                    cholesterol: 0
                ),
                servingSize: "1 can (12 fl oz)",
                category: .beverage
            )
            
        // Kraft Mac & Cheese
        case "021000615858", "0210006158584", "021000615865":
            return FoodProduct(
                id: barcode,
                name: "Kraft Macaroni & Cheese",
                brand: "Kraft",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 350,
                    protein: 11,
                    carbs: 47,
                    fat: 13,
                    fiber: 2,
                    sugar: 6,
                    sodium: 580,
                    cholesterol: 15
                ),
                servingSize: "1 cup prepared",
                category: .other
            )
            
        // Oreo Cookies
        case "044000032060", "0440000320607", "044000032077":
            return FoodProduct(
                id: barcode,
                name: "Oreo Original Cookies",
                brand: "Nabisco",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 160,
                    protein: 2,
                    carbs: 25,
                    fat: 7,
                    fiber: 1,
                    sugar: 14,
                    sodium: 135,
                    cholesterol: 0
                ),
                servingSize: "3 cookies (34g)",
                category: .snack
            )
            
        // Nature Valley Granola Bars
        case "016000424050", "0160004240507", "016000424067":
            return FoodProduct(
                id: barcode,
                name: "Nature Valley Crunchy Granola Bars",
                brand: "Nature Valley",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 190,
                    protein: 4,
                    carbs: 29,
                    fat: 7,
                    fiber: 2,
                    sugar: 11,
                    sodium: 160,
                    cholesterol: 0
                ),
                servingSize: "2 bars (42g)",
                category: .snack
            )
            
        // Campbell's Chicken Noodle Soup
        case "051000025029", "0510000250292", "051000025036":
            return FoodProduct(
                id: barcode,
                name: "Campbell's Chicken Noodle Soup",
                brand: "Campbell's",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 60,
                    protein: 3,
                    carbs: 8,
                    fat: 1.5,
                    fiber: 1,
                    sugar: 1,
                    sodium: 890,
                    cholesterol: 10
                ),
                servingSize: "1/2 cup condensed",
                category: .other
            )
            
        // Red Bull Energy Drink
        case "090204963015", "0902049630151", "090204963022":
            return FoodProduct(
                id: barcode,
                name: "Red Bull Energy Drink",
                brand: "Red Bull",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 110,
                    protein: 1,
                    carbs: 27,
                    fat: 0,
                    fiber: 0,
                    sugar: 27,
                    sodium: 105,
                    cholesterol: 0
                ),
                servingSize: "1 can (8.4 fl oz)",
                category: .beverage
            )
            
        // Kellogg's Pop-Tarts
        case "038000039058", "0380000390586", "038000039065":
            return FoodProduct(
                id: barcode,
                name: "Kellogg's Pop-Tarts Strawberry",
                brand: "Kellogg's",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 400,
                    protein: 4,
                    carbs: 76,
                    fat: 9,
                    fiber: 1,
                    sugar: 30,
                    sodium: 340,
                    cholesterol: 0
                ),
                servingSize: "1 package (2 pastries)",
                category: .snack
            )
            
        // Test/Demo Barcodes
        case "123456789012", "1234567890128":
            return FoodProduct(
                id: barcode,
                name: "Organic Banana",
                brand: "Fresh Farms",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 105,
                    protein: 1.3,
                    carbs: 27.0,
                    fat: 0.3,
                    fiber: 3.1,
                    sugar: 14.4,
                    sodium: 1.0,
                    cholesterol: 0
                ),
                servingSize: "1 medium banana (118g)",
                category: .fruit
            )
            
        case "987654321098", "9876543210987":
            return FoodProduct(
                id: barcode,
                name: "Greek Yogurt",
                brand: "Healthy Choice",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 130,
                    protein: 15.0,
                    carbs: 6.0,
                    fat: 5.0,
                    fiber: 0.0,
                    sugar: 6.0,
                    sodium: 65.0,
                    cholesterol: 20.0
                ),
                servingSize: "1 container (170g)",
                category: .dairy
            )
            
        default:
            print("⚠️ Unknown barcode: \(barcode)")
            return FoodProduct(
                id: barcode,
                name: "Unknown Product",
                brand: "Product not found in database",
                barcode: barcode,
                nutrition: NutritionInfo(
                    calories: 0,
                    protein: 0,
                    carbs: 0,
                    fat: 0,
                    fiber: 0,
                    sugar: 0,
                    sodium: 0,
                    cholesterol: 0
                ),
                servingSize: "Please scan nutrition label",
                category: .other
            )
        }
    }
    
    // Clear Data
    func clearData() {
        nutritionInfo = nil
        foodProduct = nil
        errorMessage = nil
    }
    
    // Parse Nutrition Text
    func parseNutritionText(_ text: String) async -> NutritionInfo? {
        // Use MLKitManager to extract nutrition info from text
        let textArray = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        return mlKitManager.extractNutritionInfo(from: textArray)
    }
}

// Food Product Model
struct FoodProduct: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let brand: String
    let barcode: String?
    var nutrition: NutritionInfo
    let servingSize: String
    let category: FoodCategory
    
    // Custom initializer for creating products with optional nutrition values
    init(id: String, name: String, brand: String, barcode: String?, 
         calories: Double?, protein: Double?, carbs: Double?, fat: Double?,
         fiber: Double?, sugar: Double?, sodium: Double?, 
         servingSize: String, category: FoodCategory) {
        self.id = id
        self.name = name
        self.brand = brand
        self.barcode = barcode
        self.nutrition = NutritionInfo(
            calories: calories ?? 0,
            protein: protein ?? 0,
            carbs: carbs ?? 0,
            fat: fat ?? 0,
            fiber: fiber ?? 0,
            sugar: sugar ?? 0,
            sodium: sodium ?? 0,
            cholesterol: 0
        )
        self.servingSize = servingSize
        self.category = category
    }
    
    // Standard initializer
    init(id: String, name: String, brand: String, barcode: String?, 
         nutrition: NutritionInfo, servingSize: String, category: FoodCategory) {
        self.id = id
        self.name = name
        self.brand = brand
        self.barcode = barcode
        self.nutrition = nutrition
        self.servingSize = servingSize
        self.category = category
    }
}

enum FoodCategory: String, CaseIterable, Codable {
    case fruit = "Fruits"
    case vegetable = "Vegetables"
    case protein = "Protein"
    case dairy = "Dairy"
    case grain = "Grains"
    case snack = "Snacks"
    case beverage = "Beverages"
    case other = "Other"
    
    var emoji: String {
        switch self {
        case .fruit: return "🍎"
        case .vegetable: return "🥕"
        case .protein: return "🍗"
        case .dairy: return "🥛"
        case .grain: return "🌾"
        case .snack: return "🍪"
        case .beverage: return "🥤"
        case .other: return "🍽️"
        }
    }
    
    var color: Color {
        switch self {
        case .fruit: return .red
        case .vegetable: return .green
        case .protein: return .orange
        case .dairy: return .blue
        case .grain: return .yellow
        case .snack: return .purple
        case .beverage: return .cyan
        case .other: return .gray
        }
    }
}

//  Extensions
extension NutritionInfo {
    var isEmpty: Bool {
        return calories == 0 && protein == 0 && carbs == 0 && 
               fat == 0 && fiber == 0 && sugar == 0 && sodium == 0
    }
    
    var totalCalories: Int {
        return Int(calories)
    }
    
    var macroSummary: String {
        let p = protein ?? 0
        let c = carbs ?? 0
        let f = fat ?? 0
        return "P: \(String(format: "%.1f", p))g | C: \(String(format: "%.1f", c))g | F: \(String(format: "%.1f", f))g"
    }
}
