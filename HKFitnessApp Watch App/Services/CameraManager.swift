//
//  CameraManager.swift
//  HKFitnessApp
//
//  Created by Assistant
//  watchOS Compatible Version
//

import Foundation
import Combine
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    static let shared = CameraManager()
    
    @Published var isAuthorized = false
    @Published var isCameraAvailable = false
    @Published var capturedImage: UIImage?
    
    private override init() {
        super.init()
        checkCameraAvailability()
    }
    
    func checkCameraAvailability() {
        // Apple Watch typically doesn't have camera
        // This is for demonstration purposes
        isCameraAvailable = true // Simulated availability
        print("📷 Camera simulation mode enabled (watchOS)")
    }
    
    func requestCameraPermission() {
        // Simulate permission grant
        DispatchQueue.main.async {
            self.isAuthorized = true
            print("✅ Camera permission granted (simulated)")
        }
    }
    
    func checkCameraPermission() {
        DispatchQueue.main.async {
            self.isAuthorized = true
        }
    }
    
    // Save image using notification
    func saveImageNotification() {
        NotificationManager.shared.sendPhotoSavedNotification()
        print("✅ Photo captured (saved notification sent)")
    }
    
    // Create a simple placeholder image for watchOS
    func createPlaceholderImage() -> UIImage? {
        let size = CGSize(width: 100, height: 100)
        
        // Use UIGraphicsBeginImageContext for watchOS compatibility
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Fill with blue background (using RGB instead of systemBlue)
        context.setFillColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Add white text
        let text = "Photo" as NSString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
