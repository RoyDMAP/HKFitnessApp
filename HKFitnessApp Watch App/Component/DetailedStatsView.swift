//
//  DetailedStatsView.swift
//  HKFitnessApp
//
//  Created by Roy Dimapilis on 10/25/25.
//

import SwiftUI
import HealthKit
import Charts

struct DetailedStatsView: View {
    @EnvironmentObject var hkManager: HKManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Heart Rate Chart
                HeartRateChartSection()
                
                // Steps Chart
                StepsChartSection()
                
                // Active Energy Chart
                EnergyChartSection()
                
                // Summary Card
                SummaryCard()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Heart Rate Chart Section

struct HeartRateChartSection: View {
    @EnvironmentObject var hkManager: HKManager
    
    var chartData: [ChartDataPoint] {
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        return hkManager.heartRate.prefix(20).enumerated().map { index, sample in
            ChartDataPoint(
                index: index,
                value: sample.quantity.doubleValue(for: heartRateUnit),
                time: sample.startDate
            )
        }
    }
    
    var averageHR: Double {
        guard !hkManager.heartRate.isEmpty else { return 0 }
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let sum = hkManager.heartRate.reduce(0.0) { $0 + $1.quantity.doubleValue(for: heartRateUnit) }
        return sum / Double(hkManager.heartRate.count)
    }
    
    var maxHR: Double {
        guard !hkManager.heartRate.isEmpty else { return 0 }
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        return hkManager.heartRate.map { $0.quantity.doubleValue(for: heartRateUnit) }.max() ?? 0
    }
    
    var minHR: Double {
        guard !hkManager.heartRate.isEmpty else { return 0 }
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        return hkManager.heartRate.map { $0.quantity.doubleValue(for: heartRateUnit) }.min() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                Text("Heart Rate")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.red)
                Spacer()
            }
            
            // Chart
            if !chartData.isEmpty {
                Chart(chartData) { dataPoint in
                    LineMark(
                        x: .value("Time", dataPoint.index),
                        y: .value("BPM", dataPoint.value)
                    )
                    .foregroundStyle(.red)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Time", dataPoint.index),
                        y: .value("BPM", dataPoint.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red.opacity(0.3), .red.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .chartYScale(domain: 40...140)
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [60, 100, 140]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .frame(height: 100)
            } else {
                Text("No heart rate data")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .frame(height: 100)
            }
            
            // Stats Row
            HStack(spacing: 8) {
                MiniStatCard(label: "Avg", value: "\(Int(averageHR))", unit: "BPM", color: .red)
                MiniStatCard(label: "Max", value: "\(Int(maxHR))", unit: "BPM", color: .red)
                MiniStatCard(label: "Min", value: "\(Int(minHR))", unit: "BPM", color: .red)
            }
        }
        .padding(12)
        .background(Color.red.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Steps Chart Section

struct StepsChartSection: View {
    @EnvironmentObject var hkManager: HKManager
    
    var progressData: [ProgressDataPoint] {
        let current = Double(hkManager.todayStepCount)
        let goal = Double(hkManager.stepGoal)
        let remaining = max(0, goal - current)
        
        return [
            ProgressDataPoint(category: "Done", value: current, color: .orange),
            ProgressDataPoint(category: "Left", value: remaining, color: .gray)
        ]
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                Image(systemName: "figure.walk")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text("Steps")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.orange)
                Spacer()
            }
            
            // Vertical Bar Chart
            VStack(spacing: 8) {
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 40)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.orange, .yellow]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(hkManager.stepProgress), height: 40)
                            .animation(.spring(), value: hkManager.stepProgress)
                    }
                }
                .frame(height: 40)
                
                // Stats in Horizontal Layout
                VStack(spacing: 6) {
                    HStack {
                        Text("Done:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(hkManager.todayStepCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.orange)
                        Text("steps")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Left:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(max(0, hkManager.stepGoal - hkManager.todayStepCount))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                        Text("steps")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Goal:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(hkManager.stepGoal)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.orange)
                        Text("steps")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Energy Chart Section

struct EnergyChartSection: View {
    @EnvironmentObject var hkManager: HKManager
    
    var progressData: [ProgressDataPoint] {
        let current = hkManager.todayActiveEnergy
        let goal = hkManager.activeEnergyGoal
        let remaining = max(0, goal - current)
        
        return [
            ProgressDataPoint(category: "Burned", value: current, color: .pink),
            ProgressDataPoint(category: "Left", value: remaining, color: .gray)
        ]
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.pink)
                Text("Energy")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.pink)
                Spacer()
            }
            
            // Vertical Bar Chart 
            VStack(spacing: 8) {
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 40)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.pink, .red]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(hkManager.activeEnergyProgress), height: 40)
                            .animation(.spring(), value: hkManager.activeEnergyProgress)
                    }
                }
                .frame(height: 40)
                
                // Stats in Horizontal Layout
                VStack(spacing: 6) {
                    HStack {
                        Text("Burned:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(hkManager.todayActiveEnergy))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.pink)
                        Text("kcal")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Left:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(max(0, hkManager.activeEnergyGoal - hkManager.todayActiveEnergy)))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                        Text("kcal")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Goal:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(hkManager.activeEnergyGoal))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.pink)
                        Text("kcal")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.pink.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Summary Card

struct SummaryCard: View {
    @EnvironmentObject var hkManager: HKManager
    
    var totalReadings: Int {
        return hkManager.heartRate.count + hkManager.stepCount.count + hkManager.activeEnergy.count
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                Text("Summary")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.blue)
                Spacer()
            }
            
            // Summary Stats - All Horizontal Text
            VStack(spacing: 6) {
                // Heart Rate Readings
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.red)
                    Text("HR Readings:")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(hkManager.heartRate.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.red)
                }
                .padding(8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                
                // Step Readings
                HStack {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    Text("Step Readings:")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(hkManager.stepCount.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.orange)
                }
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                
                // Energy Readings
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.pink)
                    Text("Energy Readings:")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(hkManager.activeEnergy.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.pink)
                }
                .padding(8)
                .background(Color.pink.opacity(0.1))
                .cornerRadius(8)
                
                Divider()
                
                // Total Readings
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 10))
                        .foregroundColor(.blue)
                    Text("Total Readings:")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(totalReadings)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.blue)
                }
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(12)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct MiniStatCard: View {
    let label: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(unit)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

struct SummaryStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Data Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let index: Int
    let value: Double
    let time: Date
}

struct ProgressDataPoint: Identifiable {
    let id = UUID()
    let category: String
    let value: Double
    let color: Color
}

struct DetailedStatsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailedStatsView()
                .environmentObject(HKManager.shared)
        }
    }
}
