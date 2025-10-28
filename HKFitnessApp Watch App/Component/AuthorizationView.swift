//
//  AuthorizationView.swift
//  HKFitnessApp
//
//  Created by Roy Dimapilis on 10/25/25.


import SwiftUI

struct AuthorizationView: View {
    @EnvironmentObject var hkManager: HKManager
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Health Access Required")
                .font(.headline)
            
            Text("HKFitness needs access to your health data to monitor your heart rate, steps, and active energy.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Button(action: {
                isRequesting = true
                hkManager.requestAuthorization()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isRequesting = false
                }
            }) {
                if isRequesting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Grant Access")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(isRequesting)
        }
        .padding()
    }
}

struct AuthorizationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationView()
            .environmentObject(HKManager.shared)
    }
}
