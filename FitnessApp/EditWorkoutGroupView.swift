import SwiftUI
import SwiftData

struct EditWorkoutGroupView: View {
    let group: WorkoutGroup

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var exercises: [ExerciseDraft]
    @State private var showSaveError = false

    struct ExerciseDraft: Identifiable {
        let id = UUID()
        var name: String
        var sets: String
        var reps: String

        var isValid: Bool {
            [name, sets, reps].allSatisfy {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        }
    }

    init(group: WorkoutGroup) {
        self.group = group
        _title = State(initialValue: group.title)
        _exercises = State(initialValue: group.workouts.map {
            ExerciseDraft(name: $0.name, sets: $0.sets, reps: $0.reps)
        })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Group Name", text: $title)
                } footer: {
                    Text("Changes apply to future sessions. Existing sessions keep their original exercises, targets, and logged sets.")
                }
                Section("Exercises") {
                    ForEach($exercises) { $exercise in
                        WorkoutExerciseDraftRow(exercise: $exercise)
                    }
                    .onDelete { exercises.remove(atOffsets: $0) }

                    Button("Add Exercise", systemImage: "plus.circle") {
                        exercises.append(ExerciseDraft(name: "", sets: "", reps: ""))
                    }
                }
            }
            .navigationTitle("Edit Workout Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                  || exercises.isEmpty || !exercises.allSatisfy(\.isValid))
                }
            }
            .alert("Couldn’t Save Changes", isPresented: $showSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your edits are still here. Please try saving again.")
            }
        }
    }

    private func save() {
        do {
            // Commit unrelated pending logs before an edit that may need rollback.
            try modelContext.save()
            let replacements = exercises.map {
                Workout(
                    name: $0.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    sets: $0.sets.trimmingCharacters(in: .whitespacesAndNewlines),
                    reps: $0.reps.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            do {
                try group.replacePlan(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    workouts: replacements,
                    in: modelContext
                )
                try modelContext.save()
            } catch {
                modelContext.rollback()
                throw error
            }
            dismiss()
        } catch {
            showSaveError = true
        }
    }
}

private struct WorkoutExerciseDraftRow: View {
    @Binding var exercise: EditWorkoutGroupView.ExerciseDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Exercise Name", text: $exercise.name)
                .accessibilityLabel("Exercise name")
            LabeledContent("Sets") {
                TextField("3", text: $exercise.sets)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel("Sets")
            }
            LabeledContent("Reps") {
                TextField("8–12", text: $exercise.reps)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel("Reps")
            }
        }
    }
}
