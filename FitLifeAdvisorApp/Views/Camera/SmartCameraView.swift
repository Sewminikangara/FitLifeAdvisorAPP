//
//  SmartCameraView.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.
//

import SwiftUI
import AVFoundation
import UIKit

struct SmartCameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.cameraCaptureMode = .photo
        picker.cameraDevice = .rear
        
        // Configure camera settings for food photography
        if picker.sourceType == .camera {
            picker.cameraFlashMode = .auto
            picker.cameraViewTransform = CGAffineTransform.identity
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: SmartCameraView
        
        init(_ parent: SmartCameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

struct MealCameraView: View {
    @StateObject private var mealAnalysisManager = MealAnalysisManager.shared
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var showingPhotoOptions = false
    @State private var capturedImage: UIImage?
    @State private var showingAnalysis = false
    @State private var cameraPermissionDenied = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Constants.Colors.backgroundGray,
                        Constants.Colors.backgroundGray.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: Constants.Spacing.large) {
                    // Header
                    headerSection
                    
                    Spacer()
                    
                    // Main content
                    if mealAnalysisManager.isAnalyzing {
                        analysisLoadingView
                    } else {
                        captureOptionsView
                    }
                    
                    Spacer()
                    
                    // Recent meals section
                    if !mealAnalysisManager.getMealsForToday().isEmpty {
                        recentMealsSection
                    }
                }
                .padding(Constants.Spacing.large)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Text("Smart Food Analysis")
                    .font(Constants.Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
            )
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(image: $capturedImage)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $capturedImage)
        }
        .confirmationDialog("Choose Photo Source", isPresented: $showingPhotoOptions, titleVisibility: .visible) {
            Button("Take Photo") {
                checkCameraPermissionAndCapture()
            }
            Button("Choose from Library") {
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Select how you'd like to add a photo of your meal for analysis.")
        }
        .fullScreenCover(isPresented: $showingAnalysis) {
            if let image = capturedImage {
                MealAnalysisView(image: image)
            }
        }
        .onChange(of: capturedImage) { image in
            if image != nil {
                showingAnalysis = true
            }
        }
        .alert("Camera Permission Required", isPresented: $cameraPermissionDenied) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow camera access in Settings to capture food photos for analysis.")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            // Icon and title
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Constants.Colors.successGreen.opacity(0.2),
                                    Constants.Colors.successGreen.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "camera.fill")
                        .font(.title)
                        .foregroundColor(Constants.Colors.successGreen)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Food Recognition")
                        .font(Constants.Typography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text("Capture meals for instant nutrition analysis")
                        .font(Constants.Typography.body)
                        .foregroundColor(Constants.Colors.textLight)
                }
                
                Spacer()
            }
            
            // Today's nutrition summary
            if !mealAnalysisManager.getMealsForToday().isEmpty {
                todaysNutritionCard
            }
        }
    }
    
    private var todaysNutritionCard: some View {
        let todaysNutrition = mealAnalysisManager.getTotalNutritionForToday()
        
        return HStack(spacing: Constants.Spacing.medium) {
            NutritionSummaryItem(
                title: "Calories",
                value: "\(Int(todaysNutrition.calories))",
                unit: "kcal",
                color: Constants.Colors.warningOrange
            )
            
            NutritionSummaryItem(
                title: "Protein",
                value: todaysNutrition.formatted(todaysNutrition.protein),
                unit: "g",
                color: Constants.Colors.primaryBlue
            )
            
            NutritionSummaryItem(
                title: "Carbs",
                value: todaysNutrition.formatted(todaysNutrition.carbs),
                unit: "g",
                color: Constants.Colors.successGreen
            )
            
            NutritionSummaryItem(
                title: "Fat",
                value: todaysNutrition.formatted(todaysNutrition.fat),
                unit: "g",
                color: Constants.Colors.errorRed
            )
        }
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    private var captureOptionsView: some View {
        VStack(spacing: Constants.Spacing.large) {
            // Enhanced capture options with equal emphasis
            VStack(spacing: Constants.Spacing.medium) {
                Text("Choose Your Option")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                // Camera and Photo Library buttons side by side
                HStack(spacing: Constants.Spacing.medium) {
                    // Camera button
                    Button(action: {
                        checkCameraPermissionAndCapture()
                    }) {
                        VStack(spacing: Constants.Spacing.small) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Constants.Colors.primaryBlue,
                                                Constants.Colors.primaryBlue.opacity(0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: 100)
                                    .shadow(color: Constants.Colors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Take Photo")
                                .font(Constants.Typography.body)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textDark)
                            
                            Text("Capture new meal")
                                .font(Constants.Typography.caption)
                                .foregroundColor(Constants.Colors.textLight)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Photo library button
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        VStack(spacing: Constants.Spacing.small) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Constants.Colors.successGreen,
                                                Constants.Colors.successGreen.opacity(0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: 100)
                                    .shadow(color: Constants.Colors.successGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Choose Photo")
                                .font(Constants.Typography.body)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textDark)
                            
                            Text("From photo library")
                                .font(Constants.Typography.caption)
                                .foregroundColor(Constants.Colors.textLight)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Additional tips
            VStack(spacing: Constants.Spacing.small) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.warningOrange)
                    
                    Text("Tips for best results:")
                        .font(Constants.Typography.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("•")
                            .foregroundColor(Constants.Colors.textLight)
                        Text("Ensure good lighting and clear view of food")
                            .font(Constants.Typography.small)
                            .foregroundColor(Constants.Colors.textLight)
                        Spacer()
                    }
                    
                    HStack {
                        Text("•")
                            .foregroundColor(Constants.Colors.textLight)
                        Text("Include the entire meal in the frame")
                            .font(Constants.Typography.small)
                            .foregroundColor(Constants.Colors.textLight)
                        Spacer()
                    }
                    
                    HStack {
                        Text("•")
                            .foregroundColor(Constants.Colors.textLight)
                        Text("Keep camera steady for sharp images")
                            .font(Constants.Typography.small)
                            .foregroundColor(Constants.Colors.textLight)
                        Spacer()
                    }
                }
            }
            .padding(Constants.Spacing.medium)
            .background(Constants.Colors.warningOrange.opacity(0.05))
            .cornerRadius(Constants.cornerRadius)
            
            // Quick action button for easy access
            Button(action: {
                showingPhotoOptions = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Quick Add Meal")
                        .font(Constants.Typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, Constants.Spacing.large)
                .padding(.vertical, Constants.Spacing.medium)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Constants.Colors.primaryBlue.opacity(0.8),
                            Constants.Colors.primaryBlue
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: Constants.Colors.primaryBlue.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var analysisLoadingView: some View {
        VStack(spacing: Constants.Spacing.large) {
            // Loading animation
            ZStack {
                Circle()
                    .stroke(Constants.Colors.primaryBlue.opacity(0.2), lineWidth: 8)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Constants.Colors.primaryBlue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(
                        Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: mealAnalysisManager.isAnalyzing
                    )
                
                Image(systemName: "brain.head.profile")
                    .font(.title)
                    .foregroundColor(Constants.Colors.primaryBlue)
            }
            
            VStack(spacing: Constants.Spacing.small) {
                Text("Analyzing Your Meal...")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Text("Identifying ingredients and calculating nutrition")
                    .font(Constants.Typography.body)
                    .foregroundColor(Constants.Colors.textLight)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var recentMealsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Today's Meals")
                    .font(Constants.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textDark)
                
                Spacer()
                
                Text("\(mealAnalysisManager.getMealsForToday().count) meals")
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.textLight)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.medium) {
                    ForEach(mealAnalysisManager.getMealsForToday().prefix(5)) { meal in
                        RecentMealCard(
                            mealImage: meal.recognizedFoods.first?.name.firstEmoji ?? "🍽️",
                            mealName: meal.recognizedFoods.first?.name ?? "Meal",
                            calories: Int(meal.nutritionalSummary.totalCalories),
                            healthScore: meal.nutritionalSummary.healthScore,
                            aiInsight: meal.nutritionalSummary.recommendations.first ?? "Nutritious choice!",
                            timeAgo: DateFormatter.timeAgo.string(from: meal.timestamp)
                        )
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
    
    private func checkCameraPermissionAndCapture() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showingCamera = true
                    } else {
                        cameraPermissionDenied = true
                    }
                }
            }
        case .denied, .restricted:
            cameraPermissionDenied = true
        @unknown default:
            cameraPermissionDenied = true
        }
    }
}

// MARK: - Supporting Views

struct NutritionSummaryItem: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Constants.Typography.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(Constants.Typography.caption)
                .foregroundColor(Constants.Colors.textLight)
            
            Text(unit)
                .font(Constants.Typography.small)
                .foregroundColor(Constants.Colors.textLight)
        }
        .frame(maxWidth: .infinity)
    }
}



// MARK: - Enhanced Image Picker for Photo Library

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true // Enable basic editing
        picker.mediaTypes = ["public.image"]
        
        // Configure for better food photo selection
        if #available(iOS 14.0, *) {
            picker.preferredContentSize = CGSize(width: 400, height: 600)
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Prefer edited image if available, otherwise use original
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}