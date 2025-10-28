//
//  MotionManager.swift
//  HKFitnessApp
//
//  Created by Assistant
//

import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    static let shared = MotionManager()
    
    private let motionActivityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    
    @Published var currentActivity: ActivityType = .stationary
    @Published var realtimeSteps: Int = 0
    @Published var realtimeDistance: Double = 0.0
    @Published var currentPace: Double = 0.0 // steps per second
    @Published var isMotionAvailable = false
    
    enum ActivityType: String {
        case stationary = "Stationary"
        case walking = "Walking"
        case running = "Running"
        case cycling = "Cycling"
        case automotive = "In Vehicle"
        case unknown = "Unknown"
        
        var icon: String {
            switch self {
            case .stationary: return "figure.stand"
            case .walking: return "figure.walk"
            case .running: return "figure.run"
            case .cycling: return "bicycle"
            case .automotive: return "car.fill"
            case .unknown: return "questionmark.circle"
            }
        }
    }
    
    private init() {
        checkAvailability()
    }
    
    func checkAvailability() {
        isMotionAvailable = CMMotionActivityManager.isActivityAvailable() && CMPedometer.isStepCountingAvailable()
        print("Motion Activity Available: \(CMMotionActivityManager.isActivityAvailable())")
        print("Step Counting Available: \(CMPedometer.isStepCountingAvailable())")
        print("Distance Available: \(CMPedometer.isDistanceAvailable())")
        print("Pace Available: \(CMPedometer.isPaceAvailable())")
    }
    
    // MARK: - Start Tracking
    
    func startTracking() {
        startActivityTracking()
        startPedometerTracking()
    }
    
    func stopTracking() {
        motionActivityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        print("🛑 Motion tracking stopped")
    }
    
    // MARK: - Activity Tracking
    
    private func startActivityTracking() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            print("❌ Motion Activity not available on this device")
            return
        }
        
        motionActivityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self = self, let activity = activity else { return }
            
            DispatchQueue.main.async {
                self.updateActivityType(from: activity)
            }
        }
        
        print("✅ Motion activity tracking started")
    }
    
    private func updateActivityType(from activity: CMMotionActivity) {
        if activity.stationary {
            currentActivity = .stationary
        } else if activity.running {
            currentActivity = .running
        } else if activity.walking {
            currentActivity = .walking
        } else if activity.cycling {
            currentActivity = .cycling
        } else if activity.automotive {
            currentActivity = .automotive
        } else {
            currentActivity = .unknown
        }
        
        print("🏃 Activity: \(currentActivity.rawValue)")
    }
    
    // MARK: - Pedometer Tracking
    
    private func startPedometerTracking() {
        guard CMPedometer.isStepCountingAvailable() else {
            print("❌ Pedometer not available on this device")
            return
        }
        
        let now = Date()
        
        pedometer.startUpdates(from: now) { [weak self] pedometerData, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Pedometer error: \(error.localizedDescription)")
                return
            }
            
            guard let data = pedometerData else { return }
            
            DispatchQueue.main.async {
                self.realtimeSteps = data.numberOfSteps.intValue
                
                if let distance = data.distance {
                    self.realtimeDistance = distance.doubleValue
                }
                
                if let pace = data.currentPace {
                    self.currentPace = pace.doubleValue
                }
                
                print("📊 Real-time - Steps: \(self.realtimeSteps), Distance: \(String(format: "%.1f", self.realtimeDistance))m")
            }
        }
        
        print("✅ Pedometer tracking started")
    }
    
    // MARK: - Get Historical Data
    
    func fetchTodaysPedometerData(completion: @escaping (Int, Double) -> Void) {
        guard CMPedometer.isStepCountingAvailable() else {
            completion(0, 0.0)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        pedometer.queryPedometerData(from: startOfDay, to: now) { data, error in
            if let error = error {
                print("❌ Failed to fetch pedometer data: \(error.localizedDescription)")
                completion(0, 0.0)
                return
            }
            
            guard let data = data else {
                completion(0, 0.0)
                return
            }
            
            let steps = data.numberOfSteps.intValue
            let distance = data.distance?.doubleValue ?? 0.0
            
            DispatchQueue.main.async {
                completion(steps, distance)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func getActivityDescription() -> String {
        switch currentActivity {
        case .stationary:
            return "You're currently at rest"
        case .walking:
            return "Keep up the walking!"
        case .running:
            return "Great running pace!"
        case .cycling:
            return "Enjoy your ride!"
        case .automotive:
            return "Traveling by vehicle"
        case .unknown:
            return "Activity detected"
        }
    }
    
    func resetDailyTracking() {
        realtimeSteps = 0
        realtimeDistance = 0.0
        currentPace = 0.0
        print("🔄 Daily motion tracking reset")
    }
}
