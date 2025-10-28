//
//  ActiveEnergyCard.swift
//  HKFitnessApp
//
//  Created by Roy Dimapilis on 10/25/25.
//

import SwiftUI
import HealthKit

struct ActiveEnergyCard: View {
    @EnvironmentObject var hkManager: HKManager
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.pink)
                Text("Active Energy")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("\(Int(hkManager.activeEnergyProgress * 100))%")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.pink)
            }
            
            VStack(spacing: 6) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(Int(hkManager.todayActiveEnergy))")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.pink)
                    Text("/ \(Int(hkManager.activeEnergyGoal))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                    Text("kcal")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "target")
                        .font(.system(size: 12))
                        .foregroundColor(.pink)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 16)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.pink, .red]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(hkManager.activeEnergyProgress), height: 16)
                            .animation(.spring(), value: hkManager.activeEnergyProgress)
                    }
                }
                .frame(height: 16)
            }
            
            // Add sample data button for testing
            #if DEBUG
            Button(action: {
                let randomEnergy = Double.random(in: 20...80)
                hkManager.addActiveEnergy(randomEnergy)
            }) {
                Text("Add Sample")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.pink.opacity(0.6))
                    .cornerRadius(6)
            }
            #endif  // DEBUG
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ActiveEnergyCard_Previews: PreviewProvider {
    static var previews: some View {
        ActiveEnergyCard()
            .environmentObject(HKManager.shared)
            .padding()
    }
}
