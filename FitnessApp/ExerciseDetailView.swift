//
//  ExerciseDetailView.swift
//  FitnessApp
//
//  Created by Cheeto on 2/18/26.
//
import SwiftUI

struct ExerciseDetailView: View {
    
    let workout: Workout
    
    @EnvironmentObject var manager: WorkoutManager
    
    @State private var weightInput: String = ""
    @State private var repsInput: String = ""
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack(spacing: 20) {
                
//                Text(workout.name)
//                    .font(.largeTitle)
//                    .bold()
                
                Text("Target: \(workout.sets) sets • \(workout.reps) reps")
                    .foregroundStyle(.secondary)
                
                TextField("Weight", text: $weightInput)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Reps", text: $repsInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                
                Button("Save Set") {
                    if let weight = Double(weightInput),
                       let reps = Int(repsInput) {
                        
                        manager.addLog(for: workout, weight: weight, reps: reps)
                        
                        weightInput = ""
                        repsInput = ""
                    }
                    print("Weight and reps have been saved...")
                }
                .buttonStyle(.fitnessPrimary())
                
                // Pulls from completedSessions and shows user what last weight done
                if let lastLog = manager.lastCompletedLog(for: workout) {
                    Text("Last time: \(formattedWeight(lastLog.weight)) lbs x \(lastLog.reps)")
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        // toolbox allows customization to navigation titles
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(workout.name)
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(Color("AccentColor"))
            }
        }    }
    
    private func formattedWeight(_ weight: Double) -> String {
        String(format: "%.1f", weight)
    }
}
