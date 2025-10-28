//
//  SettingsView.swift
//  HKFitnessApp
//
//  Created by Roy Dimapilis on 10/25/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var hkManager: HKManager
    @Environment(\.dismiss) var dismiss
    
    @State private var localLowThreshold: Double
    @State private var localHighThreshold: Double
    @State private var localStepGoal: Double
    @State private var localEnergyGoal: Double
    @State private var showingSaved = false
    
    init() {
        _localLowThreshold = State(initialValue: HKManager.shared.lowThreshold)
        _localHighThreshold = State(initialValue: HKManager.shared.highThreshold)
        _localStepGoal = State(initialValue: Double(HKManager.shared.stepGoal))
        _localEnergyGoal = State(initialValue: HKManager.shared.activeEnergyGoal)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
            VStack(spacing: 16) {
                // Heart Rate Thresholds Section
                VStack(spacing: 12) {
                    SectionHeader(icon: "heart.fill", title: "Heart Rate", color: .red)
                    
                    // Low Threshold
                    VStack(spacing: 6) {
                        HStack {
                            Text("Low")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.blue)
                            Spacer()
                            Text("\(Int(localLowThreshold))")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.blue)
                            Text("BPM")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        Slider(value: $localLowThreshold, in: 30...100, step: 1)
                            .tint(.blue)
                    }
                    .padding(10)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // High Threshold
                    VStack(spacing: 6) {
                        HStack {
                            Text("High")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.red)
                            Spacer()
                            Text("\(Int(localHighThreshold))")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.red)
                            Text("BPM")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        Slider(value: $localHighThreshold, in: 100...220, step: 1)
                            .tint(.red)
                    }
                    .padding(10)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Current Status
                    CurrentStatusCard(currentHR: hkManager.currentHeartRate)
                }
                
                // Goals Section
                VStack(spacing: 12) {
                    SectionHeader(icon: "flag.fill", title: "Goals", color: .orange)
                    
                    // Step Goal
                    VStack(spacing: 6) {
                        HStack {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 11))
                                .foregroundColor(.orange)
                            Text("Steps")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.orange)
                            Spacer()
                            Text("\(Int(localStepGoal))")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.orange)
                        }
                        Slider(value: $localStepGoal, in: 1000...20000, step: 100)
                            .tint(.orange)
                    }
                    .padding(10)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Energy Goal
                    VStack(spacing: 6) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.pink)
                            Text("Energy")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.pink)
                            Spacer()
                            Text("\(Int(localEnergyGoal))")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.pink)
                            Text("kcal")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        Slider(value: $localEnergyGoal, in: 100...1000, step: 10)
                            .tint(.pink)
                    }
                    .padding(10)
                    .background(Color.pink.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Save Button
                Button(action: saveSettings) {
                    HStack(spacing: 3) {
                        Image(systemName: showingSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                            .font(.system(size: 10))
                        Text(showingSaved ? "Saved!" : "Save")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(showingSaved ? Color.green : Color.blue)
                    .cornerRadius(8)
                }
                .disabled(showingSaved)
            }
            .padding()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        }
    }
    
    // MARK: - Helper Functions
    
    private func saveSettings() {
        hkManager.lowThreshold = localLowThreshold
        hkManager.highThreshold = localHighThreshold
        hkManager.stepGoal = Int(localStepGoal)
        hkManager.activeEnergyGoal = localEnergyGoal
        
        showingSaved = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showingSaved = false
        }
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
                .fixedSize(horizontal: true, vertical: false)
            Spacer()
        }
    }
}

struct CurrentStatusCard: View {
    let currentHR: Double
    
    var statusColor: Color {
        if currentHR < 60 { return .blue }
        else if currentHR > 100 { return .red }
        else { return .green }
    }
    
    var statusText: String {
        if currentHR < 60 { return "Low" }
        else if currentHR > 100 { return "High" }
        else { return "Normal" }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Current")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
                    .fixedSize()
                Text("\(Int(currentHR))")
                    .font(.system(size: 12, weight: .bold))
                    .fixedSize()
                Text("BPM")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
                    .fixedSize()
            }
            
            Spacer()
            
            Text(statusText)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .cornerRadius(6)
                .fixedSize()
        }
        .padding(10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(HKManager.shared)
        }
    }
}
