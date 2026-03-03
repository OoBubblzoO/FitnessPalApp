//
//  WorkoutSessionView.swift
//  FitnessApp
//
//  Created by Cheeto on 2/18/26.
//
import SwiftUI

struct WorkoutSessionView: View {
    
    @EnvironmentObject var manager: WorkoutManager
    
    let workoutGroup: WorkoutGroup
    let onWorkoutCompleted: () -> Void
    
    @State private var completionSummary: String = ""
    @State private var showCompletionAlert: Bool = false

    var body: some View {
        VStack {
            List {
                ForEach(workoutGroup.workouts) { workout in
                    NavigationLink {
                        ExerciseDetailView(workout: workout)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(workout.name)
                                .font(.headline)
                            
                            HStack(spacing: 16) {
                                Text("Sets: \(workout.sets)")
                                Text("Reps: \(workout.reps)")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle(workoutGroup.title)
            .alert("Workout Complete", isPresented: $showCompletionAlert) {
                Button("OK") {
                    onWorkoutCompleted()
                }
            } message: {
                Text(completionSummary)
            }
            
            Button("Workout Complete") {
                // Finish the session first so it is saved into completedSessions.
                manager.completeSession()
                
                // Build the alert text from the saved session we just completed.
                completionSummary = completionMessage
                showCompletionAlert = true
            }
        }
    }
    
    // This pulls the newest completed session for the workout group shown in this view.
    private var latestCompletedSessionForGroup: WorkoutSession? {
        manager.completedSessions
            .filter { completedSession in
                completedSession.workoutGroupID == workoutGroup.id // taking current session (temporary)
            }
            .sorted { $0.date > $1.date }
            .first
    }
    
    // The alert uses the completed session logs as the source of truth for what was done.
    private var completionMessage: String {
        
        guard let completedSession = latestCompletedSessionForGroup,
              Calendar.current.isDateInToday(completedSession.date) else { // Grabs current calendar settings
            return "Your workout was saved." //
        }
        
        // MARK: Prompt User that a workout was not done
        // If marked as complete but nothing recorded (Change Later)
        if completedSession.logs.isEmpty {
            return "Workout completed today, no sets logged."
        }
        return completedSession.logs // [ExerciseLog] | logs put into string
            .map { log in
                "\(workoutName(for: log)): \(formattedWeight(log.weight)) lbs x \(log.reps)"
            }
            .joined(separator: "\n")
    }
    
    // Logs store only workout IDs so this maps each saved log back to a display name. TY
    private func workoutName(for log: ExerciseLog) -> String {
        workoutGroup.workouts
            .first { $0.id == log.workoutID }?
            .name ?? "Exercise"
    }
    
    // Format to 1 dec
    private func formattedWeight(_ weight: Double) -> String {
        String(format: "%.1f", weight)
    }
}
