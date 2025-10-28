import SwiftUI

struct ActivityCard: View {
    @StateObject private var motionManager = MotionManager.shared
    @EnvironmentObject var hkManager: HKManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: smartActivityType.icon)
                    .foregroundColor(.purple)
                Text("Activity")
                    .font(.headline)
                    .fixedSize()
                Spacer()
                Text(smartActivityType.rawValue)
                    .font(.caption2)
                    .foregroundColor(.purple)
                    .fixedSize()
            }
            
            VStack(spacing: 10) {
                // Activity Type
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current Activity")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                            .fixedSize()
                        Text(smartActivityType.rawValue)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.purple)
                            .fixedSize()
                    }
                    
                    Spacer()
                    
                    Image(systemName: smartActivityType.icon)
                        .font(.system(size: 30))
                        .foregroundColor(.purple)
                }
                .padding(10)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
                
                // Steps (uses HealthKit data as fallback for simulator)
                HStack {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(displaySteps)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                            .fixedSize()
                        Text("steps")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                            .fixedSize()
                    }
                    
                    Spacer()
                    
                    Image(systemName: "figure.walk.motion")
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                }
                .padding(10)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
                
                // Distance
                HStack {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", displayDistance))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                            .fixedSize()
                        Text("meters")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                            .fixedSize()
                    }
                    
                    Spacer()
                    
                    Image(systemName: "location.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                }
                .padding(10)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Activity Description
            Text(smartActivityDescription)
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
            
            // Data Source Indicator
            Text(dataSourceText)
                .font(.system(size: 8))
                .foregroundColor(.gray.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .onAppear {
            if motionManager.isMotionAvailable {
                motionManager.startTracking()
            }
        }
        .onDisappear {
            motionManager.stopTracking()
        }
    }
    
    // MARK: - Computed Properties
    
    // Intelligent activity type based on actual data
    private var smartActivityType: MotionManager.ActivityType {
        // If Core Motion is working and detecting activity, use it
        if motionManager.realtimeSteps > 0 && motionManager.currentActivity != .stationary {
            return motionManager.currentActivity
        }
        
        // Otherwise, infer activity from step count
        let steps = displaySteps
        if steps == 0 {
            return .stationary
        } else if steps < 1000 {
            return .walking
        } else if steps < 5000 {
            return .walking
        } else {
            return .walking // Could be running if we had pace data
        }
    }
    
    // Use Core Motion steps if available, otherwise use HealthKit steps
    private var displaySteps: Int {
        if motionManager.realtimeSteps > 0 {
            return motionManager.realtimeSteps
        }
        // Fallback to HealthKit for simulator
        return hkManager.todayStepCount
    }
    
    // Estimate distance from steps if Core Motion doesn't provide it
    private var displayDistance: Double {
        if motionManager.realtimeDistance > 0 {
            return motionManager.realtimeDistance
        }
        // Estimate: average step = 0.762 meters
        return Double(displaySteps) * 0.762
    }
    
    private var dataSourceText: String {
        if motionManager.realtimeSteps > 0 {
            return "Using Core Motion data"
        } else {
            return "Using HealthKit data (Simulator mode)"
        }
    }
    
    private var smartActivityDescription: String {
        switch smartActivityType {
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
}

struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard()
            .environmentObject(HKManager.shared)
            .padding()
    }
}
