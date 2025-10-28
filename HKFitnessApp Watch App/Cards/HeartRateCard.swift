//
//  HeartRateCard.swift
//  HKFitnessApp
//
//  Created by Roy Dimapilis on 10/25/25.
//

import SwiftUI
import HealthKit

struct HeartRateCard: View {
    @EnvironmentObject var hkManager: HKManager
    
    var statusColor: Color {
        switch hkManager.heartRateStatus {
        case .low: return .blue
        case .normal: return .green
        case .high: return .red
        }
    }
    
    // Calculate progress based on heart rate 
    var heartRateProgress: Double {
        let hr = hkManager.currentHeartRate
        let minHR = 40.0
        let maxHR = 200.0
        
        // Normalize HR to 0-1 range
        let progress = (hr - minHR) / (maxHR - minHR)
        return min(max(progress, 0), 1) // Clamp between 0 and 1
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(statusColor)
                Text("Heart Rate")
                    .font(.headline)
                Spacer()
                Text(hkManager.heartRateStatus.message)
                    .font(.caption2)
                    .foregroundColor(statusColor)
            }
            
            ZStack {
                Circle()
                    .stroke(statusColor.opacity(0.3), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: heartRateProgress)
                    .stroke(statusColor, lineWidth: 12)
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: hkManager.currentHeartRate)
                
                VStack(spacing: 2) {
                    Text("\(Int(hkManager.currentHeartRate))")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(statusColor)
                    Text("BPM")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Add sample data button for testing
            #if DEBUG
            Button(action: {
                let randomBPM = Double.random(in: 60...100)
                hkManager.addHeartRate(randomBPM)
            }) {
                Text("Add Sample")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.red.opacity(0.6))
                    .cornerRadius(6)
            }
            #endif  // DEBUG
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct HeartRateCard_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateCard()
            .environmentObject(HKManager.shared)
            .padding()
    }
}
