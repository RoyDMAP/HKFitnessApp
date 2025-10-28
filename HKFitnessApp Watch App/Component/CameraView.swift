//
//  CameraView.swift
//  HKFitnessApp
//
//  Created by Roy Dimapilis 10/25/25.
//  watchOS Compatible Version
//

import SwiftUI

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var cameraManager = CameraManager.shared
    @State private var showingCapturedConfirmation = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Camera Status
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Camera")
                            .font(.headline)
                        
                        Text("Note: Apple Watch camera functionality is limited. This simulates photo capture.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    // Captured Image Preview
                    if let image = selectedImage {
                        VStack(spacing: 8) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                                .cornerRadius(12)
                            
                            Text("Photo Captured")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Camera Actions
                    VStack(spacing: 12) {
                        // Simulate Photo Capture Button
                        Button(action: simulatePhotoCapture) {
                            Label("Capture Photo", systemImage: "camera")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    
                    // Captured Confirmation
                    if showingCapturedConfirmation {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Photo Captured!")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding(8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Camera on Apple Watch:")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("• Most Apple Watches don't have cameras")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("• This simulates photo capture")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("• Notification confirms capture")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("• Tap 'Close' button above to return")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                cameraManager.requestCameraPermission()
            }
        }
    }
    
    private func simulatePhotoCapture() {
        // Create placeholder image using CameraManager
        if let image = cameraManager.createPlaceholderImage() {
            selectedImage = image
        }
        
        showingCapturedConfirmation = true
        
        // Send notification
        cameraManager.saveImageNotification()
        
        // Hide confirmation after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingCapturedConfirmation = false
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CameraView()
        }
    }
}
