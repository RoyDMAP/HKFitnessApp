//
//  ContentView.swift
//  HKFitnessApp
//
//  Created by Roy Dimapilis on 10/25/25.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject var hkManager: HKManager
    @State private var refreshTimer: Timer?
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
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
                            
                            // Refresh Button
                            Button(action: refreshAllData) {
                                Label("Refresh", systemImage: "arrow.clockwise")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            
                            // Navigation Buttons - Vertical
                            NavigationLink(destination: SettingsView()) {
                                Label("Settings", systemImage: "gear")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            
                            NavigationLink(destination: DetailedStatsView()) {
                                Label("Details", systemImage: "chart.bar.fill")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                                .id("details")
                        } else {
                            AuthorizationView()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("HKFitness")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startAutoRefresh()
            }
            .onDisappear {
                stopAutoRefresh()
            }
        }
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
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            refreshAllData()
        }
    }
    
    private func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HKManager.shared)
    }
}
