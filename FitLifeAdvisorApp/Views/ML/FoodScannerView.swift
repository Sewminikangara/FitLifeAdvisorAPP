//
//  FoodScannerView.swift
//  FitLifeAdvisorApp
//
//  ML-powered food scanning with barcode and nutrition label recognition
//

import SwiftUI
import AVFoundation
import Photos

struct FoodScannerView: View {
    @StateObject private var foodService = FoodRecognitionService()
    @StateObject private var mlKitManager = MLKitManager()
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var scanMode: ScanMode = .barcode
    @State private var showingResult = false
    @State private var showingPermissionAlert = false
    @State private var permissionMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    enum ScanMode: String, CaseIterable {
        case barcode = "Barcode"
        case nutritionLabel = "Nutrition Label"
        
        var icon: String {
            switch self {
            case .barcode: return "barcode.viewfinder"
            case .nutritionLabel: return "doc.text.viewfinder"
            }
        }
        
        var description: String {
            switch self {
            case .barcode: return "Scan product barcode for nutrition info"
            case .nutritionLabel: return "Scan nutrition facts label"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: Constants.Spacing.large) {
                // Header
                VStack(spacing: Constants.Spacing.medium) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Constants.Colors.primaryBlue)
                    
                    Text("Smart Food Scanner")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    Text("Use AI to quickly log food nutrition")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textLight)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Constants.Spacing.large)
                
                // Scan Mode Selector
                VStack(spacing: Constants.Spacing.medium) {
                    Text("Select Scan Mode")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Constants.Colors.textDark)
                    
                    HStack(spacing: Constants.Spacing.medium) {
                        ForEach(ScanMode.allCases, id: \.self) { mode in
                            FoodScanModeButton(
                                mode: mode,
                                isSelected: scanMode == mode
                            ) {
                                scanMode = mode
                            }
                        }
                    }
                }
                .padding(.horizontal, Constants.Spacing.large)
                
                // Description
                Text(scanMode.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Spacing.large)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: Constants.Spacing.medium) {
                    // Camera Button
                    Button(action: {
                        checkCameraPermission()
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Take Photo")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Constants.Spacing.medium)
                        .background(Constants.Colors.primaryBlue)
                        .cornerRadius(12)
                    }
                    
                    // Gallery Button
                    Button(action: {
                        checkPhotoLibraryPermission()
                    }) {
                        HStack {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Choose from Gallery")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(Constants.Colors.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Constants.Spacing.medium)
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Constants.Colors.primaryBlue, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, Constants.Spacing.large)
                
                Spacer()
                
                // Loading State
                if foodService.isLoading || mlKitManager.isProcessing {
                    VStack(spacing: Constants.Spacing.medium) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(Constants.Colors.primaryBlue)
                        
                        Text("Processing image...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Constants.Colors.textLight)
                    }
                    .padding(.bottom, Constants.Spacing.large)
                }
                
                // Error Message
                if let errorMessage = foodService.errorMessage ?? mlKitManager.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Constants.Colors.errorRed)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Constants.Spacing.large)
                        .padding(.bottom, Constants.Spacing.large)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: foodService.foodProduct) { product in
                if product != nil {
                    showingResult = true
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView(onImageCaptured: { image in
                    selectedImage = image
                    processImage(image)
                })
            }
            .sheet(isPresented: $showingImagePicker) {
                FoodImagePicker(onImageSelected: { image in
                    selectedImage = image
                    processImage(image)
                })
            }
            .sheet(isPresented: $showingResult) {
                if let product = foodService.foodProduct {
                    FoodProductResultView(
                        product: product,
                        onAddToLog: { product in
                            // Add to meal log
                            addToMealLog(product: product)
                            dismiss()
                        },
                        onDismiss: {
                            showingResult = false
                            foodService.clearData()
                        }
                    )
                }
            }
        }
        .alert("Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(permissionMessage)
        }
    }
    
    // MARK: - Process Image
    private func processImage(_ image: UIImage) {
        print("🎯 Processing image with mode: \(scanMode.rawValue)")
        
        switch scanMode {
        case .barcode:
            print("📱 Starting barcode scan...")
            mlKitManager.scanBarcode(from: image) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let barcode):
                        print("✅ Barcode found: \(barcode)")
                        Task {
                            await self.foodService.fetchFoodProduct(barcode: barcode)
                            DispatchQueue.main.async {
                                if self.foodService.foodProduct != nil {
                                    print("✅ Product found in database")
                                    self.showingResult = true
                                } else {
                                    print("❌ Product not found in database")
                                }
                            }
                        }
                    case .failure(let error):
                        print("❌ Barcode scan failed: \(error.localizedDescription)")
                        // Error handled in ML Kit Manager
                    }
                }
            }
            
        case .nutritionLabel:
            print("📄 Starting nutrition label scan...")
            foodService.scanNutritionLabel(image: image)
        }
    }
    
    // MARK: - Add to Meal Log
    private func addToMealLog(product: FoodProduct) {
        // This would integrate with your existing meal logging system
        print("Adding to meal log: \(product.name)")
        // TODO: Integrate with MealAnalysisManager or existing logging system
    }
    
    // MARK: - Permission Checking
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.showingCamera = true
                    } else {
                        self.permissionMessage = "Camera access is required to scan barcodes and nutrition labels. Please enable camera access in Settings."
                        self.showingPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            permissionMessage = "Camera access is required to scan barcodes and nutrition labels. Please enable camera access in Settings."
            showingPermissionAlert = true
        @unknown default:
            permissionMessage = "Camera access is required to scan barcodes and nutrition labels. Please enable camera access in Settings."
            showingPermissionAlert = true
        }
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            showingImagePicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited:
                        self.showingImagePicker = true
                    case .denied, .restricted:
                        self.permissionMessage = "Photo library access is required to select images for scanning. Please enable photo access in Settings."
                        self.showingPermissionAlert = true
                    @unknown default:
                        self.permissionMessage = "Photo library access is required to select images for scanning. Please enable photo access in Settings."
                        self.showingPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            permissionMessage = "Photo library access is required to select images for scanning. Please enable photo access in Settings."
            showingPermissionAlert = true
        @unknown default:
            permissionMessage = "Photo library access is required to select images for scanning. Please enable photo access in Settings."
            showingPermissionAlert = true
        }
    }
}

// MARK: - Food Scanner Mode Button
struct FoodScanModeButton: View {
    let mode: FoodScannerView.ScanMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Constants.Spacing.small) {
                Image(systemName: mode.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? .white : Constants.Colors.primaryBlue)
                
                Text(mode.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : Constants.Colors.primaryBlue)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.Spacing.medium)
            .background(isSelected ? Constants.Colors.primaryBlue : .white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Constants.Colors.primaryBlue, lineWidth: 2)
            )
            .cornerRadius(12)
        }
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Image Picker
// MARK: - Food Scanner Image Picker
struct FoodImagePicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: FoodImagePicker
        
        init(_ parent: FoodImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    FoodScannerView()
}
