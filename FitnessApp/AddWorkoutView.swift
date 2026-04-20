//
//  AddWorkoutView.swift
//  FitnessApp
//
//  Created by Cheeto on 3/4/26.
//

import SwiftUI
import SwiftData

struct AddWorkoutView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Temp form, gets converted to Workout later
    struct DraftWorkout: Identifiable {
        let id = UUID()
        var name = ""
        var sets = ""
        var reps = ""
    }

    // Name of workout
    @State private var workoutGroupNameInput: String = ""
    
    // Array of of draftRows (starts with 1 item to show input)
    @State private var draftWorkouts: [DraftWorkout] = [DraftWorkout()]

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    TextField("Group Name", text: $workoutGroupNameInput)
                        .textFieldStyle(.roundedBorder)
                    
                    ForEach($draftWorkouts) { $draft in
                        HStack(spacing: 8) {
                            TextField("Workout", text: $draft.name)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("Sets", text: $draft.sets)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("Reps", text: $draft.reps)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    
                    Button {
                        draftWorkouts.append(DraftWorkout())
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(FitnessSecondaryButtonStyle())
                    
                    Button("Save workout") {
                        let groupTitle = workoutGroupNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        let workouts = draftWorkouts
                        // Convert draft row to final WorkoutObject (Builds workout from temp data)
                            .map {
                                Workout(
                                    name: $0.name.trimmingCharacters(in: .whitespacesAndNewlines),
                                    sets: $0.sets.trimmingCharacters(in: .whitespacesAndNewlines),
                                    reps: $0.reps.trimmingCharacters(in: .whitespacesAndNewlines)
                                )
                            }
                        // Don't allow blank workouts
                            .filter {
                                !$0.name.isEmpty && !$0.sets.isEmpty && !$0.reps.isEmpty
                            }
                        
                        // Save the new group directly to SwiftData so @Query views update automatically.
                        let newWorkoutGroup = WorkoutGroup(title: groupTitle, workouts: workouts)
                        modelContext.insert(newWorkoutGroup)
                        try? modelContext.save()
                        dismiss()
                    }
                    .buttonStyle(.fitnessPrimary())
                    .opacity(workoutGroupNameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
                    // Don't allow save if pre-req missing
                    .disabled(
                        workoutGroupNameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || draftWorkouts.allSatisfy {
                            $0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || $0.sets.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || $0.reps.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        }
                    )
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Add Workout")
            }
        }
    }
}

#Preview {
    AddWorkoutView()
        .modelContainer(for: [WorkoutGroup.self, Workout.self, WorkoutSession.self, ExerciseLog.self])
}
