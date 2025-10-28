//
//  ContentView.swift
//  HKFitnessApp
//
//  Created by Roy Dimapilis on 10/25/25.
//  Updated with Camera and Activity Integration
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject var hkManager: HKManager
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var motionManager = MotionManager.shared
    @State private var refreshTimer: Timer?
    @State private var showCameraSheet = false
    @State private var showSettingsSheet = false
    @State private var showDetailsSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if hkManager.isAuthorized {
                        // Health Metrics Cards
                        HeartRateCard()
                            .id("heartRate")
                        
                        StepsCard()
                            .id("steps")
                        
                        ActiveEnergyCard()
                            .id("energy")
                        
                        // NEW: Activity Card (Core Motion)
                        ActivityCard()
                            .id("activity")
                        
                        // Refresh Button
                        Button(action: refreshAllData) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        
                        // Camera Button - Using fullScreenCover instead of sheet
                        Button(action: {
                            showCameraSheet = true
                        }) {
                            Label("Camera", systemImage: "camera.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .fullScreenCover(isPresented: $showCameraSheet) {
                            CameraView()
                        }
                        
                        // Settings Button - Using fullScreenCover
                        Button(action: {
                            showSettingsSheet = true
                        }) {
                            Label("Settings", systemImage: "gear")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .fullScreenCover(isPresented: $showSettingsSheet) {
                            SettingsView()
                        }
                        
                        // Details Button - Using fullScreenCover
                        Button(action: {
                            showDetailsSheet = true
                        }) {
                            Label("Details", systemImage: "chart.bar.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .fullScreenCover(isPresented: $showDetailsSheet) {
                            DetailedStatsView()
                        }
                            .id("details")
                    } else {
                        AuthorizationView()
                    }
                }
                .padding()
            }
            .navigationTitle("HKFitness")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startAutoRefresh()
                requestNotificationPermission()
                startMotionTracking()
            }
            .onDisappear {
                stopAutoRefresh()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Private Methods
    
    private func refreshAllData() {
        print("🔄 Refresh button tapped!")
        print("📊 Before refresh - HR: \(hkManager.currentHeartRate), Steps: \(hkManager.todayStepCount), Energy: \(hkManager.todayActiveEnergy)")
        hkManager.fetchHeartRate()
        hkManager.fetchStepCount()
        hkManager.fetchActiveEnergy()
        
        // Debug after a short delay to see if data changed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("📊 After refresh - HR: \(self.hkManager.currentHeartRate), Steps: \(self.hkManager.todayStepCount), Energy: \(self.hkManager.todayActiveEnergy)")
        }
    }
    
    private func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            refreshAllData()
        }
    }
    
    private func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func requestNotificationPermission() {
        notificationManager.requestAuthorization()
    }
    
    private func startMotionTracking() {
        if motionManager.isMotionAvailable {
            motionManager.startTracking()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HKManager.shared)
    }
}
