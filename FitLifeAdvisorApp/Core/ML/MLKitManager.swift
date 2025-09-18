//
//  MLKitManager.swift
//  FitLifeAdvisorApp
//
//

import SwiftUI
import AVFoundation
import Vision

// MARK: - ML Kit Manager
@MainActor
class MLKitManager: ObservableObject {
    @Published var isProcessing = false
    @Published var lastResult: MLResult?
    @Published var errorMessage: String?
    
    init() {}
}

// MARK: - ML Result Types
enum MLResultType {
    case barcode
    case text
    case pose
    case foodLabel
}

struct MLResult {
    let type: MLResultType
    let data: Any
    let confidence: Float
    let timestamp: Date
}

enum MLKitResult {
    case barcodes([String])
    case text([String])
    case pose(PoseData)
    case foodLabel([String])
}

// MARK: - Data Models
struct PoseData {
    let landmarks: [CGPoint]
    let confidence: Float
    let exerciseType: ExerciseType?
    let formScore: Float?
}

enum ExerciseType {
    case pushup
    case squat
    case plank
    case bicepCurl
    case unknown
}

// MARK: - ML Kit Error Types
enum MLKitError: Error {
    case invalidImage
    case processingFailed
    case noResultsFound
    case permissionDenied
    
    var localizedDescription: String {
        switch self {
        case .invalidImage:
            return "Invalid image provided for analysis"
        case .processingFailed:
            return "ML processing failed"
        case .noResultsFound:
            return "No results found in image"
        case .permissionDenied:
            return "Camera or photo library permission denied"
        }
    }
}

// MARK: - ML Kit Extensions
extension MLKitManager {
    
