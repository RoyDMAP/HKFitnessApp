//
//  HKFitnessAppApp.swift
//  HKFitnessApp Watch App
//
//  Created by Roy Dimapilis on 10/27/25.
//

import SwiftUI
import HealthKit

@main
struct HKFitnessApp: App {
    @StateObject private var hkManager = HKManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(hkManager)
        }
    }
}
