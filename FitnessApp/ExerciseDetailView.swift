//
//  ExerciseDetailView.swift
//  FitnessApp
//
//  Created by Cheeto on 2/18/26.
//
import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    
    let workout: Workout
    let currentSession: WorkoutSession?
    
    @State private var weightInput: String = ""
    @State private var repsInput: String = ""
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExerciseLog.date, order: .reverse)
    private var logs: [ExerciseLog]
    
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
                        let log = ExerciseLog(
                            workoutID: workout.id,
                            name: workout.name,
                            date: Date(),
                            weight: weight,
                            reps: reps,
                            session: currentSession
                        )
                        
                        currentSession?.logs.append(log)
                        modelContext.insert(log)
                        
                        weightInput = ""
                        repsInput = ""
                    }
                    print("Weight and reps have been saved...")
                }
                .buttonStyle(.fitnessPrimary())
                
                // Pulls from completedSessions and shows user what last weight done
                if let lastLog = lastCompletedLog {
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
    
    private var lastCompletedLog: ExerciseLog? {
        logs.first { log in
            log.workoutID == workout.id && (log.session?.isCompleted ?? false)
        }
    }
    
    private func formattedWeight(_ weight: Double) -> String {
        String(format: "%.1f", weight)
    }
}
