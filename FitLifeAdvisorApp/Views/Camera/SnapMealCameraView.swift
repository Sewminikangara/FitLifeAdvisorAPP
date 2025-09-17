//
//  SnapMealCameraView.swift
//  FitLifeAdvisorApp
//
//  created by Sewmini 010 on 2025-08-28.
//

import SwiftUI
import AVFoundation
import UIKit

struct SnapMealCameraView: View {
    @StateObject private var aiService = AIFoodRecognitionService()
    @StateObject private var cameraManager = CameraManager()
    @State private var capturedImage: UIImage?
    @State private var showingResults = false
    @State private var showingPermissionAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreviewView(cameraManager: cameraManager)
                .edgesIgnoringSafeArea(.all)
            
            // Dark overlay for better UI visibility
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Top Bar
                topBar
                
                Spacer()
                
                // AI Detection Overlay
                if aiService.isAnalyzing {
                    analysisOverlay
                }
                
                Spacer()
                
                // Bottom Controls
                bottomControls
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            requestCameraPermission()
        }
        .sheet(isPresented: $showingResults) {
            if let image = capturedImage {
                MealAnalysisResultsView(
                    capturedImage: image,
                    aiService: aiService
                )
            }
        }
        .alert("Camera Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Please enable camera access in Settings to use the Snap Meal feature.")
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // Close Button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Title
            VStack {
                Text("Snap Meal")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("AI-Powered Food Analysis")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Flash Toggle
            Button(action: { cameraManager.toggleFlash() }) {
                Image(systemName: cameraManager.isFlashOn ? "bolt.fill" : "bolt.slash")
                    .font(.title2)
                    .foregroundColor(cameraManager.isFlashOn ? .yellow : .white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Analysis Overlay
    private var analysisOverlay: some View {
        VStack(spacing: 20) {
            // AI Scanning Animation
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(aiService.analysisProgress * 360))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: aiService.isAnalyzing)
                
                Image(systemName: "brain")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            // Analysis Status
            VStack(spacing: 8) {
                Text("AI Analyzing Your Meal...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Identifying foods and calculating nutrition")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                // Progress Bar
                ProgressView(value: aiService.analysisProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .frame(width: 200)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.7))
                .blur(radius: 0.5)
        )
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: 30) {
            // Instructions
            if !aiService.isAnalyzing {
                instructionsCard
            }
            
            // Camera Controls
            HStack(spacing: 50) {
                // Gallery Button
                Button(action: selectFromGallery) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                
                // Capture Button
                Button(action: capturePhoto) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .stroke(Color.white, lineWidth: 6)
                            .frame(width: 100, height: 100)
                        
                        if aiService.isAnalyzing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        }
                    }
                }
                .scaleEffect(aiService.isAnalyzing ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: aiService.isAnalyzing)
                .disabled(aiService.isAnalyzing)
                
                // Switch Camera
                Button(action: { cameraManager.switchCamera() }) {
                    Image(systemName: "camera.rotate")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.bottom, 50)
    }
    
    // MARK: - Instructions Card
    private var instructionsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.yellow)
                Text("Tips for Best Results")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                instructionRow(icon: "camera", text: "Hold steady and ensure good lighting")
                instructionRow(icon: "viewfinder", text: "Frame your entire meal in the shot")
                instructionRow(icon: "hand.raised", text: "Keep hands and utensils out of frame")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.6))
        )
        .padding(.horizontal)
    }
    
    private func instructionRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    // MARK: - Functions
    private func requestCameraPermission() {
        cameraManager.requestPermission { granted in
            if !granted {
                showingPermissionAlert = true
            }
        }
    }
    
    private func capturePhoto() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        cameraManager.capturePhoto { image in
            if let image = image {
                capturedImage = image
                Task {
                    await aiService.analyzeMealFromImage(image)
                    showingResults = true
                }
            }
        }
    }
    
    private func selectFromGallery() {
        // Implementation for photo picker would go here
        print("📸 Select from gallery")
    }
}

// MARK: - Camera Manager
class CameraManager: NSObject, ObservableObject {
    @Published var isFlashOn = false
    @Published var session = AVCaptureSession()
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    private var currentCamera: AVCaptureDevice.Position = .back
    private var photoCompletionHandler: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
        setupSession()
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    private func setupSession() {
        session.beginConfiguration()
        
        // Add video input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // Add photo output
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.isHighResolutionCaptureEnabled = true
        }
        
        session.commitConfiguration()
        
        // Create preview layer
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        photoCompletionHandler = completion
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
        
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
    
    func switchCamera() {
        session.beginConfiguration()
        
        // Remove current input
        session.inputs.forEach { session.removeInput($0) }
        
        // Switch position
        currentCamera = currentCamera == .back ? .front : .back
        
        // Add new input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCamera),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        session.commitConfiguration()
    }
}

// MARK: - Camera Manager Photo Delegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoCompletionHandler?(nil)
            return
        }
        
        photoCompletionHandler?(image)
        photoCompletionHandler = nil
    }
}

// MARK: - Camera Preview View
struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        DispatchQueue.main.async {
            if let preview = cameraManager.preview {
                preview.frame = view.bounds
                view.layer.addSublayer(preview)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let preview = cameraManager.preview {
            preview.frame = uiView.bounds
        }
    }
}

#Preview {
    SnapMealCameraView()
}
