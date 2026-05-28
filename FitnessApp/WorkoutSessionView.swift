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
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var isAddingWorkoutSheetPresented = false
    @State private var newWorkoutName = ""
    @State private var newWorkoutSets = ""
    @State private var newWorkoutReps = ""

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
                    ForEach(sessionWorkouts) { workout in
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
                
                Button("Add Workout") {
                    isAddingWorkoutSheetPresented = true
                }
                .buttonStyle(.fitnessPrimary())
                .padding(.horizontal)
                .padding(.bottom)
                .sheet(isPresented: $isAddingWorkoutSheetPresented){
                    addWorkoutSheet
                }
                    
                
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
    
    // Returns full list of exercises with both temp and regular group || can be nil
    private var sessionWorkouts: [Workout] {
        workoutGroup.workouts + (currentSession?.additionalWorkouts ?? [])
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
    
    private func saveAdditionalWorkout() {
        let trimmedName = newWorkoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSets = newWorkoutSets.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedReps = newWorkoutReps.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Don't allow empty information
        guard let currentSession,
              !trimmedName.isEmpty,
              !trimmedSets.isEmpty,
              !trimmedReps.isEmpty else {
            return
        }
        
        let newWorkout = Workout(
            name: trimmedName,
            sets: trimmedSets,
            reps: trimmedReps
        )
        
        // Save additional workouts
        currentSession.additionalWorkouts.append(newWorkout)
        
        try? modelContext.save()
        
        resetAdditionalWorkoutForm()
        isAddingWorkoutSheetPresented = false
    }
    
    private func resetAdditionalWorkoutForm() {
        newWorkoutName = ""
        newWorkoutSets = ""
        newWorkoutReps = ""
    }
    
    private var addWorkoutSheet: some View {
        NavigationStack {
            Form {
                TextField("Workout Name", text: $newWorkoutName)
                TextField("Sets", text: $newWorkoutSets)
                TextField("Reps", text: $newWorkoutReps)
                
                Button("Add To Today's Workout"){
                    saveAdditionalWorkout()
                }
                .disabled(
                    newWorkoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    newWorkoutSets.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    newWorkoutReps.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
            .navigationTitle("Add Workout")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        resetAdditionalWorkoutForm()
                        isAddingWorkoutSheetPresented = false
                    }
                }
            }
        }
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
