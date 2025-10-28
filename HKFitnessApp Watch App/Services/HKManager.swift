//
//  HKManager.swift
//  HKFitnessApp
//
//  Created by Roy Dimapilis on 10/25/25.
//

import Foundation
import HealthKit
import Combine
import SwiftUI

class HKManager: ObservableObject {
    static let shared = HKManager()
    private var healthStore = HKHealthStore()
    
    @Published var heartRate: [HKQuantitySample] = []
    @Published var stepCount: [HKQuantitySample] = []
    @Published var activeEnergy: [HKQuantitySample] = []
    
    // Computed properties for UI
    @Published var isAuthorized = false
    @Published var lowThreshold: Double = 50
    @Published var highThreshold: Double = 120
    @Published var stepGoal: Int = 10000
    @Published var activeEnergyGoal: Double = 500
    
    private init() {
        self.requestAuthorization()
    }
    
    func requestAuthorization() {
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        // Including step count in write permissions for simulator testing
        let typesToWrite: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success {
                    self.fetchHeartRate()
                    self.fetchStepCount()
                    self.fetchActiveEnergy()
                } else {
                    print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    // MARK: - Heart Rate
    
    func fetchHeartRate() {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 500, sortDescriptors: [NSSortDescriptor(key: "startDate", ascending: true)]) { _, samples, _ in
            DispatchQueue.main.async {
                self.heartRate = (samples as? [HKQuantitySample]) ?? []
            }
        }
        
        healthStore.execute(query)
    }
    
    func addHeartRate(_ bpm: Double) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        let quantity = HKQuantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()), doubleValue: bpm)
        let now = Date()
        let sample = HKQuantitySample(type: sampleType, quantity: quantity, start: now, end: now)
        
        healthStore.save(sample) { success, error in
            if success {
                self.fetchHeartRate()
            } else {
                print("Failed to save heart rate: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Step Count
    
    func fetchStepCount() {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: "startDate", ascending: true)]) { _, samples, _ in
            DispatchQueue.main.async {
                self.stepCount = (samples as? [HKQuantitySample]) ?? []
            }
        }
        
        healthStore.execute(query)
    }
    
    // Handler for UI feedback
    func addStepCount(_ steps: Double, completion: @escaping (Bool, String?) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(false, "Step count type not available")
            return
        }
        
        let quantity = HKQuantity(unit: HKUnit.count(), doubleValue: steps)
        let now = Date()
        let sample = HKQuantitySample(type: sampleType, quantity: quantity, start: now, end: now)
        
        healthStore.save(sample) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.fetchStepCount()
                    completion(true, nil)
                    print("✅ Successfully added \(Int(steps)) steps")
                } else {
                    let errorMsg = error?.localizedDescription ?? "Unknown error"
                    completion(false, errorMsg)
                    print("❌ Failed to save step count: \(errorMsg)")
                    print("💡 Tip: Use Health app → Activity → Steps → Add Data")
                }
            }
        }
    }
    
    // MARK: - Active Energy
    
    func fetchActiveEnergy() {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: "startDate", ascending: true)]) { _, samples, _ in
            DispatchQueue.main.async {
                self.activeEnergy = (samples as? [HKQuantitySample]) ?? []
            }
        }
        
        healthStore.execute(query)
    }
    
    func addActiveEnergy(_ kcal: Double) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let quantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: kcal)
        let now = Date()
        let sample = HKQuantitySample(type: sampleType, quantity: quantity, start: now, end: now)
        
        healthStore.save(sample) { success, error in
            if success {
                self.fetchActiveEnergy()
            } else {
                print("Failed to save active energy: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var currentHeartRate: Double {
        guard let lastSample = heartRate.last else { return 0 }
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        return lastSample.quantity.doubleValue(for: heartRateUnit)
    }
    
    var todayStepCount: Int {
        let stepUnit = HKUnit.count()
        let totalSteps = stepCount.reduce(0) { $0 + $1.quantity.doubleValue(for: stepUnit) }
        return Int(totalSteps)
    }
    
    var todayActiveEnergy: Double {
        let energyUnit = HKUnit.kilocalorie()
        let totalEnergy = activeEnergy.reduce(0) { $0 + $1.quantity.doubleValue(for: energyUnit) }
        return totalEnergy
    }
    
    var heartRateStatus: HeartRateStatus {
        let hr = currentHeartRate
        if hr < lowThreshold {
            return .low
        } else if hr > highThreshold {
            return .high
        } else {
            return .normal
        }
    }
    
    var stepProgress: Double {
        return min(Double(todayStepCount) / Double(stepGoal), 1.0)
    }
    
    var activeEnergyProgress: Double {
        return min(todayActiveEnergy / activeEnergyGoal, 1.0)
    }
    
    // MARK: - Threshold Management
    
    func updateThresholds(low: Double, high: Double) {
        lowThreshold = low
        highThreshold = high
    }
}

// MARK: - Supporting Types

enum HeartRateStatus {
    case low
    case normal
    case high
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .normal: return .green
        case .high: return .red
        }
    }
    
    var message: String {
        switch self {
        case .low: return "Heart rate is low"
        case .normal: return "Heart rate is normal"
        case .high: return "Heart rate is high"
        }
    }
}
