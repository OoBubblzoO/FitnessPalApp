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
        VStack(spacing: 20) {
            
            Text(workout.name)
                .font(.largeTitle)
                .bold()
            
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
            
            // Pulls from completedSessions and shows user what last weight done
            if let lastLog = manager.lastCompletedLog(for: workout) {
                Text("Last time: \(formattedWeight(lastLog.weight)) lbs x \(lastLog.reps)")
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle(workout.name, displayMode: .inline)
    }
    
    private func formattedWeight(_ weight: Double) -> String {
        String(format: "%.1f", weight)
    }
}
