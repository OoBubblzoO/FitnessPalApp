//
//  ExerciseDetailView.swift
//  FitnessApp
//
//  Created by Cheeto on 2/18/26.
//
import SwiftUI
import SwiftData


// TODO: When a workout set is completed give some sort of confirmation / view to the logging process (EXAMPLE: Allow to be seen unerneath)
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
                            workout: workout,
                            name: workout.name,
                            date: Date(),
                            weight: weight,
                            reps: reps,
                            session: currentSession
                        )
                        
                        // currentSession?.logs.append(log) <- no longer need due to relation auto inserts
                        modelContext.insert(log)
                        
                        weightInput = ""
                        repsInput = ""
                    }
                    
                    // Change here to give some sort of notification to user
                    print("Weight and reps have been saved...")
                }
                .buttonStyle(.fitnessPrimary())
                
                // Pulls from completedSessions and shows user what last weight done
                if let lastLog = lastCompletedLog {
                    Text("Last time: \(formattedWeight(lastLog.weight)) lbs x \(lastLog.reps)")
                        .foregroundColor(.gray)
                }
                
                // MARK: Add here some sort of viewing screen of current session but ONLY for that exercise
                
                if let session = currentSession{
                   let currentLogWorkout = session.logs
                        .filter({ $0.name == workout.name })
                        .sorted(by: { $0.date > $1.date })
                    if !currentLogWorkout.isEmpty {
                        VStack(alignment: .leading, spacing: 8){
                            Text("This Session")
                                .font(.headline)
                            ForEach(currentLogWorkout) { log in
                                Text("\(formattedWeight(log.weight)) lbs x \(log.reps)")
                                    .foregroundStyle(.gray)
                                
                            }
                        }
                    }
//                        .first {
//                    Text("Current set: \(formattedWeight(latestForThisWorkout.weight)) lbs x \(latestForThisWorkout.reps)")
//                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
        // Toolbox allows customization to navigation titles
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(workout.name)
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(Color("AccentColor"))
            }
        }    }
    
    // Only use logs from completed sessions. Logs without a session count as incomplete.

    private var lastCompletedLog: ExerciseLog? {
        logs.first { log in
            log.name == workout.name && (log.session?.isCompleted ?? false) // Check to see if there is a current session and if it's completed (if nil = false)
        }
    }
    
    private func formattedWeight(_ weight: Double) -> String {
        String(format: "%.1f", weight)
    }
}

