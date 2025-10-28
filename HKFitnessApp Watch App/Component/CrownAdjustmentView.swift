//
//  CrownAdjustmentView.swift
//  HKFitnessApp
//
//  Created by Roy Dimapilis on 10/25/25.
//

import SwiftUI

struct CrownAdjustmentView: View {
    @EnvironmentObject var hkManager: HKManager
    @Environment(\.dismiss) var dismiss
    
    @State private var stepGoalValue: Double
    @State private var energyGoalValue: Double
    @State private var lowThresholdValue: Double
    @State private var highThresholdValue: Double
    
    @State private var selectedMetric: AdjustableMetric = .stepGoal
    @FocusState private var isFocused: Bool
    
    enum AdjustableMetric: String, CaseIterable {
        case stepGoal = "Step Goal"
        case energyGoal = "Energy Goal"
        case lowThreshold = "Low HR Threshold"
        case highThreshold = "High HR Threshold"
        
        var icon: String {
            switch self {
            case .stepGoal: return "figure.walk"
            case .energyGoal: return "flame.fill"
            case .lowThreshold: return "arrow.down.heart.fill"
            case .highThreshold: return "arrow.up.heart.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .stepGoal: return .orange
            case .energyGoal: return .pink
            case .lowThreshold: return .blue
            case .highThreshold: return .red
            }
        }
    }
    
    init() {
        _stepGoalValue = State(initialValue: Double(HKManager.shared.stepGoal))
        _energyGoalValue = State(initialValue: HKManager.shared.activeEnergyGoal)
        _lowThresholdValue = State(initialValue: HKManager.shared.lowThreshold)
        _highThresholdValue = State(initialValue: HKManager.shared.highThreshold)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Header
            Text("Adjust with Crown")
                .font(.headline)
                .padding(.top)
            
            // Metric Selector
            Picker("Metric", selection: $selectedMetric) {
                ForEach(AdjustableMetric.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 80)
            
            // Current Value Display with Crown Rotation
            VStack(spacing: 8) {
                Image(systemName: selectedMetric.icon)
                    .font(.system(size: 40))
                    .foregroundColor(selectedMetric.color)
                
                Text(currentValueString)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(selectedMetric.color)
                    .focusable()
                    .focused($isFocused)
                    .digitalCrownRotation(
                        currentBinding,
                        from: currentRange.lowerBound,
                        through: currentRange.upperBound,
                        by: currentIncrement,
                        sensitivity: .medium,
                        isContinuous: false,
                        isHapticFeedbackEnabled: true
                    )
                
                Text(unitString)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(selectedMetric.color.opacity(0.1))
            .cornerRadius(15)
            
            // Range Info
            Text("Range: \(Int(currentRange.lowerBound)) - \(Int(currentRange.upperBound))")
                .font(.caption2)
                .foregroundColor(.gray)
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 15) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: saveChanges) {
                    Text("Save")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.bottom)
        }
        .padding()
        .navigationTitle("Crown Adjust")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFocused = true
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentBinding: Binding<Double> {
        switch selectedMetric {
        case .stepGoal: return $stepGoalValue
        case .energyGoal: return $energyGoalValue
        case .lowThreshold: return $lowThresholdValue
        case .highThreshold: return $highThresholdValue
        }
    }
    
    private var currentRange: ClosedRange<Double> {
        switch selectedMetric {
        case .stepGoal: return 1000...30000
        case .energyGoal: return 100...2000
        case .lowThreshold: return 30...100
        case .highThreshold: return 100...220
        }
    }
    
    private var currentIncrement: Double {
        switch selectedMetric {
        case .stepGoal: return 100
        case .energyGoal: return 10
        case .lowThreshold: return 1
        case .highThreshold: return 1
        }
    }
    
    private var currentValueString: String {
        switch selectedMetric {
        case .stepGoal: return "\(Int(stepGoalValue))"
        case .energyGoal: return "\(Int(energyGoalValue))"
        case .lowThreshold: return "\(Int(lowThresholdValue))"
        case .highThreshold: return "\(Int(highThresholdValue))"
        }
    }
    
    private var unitString: String {
        switch selectedMetric {
        case .stepGoal: return "steps"
        case .energyGoal: return "kcal"
        case .lowThreshold: return "BPM"
        case .highThreshold: return "BPM"
        }
    }
    
    // MARK: - Actions
    
    private func saveChanges() {
        hkManager.stepGoal = Int(stepGoalValue)
        hkManager.activeEnergyGoal = energyGoalValue
        hkManager.updateThresholds(low: lowThresholdValue, high: highThresholdValue)
        dismiss()
    }
}

struct CrownAdjustmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CrownAdjustmentView()
                .environmentObject(HKManager.shared)
        }
    }
}
