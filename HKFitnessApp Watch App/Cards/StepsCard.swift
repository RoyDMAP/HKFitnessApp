//
//  StepsCard.swift
//  HKFitnessApp
//
//  Created by Roy Dimapilis on 10/25/25.
//

import SwiftUI
import HealthKit

struct StepsCard: View {
    @EnvironmentObject var hkManager: HKManager
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(.orange)
                Text("Steps")
                    .font(.headline)
                Spacer()
                Text("\(Int(hkManager.stepProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(hkManager.todayStepCount)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text("/ \(hkManager.stepGoal)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "flag.fill")
                        .foregroundColor(.orange)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.orange, .yellow]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(hkManager.stepProgress), height: 20)
                            .animation(.spring(), value: hkManager.stepProgress)
                    }
                }
                .frame(height: 20)
            }
            
            // Add sample data button for testing (simulator)
            #if DEBUG
            VStack(spacing: 6) {
                Button(action: {
                    let randomSteps = Double.random(in: 100...500)
                    hkManager.addStepCount(randomSteps) { success, error in
                        if !success {
                            errorMessage = error ?? "Failed to add steps"
                            showingError = true
                        }
                    }
                }) {
                    Text("Add Sample")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange.opacity(0.6))
                        .cornerRadius(6)
                }
                
                if showingError {
                    Text(errorMessage)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }
                
            }
            .padding(.top, 4)
            #endif  // DEBUG
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct StepsCard_Previews: PreviewProvider {
    static var previews: some View {
        StepsCard()
            .environmentObject(HKManager.shared)
            .padding()
    }
}