    // MARK: - Barcode Scanning
    func scanBarcode(from image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        isProcessing = true
        errorMessage = nil
        
        print("🔍 Starting barcode scan...")
        
        // Create vision request for barcode detection with enhanced symbologies
        let request = VNDetectBarcodesRequest { request, error in
            DispatchQueue.main.async {
                self.isProcessing = false
                
                if let error = error {
                    self.errorMessage = "Barcode scanning failed: \(error.localizedDescription)"
                    print("❌ Barcode scan error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let results = request.results as? [VNBarcodeObservation] else {
                    let error = NSError(domain: "MLKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "No barcode observations found"])
                    self.errorMessage = "No barcode detected in image"
                    print("❌ No barcode observations found")
                    completion(.failure(error))
                    return
                }
                
                print("📊 Found \(results.count) barcode observations")
                
                // Try to find a valid barcode from all detections
                for (index, barcode) in results.enumerated() {
                    print("🔍 Barcode \(index + 1): Type = \(barcode.symbology), Confidence = \(barcode.confidence)")
                    
                    if let barcodeString = barcode.payloadStringValue, !barcodeString.isEmpty {
                        print("✅ Found valid barcode: \(barcodeString)")
                        
                        self.lastResult = MLResult(
                            type: .barcode,
                            data: barcodeString,
                            confidence: barcode.confidence,
                            timestamp: Date()
                        )
                        
                        completion(.success(barcodeString))
                        return
                    }
                }
                
                let error = NSError(domain: "MLKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "No valid barcode payload found"])
                self.errorMessage = "Could not read barcode data. Please try a clearer image."
                print("❌ No valid barcode payload found in \(results.count) detections")
                completion(.failure(error))
            }
        }
        
        // Configure supported barcode types
        request.symbologies = [
            .upce,
            .code39,
            .code39Checksum,
            .code39FullASCII,
            .code39FullASCIIChecksum,
            .code93,
            .code93i,
            .code128,
            .dataMatrix,
            .ean8,
            .ean13,
            .i2of5,
            .i2of5Checksum,
            .itf14,
            .pdf417,
            .qr,
            .aztec
        ]
        
        // Process image
        guard let cgImage = image.cgImage else {
            isProcessing = false
            let error = NSError(domain: "MLKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid image format"])
            print("❌ Invalid image format")
            completion(.failure(error))
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = "Image processing failed: \(error.localizedDescription)"
                    print("❌ Vision processing failed: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Text Recognition
    func recognizeText(from image: UIImage, completion: @escaping (Result<[String], Error>) -> Void) {
        isProcessing = true
        errorMessage = nil
        
        print("🔍 Starting text recognition...")
        
        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                self.isProcessing = false
                
                if let error = error {
                    self.errorMessage = "Text recognition failed: \(error.localizedDescription)"
                    print("❌ Text recognition error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let results = request.results as? [VNRecognizedTextObservation] else {
                    let error = NSError(domain: "MLKit", code: 3, userInfo: [NSLocalizedDescriptionKey: "No text found"])
                    print("❌ No text observations found")
                    completion(.failure(error))
                    return
                }
                
                let recognizedText = results.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                
                print("📄 Recognized \(recognizedText.count) text lines:")
                for (index, text) in recognizedText.enumerated() {
                    print("  \(index + 1): \(text)")
                }
                
                if recognizedText.isEmpty {
                    let error = NSError(domain: "MLKit", code: 3, userInfo: [NSLocalizedDescriptionKey: "No readable text found"])
                    self.errorMessage = "No readable text found in image"
                    print("❌ No readable text extracted")
                    completion(.failure(error))
                    return
                }
                
                self.lastResult = MLResult(
                    type: .text,
                    data: recognizedText,
                    confidence: 0.8, // Average confidence
                    timestamp: Date()
                )
                
                completion(.success(recognizedText))
            }
        }
        
        // Configure for better accuracy with nutrition labels
        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true
        
        guard let cgImage = image.cgImage else {
            isProcessing = false
            let error = NSError(domain: "MLKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid image format"])
            print("❌ Invalid image format")
            completion(.failure(error))
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = "Image processing failed: \(error.localizedDescription)"
                    print("❌ Vision text processing failed: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Extract Nutrition Info from Text
    func extractNutritionInfo(from text: [String]) -> NutritionInfo {
        print("🔍 Extracting nutrition from text: \(text.joined(separator: " | "))")
        
        var calories: Int?
        var protein: Double?
        var carbs: Double?
        var fat: Double?
        var fiber: Double?
        var sugar: Double?
        var sodium: Double?
        
        let fullText = text.joined(separator: " ").lowercased()
        
        // Enhanced patterns for nutrition facts extraction
        let patterns: [String: [String]] = [
            "calories": [
                #"calories?\s*:?\s*(\d+)"#,
                #"(\d+)\s*cal(?:ories)?"#,
                #"energy\s*:?\s*(\d+)"#,
                #"(\d+)\s*kcal"#,
                #"cal(?:ories)?\s*(\d+)"#
            ],
            "protein": [
                #"protein\s*:?\s*(\d+(?:\.\d+)?)\s*g"#,
                #"protein\s*(\d+(?:\.\d+)?)"#,
                #"(\d+(?:\.\d+)?)\s*g\s*protein"#,
                #"total\s*protein\s*:?\s*(\d+(?:\.\d+)?)"#
            ],
            "carbs": [
                #"(?:total\s*)?carb(?:ohydrate)?s?\s*:?\s*(\d+(?:\.\d+)?)\s*g"#,
                #"carb(?:ohydrate)?s?\s*(\d+(?:\.\d+)?)"#,
                #"(\d+(?:\.\d+)?)\s*g\s*carb"#,
                #"total\s*carb\w*\s*:?\s*(\d+(?:\.\d+)?)"#
            ],
            "fat": [
                #"(?:total\s*)?fat\s*:?\s*(\d+(?:\.\d+)?)\s*g"#,
                #"total\s*fat\s*(\d+(?:\.\d+)?)"#,
                #"fat\s*(\d+(?:\.\d+)?)"#,
                #"(\d+(?:\.\d+)?)\s*g\s*fat"#
            ],
            "fiber": [
                #"(?:dietary\s*)?fiber\s*:?\s*(\d+(?:\.\d+)?)\s*g"#,
                #"fiber\s*(\d+(?:\.\d+)?)"#,
                #"dietary\s*fiber\s*(\d+(?:\.\d+)?)"#,
                #"fibre\s*:?\s*(\d+(?:\.\d+)?)"#
            ],
            "sugar": [
                #"(?:total\s*)?sugars?\s*:?\s*(\d+(?:\.\d+)?)\s*g"#,
                #"sugars?\s*(\d+(?:\.\d+)?)"#,
                #"(\d+(?:\.\d+)?)\s*g\s*sugar"#
            ],
            "sodium": [
                #"sodium\s*:?\s*(\d+(?:\.\d+)?)\s*mg"#,
                #"sodium\s*(\d+(?:\.\d+)?)"#,
                #"(\d+(?:\.\d+)?)\s*mg\s*sodium"#,
                #"salt\s*:?\s*(\d+(?:\.\d+)?)"#
            ]
        ]
        
        // Extract each nutrient using multiple patterns
        for (nutrient, nutrientPatterns) in patterns {
            for pattern in nutrientPatterns {
                if let value = extractNutrientValue(from: fullText, patterns: [pattern]) {
                    print("✅ Found \(nutrient): \(value)")
                    switch nutrient {
                    case "calories":
                        calories = Int(value)
                    case "protein":
                        protein = value
                    case "carbs":
                        carbs = value
                    case "fat":
                        fat = value
                    case "fiber":
                        fiber = value
                    case "sugar":
                        sugar = value
                    case "sodium":
                        sodium = value
                    default:
                        break
                    }
                    break // Found value for this nutrient, move to next
                }
            }
        }
        
        // Alternative extraction for individual lines
        for line in text {
            let lowercasedLine = line.lowercased()
            
            // Extract calories if not found yet
            if calories == nil {
                if lowercasedLine.contains("calorie") || lowercasedLine.contains("kcal") {
                    calories = extractNumber(from: line)
                }
            }
            
            // Extract protein if not found yet
            if protein == nil && lowercasedLine.contains("protein") {
                protein = extractDecimalNumber(from: line)
            }
            
            // Extract carbs if not found yet
            if carbs == nil && (lowercasedLine.contains("carbohydrate") || lowercasedLine.contains("carbs")) {
                carbs = extractDecimalNumber(from: line)
            }
            
            // Extract fat if not found yet
            if fat == nil && lowercasedLine.contains("fat") && !lowercasedLine.contains("saturated") {
                fat = extractDecimalNumber(from: line)
            }
            
            // Extract fiber if not found yet
            if fiber == nil && (lowercasedLine.contains("fiber") || lowercasedLine.contains("fibre")) {
                fiber = extractDecimalNumber(from: line)
            }
            
            // Extract sugar if not found yet
            if sugar == nil && lowercasedLine.contains("sugar") {
                sugar = extractDecimalNumber(from: line)
            }
            
            // Extract sodium if not found yet
            if sodium == nil && lowercasedLine.contains("sodium") {
                sodium = extractDecimalNumber(from: line)
            }
        }
        
        let result = NutritionInfo(
            calories: Double(calories ?? 0),
            protein: protein ?? 0,
            carbs: carbs ?? 0,
            fat: fat ?? 0,
            fiber: fiber ?? 0,
            sugar: sugar ?? 0,
            sodium: sodium ?? 0,
            cholesterol: 0
        )
        
        print("📊 Extracted nutrition: \(result.calories) cal, \(result.carbs)g carbs, \(result.protein)g protein, \(result.fat)g fat")
        
        return result
    }
    
    // MARK: - Helper Methods
    private func extractNumber(from text: String) -> Int? {
        let numbers = text.components(separatedBy: CharacterSet.decimalDigits.inverted)
        for number in numbers {
            if let int = Int(number), !number.isEmpty {
                return int
            }
        }
        return nil
    }
    
    private func extractDecimalNumber(from text: String) -> Double? {
        let regex = try? NSRegularExpression(pattern: "\\d+\\.?\\d*", options: [])
        let range = NSRange(location: 0, length: text.count)
        
        if let match = regex?.firstMatch(in: text, options: [], range: range) {
            let matchString = (text as NSString).substring(with: match.range)
            return Double(matchString)
        }
        
        return nil
    }
    
    private func extractNutrientValue(from text: String, patterns: [String]) -> Double? {
        for pattern in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                let range = NSRange(location: 0, length: text.count)
                
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    // Extract the captured group (the number)
                    if match.numberOfRanges > 1 {
                        let numberRange = match.range(at: 1)
                        if numberRange.location != NSNotFound {
                            let numberString = (text as NSString).substring(with: numberRange)
                            return Double(numberString)
                        }
                    }
                }
            } catch {
                continue // Try next pattern if regex fails
            }
        }
        return nil
    }
    
    // MARK: - Meal Photo Analysis
    func analyzeMealPhoto(_ image: UIImage, completion: @escaping (Result<NutritionInfo, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(MLKitError.invalidImage))
            return
        }
        
        isProcessing = true
        
        // Use text recognition to find any nutrition labels in the meal photo
        let request = VNRecognizeTextRequest { [weak self] request, error in
            DispatchQueue.main.async {
                self?.isProcessing = false
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    // No text found, provide meal estimation
                    completion(.success(self?.estimateMealNutrition(from: image) ?? NutritionInfo.defaultMeal))
                    return
                }
                
                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                // Try to extract nutrition from recognized text
                if let nutrition = self?.parseNutritionFromMealText(recognizedText) {
                    completion(.success(nutrition))
                } else {
                    // Fallback to meal estimation
                    completion(.success(self?.estimateMealNutrition(from: image) ?? NutritionInfo.defaultMeal))
                }
            }
        }
        
        request.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func parseNutritionFromMealText(_ text: String) -> NutritionInfo? {
        let lowercasedText = text.lowercased()
        
        // Look for nutrition facts patterns with improved regex
        var calories: Double = 0
        var carbs: Double = 0
        var protein: Double = 0
        var fat: Double = 0
        var fiber: Double = 0
        var sodium: Double = 0
        var sugar: Double = 0
        
        // Improved calorie extraction patterns
        if let cal = extractNutrientValue(from: lowercasedText, patterns: [
            #"calories?\s*:?\s*(\d+(?:\.\d+)?)"#,
            #"(\d+(?:\.\d+)?)\s*cal(?:ories)?"#,
            #"energy\s*:?\s*(\d+(?:\.\d+)?)\s*(?:kcal|cal)"#,
            #"(\d+(?:\.\d+)?)\s*kcal"#,
            #"total\s*calories?\s*:?\s*(\d+(?:\.\d+)?)"#
        ]) {
            calories = cal
        }
        
        // Improved carbohydrate extraction
        if let carb = extractNutrientValue(from: lowercasedText, patterns: [
            #"(?:total\s*)?carb(?:ohydrate)?s?\s*:?\s*(\d+(?:\.\d+)?)\s*g"#,
            #"carb(?:ohydrate)?s?\s*(\d+(?:\.\d+)?)"#,
            #"total\s*carb\w*\s*:?\s*(\d+(?:\.\d+)?)"#
        ]) {
            carbs = carb
        }
        
        // Improved protein extraction
        if let prot = extractNutrientValue(from: lowercasedText, patterns: [
            #"(?:total\s*)?protein\s*:?\s*(\d+(?:\.\d+)?)\s*g"#,
            #"protein\s*(\d+(?:\.\d+)?)"#,
            #"total\s*protein\s*:?\s*(\d+(?:\.\d+)?)"#
        ]) {
            protein = prot
        }
        
        // Improved fat extraction
        if let fatValue = extractNutrientValue(from: lowercasedText, patterns: [
            #"(?:total\s*)?fat\s*:?\s*(\d+(?:\.\d+)?)\s*g"#,
            #"total\s*fat\s*:?\s*(\d+(?:\.\d+)?)"#,
            #"fat\s*(\d+(?:\.\d+)?)"#
        ]) {
            fat = fatValue
        }
        
        // Improved fiber extraction
        if let fiberValue = extractNutrientValue(from: lowercasedText, patterns: [
            #"(?:dietary\s*)?fiber\s*:?\s*(\d+(?:\.\d+)?)\s*g"#,
            #"fiber\s*(\d+(?:\.\d+)?)"#,
            #"dietary\s*fiber\s*:?\s*(\d+(?:\.\d+)?)"#,
            #"fibre\s*:?\s*(\d+(?:\.\d+)?)"#
        ]) {
            fiber = fiberValue
        }
        
        // Improved sodium extraction
        if let sodiumValue = extractNutrientValue(from: lowercasedText, patterns: [
            #"sodium\s*:?\s*(\d+(?:\.\d+)?)\s*mg"#,
            #"sodium\s*(\d+(?:\.\d+)?)"#,
            #"salt\s*:?\s*(\d+(?:\.\d+)?)"#
        ]) {
            sodium = sodiumValue
        }
        
        // Sugar extraction
        if let sugarValue = extractNutrientValue(from: lowercasedText, patterns: [
            #"(?:total\s*)?sugar\s*:?\s*(\d+(?:\.\d+)?)\s*g"#,
            #"sugar\s*(\d+(?:\.\d+)?)"#,
            #"sugars\s*:?\s*(\d+(?:\.\d+)?)"#
        ]) {
            sugar = sugarValue
        }
        
        // Return nutrition info if we found meaningful data
        if calories > 0 || (carbs + protein + fat) > 5 {
            return NutritionInfo(
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                sugar: sugar,
                sodium: sodium,
                cholesterol: 0 // Not typically extracted from meal photos
            )
        }
        
        return nil
    }
    
    private func estimateMealNutrition(from image: UIImage) -> NutritionInfo {
        // Create more varied estimates based on image characteristics
        let imageArea = image.size.width * image.size.height
        let normalizedArea = min(imageArea / (500 * 500), 2.0)
        
        // Add some randomness based on image hash for consistent but varied results
        let imageHash = image.pngData()?.hashValue ?? 0
        let variance = Double(abs(imageHash) % 200) - 100.0 // -100 to +100
        
        // Base calories with variance
        let baseCalories = 350.0 + variance
        let estimatedCalories = baseCalories * Double(normalizedArea)
        
        // Add meal type detection based on image brightness/color analysis
        let mealTypeMultiplier = analyzeMealType(image: image)
        
        let finalCalories = min(max(estimatedCalories * mealTypeMultiplier, 150), 900)
        
        return NutritionInfo(
            calories: finalCalories,
            protein: (finalCalories * 0.25) / 4, // 25% calories from protein  
            carbs: (finalCalories * 0.45) / 4, // 45% calories from carbs
            fat: (finalCalories * 0.30) / 9, // 30% calories from fat
            fiber: Double.random(in: 3...8), // Variable fiber content
            sugar: Double.random(in: 5...15), // Variable sugar content
            sodium: Double.random(in: 400...800), // Variable sodium content
            cholesterol: Double.random(in: 20...80) // Variable cholesterol content
        )
    }
    
    private func analyzeMealType(image: UIImage) -> Double {
        // Simple brightness analysis to estimate meal type
        guard let cgImage = image.cgImage else { return 1.0 }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(data: nil,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: bitsPerComponent,
                                    bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
            return 1.0
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return 1.0 }
        
        let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        var totalBrightness: CGFloat = 0
        let pixelCount = width * height
        
        for i in stride(from: 0, to: pixelCount * bytesPerPixel, by: bytesPerPixel) {
            let r = CGFloat(buffer[i]) / 255.0
            let g = CGFloat(buffer[i + 1]) / 255.0
            let b = CGFloat(buffer[i + 2]) / 255.0
            
            // Calculate brightness using luminance formula
            let brightness = 0.299 * r + 0.587 * g + 0.114 * b
            totalBrightness += brightness
        }
        
        let averageBrightness = totalBrightness / CGFloat(pixelCount)
        
        // Adjust multiplier based on brightness (darker foods might be heartier)
        if averageBrightness < 0.3 {
            return 1.3 // Darker foods - potentially heartier meals
        } else if averageBrightness > 0.7 {
            return 0.8 // Lighter foods - potentially lighter meals
        } else {
            return 1.0 // Medium brightness - normal meal
        }
    }
}

// MARK: - NutritionInfo Extension
extension NutritionInfo {
    static let defaultMeal = NutritionInfo(
        calories: 400,
        protein: 20,
        carbs: 45,
        fat: 15,
        fiber: 6,
        sugar: 10,
        sodium: 650,
        cholesterol: 45
    )
}
