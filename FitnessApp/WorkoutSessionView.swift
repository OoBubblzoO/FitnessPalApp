//
//  WorkoutSessionView.swift
//  FitnessApp
//
//  Created by Cheeto on 2/18/26.
//
import SwiftUI
import SwiftData

struct WorkoutSessionView: View {
    let workoutGroup: WorkoutGroup
    let currentSession: WorkoutSession?
    let onWorkoutCompleted: () -> Void
    
    @Query(sort: \WorkoutSession.date, order: .reverse)
    private var sessions: [WorkoutSession]
    
    @State private var completionSummary: String = ""
    @State private var showCompletionAlert: Bool = false

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack {
                Text(workoutGroup.title)
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(Color("AccentColor"))
                    .padding(.top, 50)
                List {
                    ForEach(workoutGroup.workouts) { workout in
                        NavigationLink
                        {
                            ExerciseDetailView(workout: workout, currentSession: currentSession)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.headline)
                                    .foregroundStyle(Color("BackgroundColor"))
                                
                                HStack(spacing: 16) {
                                    Text("Sets: \(workout.sets)")
                                    Text("Reps: \(workout.reps)")
                                }
                                .font(.subheadline)
                                .foregroundStyle(Color("BackgroundColor").opacity(0.72))
                                
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color("AccentColor"))
                    }
                }
                .listRowBackground(Color.clear)
                .scrollContentBackground(.hidden)
                //.navigationTitle(workoutGroup.title)
                .alert("Workout Complete", isPresented: $showCompletionAlert) {
                    Button("OK") {
                        onWorkoutCompleted()
                    }
                } message: {
                    Text(completionSummary)
                }
                
                Button("Add Cardio") {
                    
                }
                .buttonStyle(.fitnessPrimary())
                .padding(.horizontal)
                .padding(.bottom)
                    
                
                Button("Workout Complete") {
                    guard let currentSession else { return }
                    currentSession.isCompleted = true
                    completionSummary = completionMessage
                    showCompletionAlert = true
                }
                .buttonStyle(.fitnessAccent())
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    private var latestCompletedSessionForGroup: WorkoutSession? {
        sessions
            .filter { completedSession in
                completedSession.isCompleted && completedSession.workoutGroup == workoutGroup
            }
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
        log.workout?.name ?? "Exercise"
    }
    
    // Format to 1 dec
    private func formattedWeight(_ weight: Double) -> String {
        String(format: "%.1f", weight)
    }
}

#Preview {
    
    let previewWorkoutGroup = WorkoutGroup(
        title: "Lower (quad/hinges)",
        workouts: [
            Workout(name: "Squat", sets: "3", reps: "6-8"),
            Workout(name: "RDL", sets: "3", reps: "6-10")
        ]
    )

    return NavigationStack {
        
        WorkoutSessionView(
            workoutGroup: previewWorkoutGroup,
            currentSession: nil,
            onWorkoutCompleted: {}
        )
    }
    .preferredColorScheme(.dark)

    .modelContainer(for: [WorkoutGroup.self, Workout.self, WorkoutSession.self, ExerciseLog.self])
}
