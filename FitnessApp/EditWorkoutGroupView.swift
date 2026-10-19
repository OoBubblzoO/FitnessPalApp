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
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && WorkoutInputRules.setCount(sets) != nil
                && WorkoutInputRules.repRange(reps) != nil
        }
    }

    init(group: WorkoutGroup) {
        self.group = group
        _title = State(initialValue: group.title)
        _exercises = State(initialValue: group.orderedWorkouts.map {
            ExerciseDraft(name: $0.name, sets: $0.sets, reps: $0.reps)
        })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Group Name", text: $title)
                        .textInputAutocapitalization(.words)
                } footer: {
                    Text("Changes apply to future sessions. Existing sessions keep their original exercises, targets, and logged sets.")
                }
                Section("Exercises") {
                    ForEach($exercises) { $exercise in
                        WorkoutExerciseDraftRow(exercise: $exercise)
                    }
                    .onDelete { exercises.remove(atOffsets: $0) }
                    .onMove { source, destination in
                        exercises.move(fromOffsets: source, toOffset: destination)
                    }

                    Button("Add Exercise", systemImage: "plus.circle") {
                        exercises.append(ExerciseDraft(name: "", sets: "", reps: ""))
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
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
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !exercises.isEmpty, exercises.allSatisfy(\.isValid) else { return }
        do {
            // Commit unrelated pending logs before an edit that may need rollback.
            try modelContext.save()
            let replacements = exercises.map {
                Workout(
                    name: WorkoutInputRules.capitalizedWords($0.name),
                    sets: WorkoutInputRules.setCount($0.sets) ?? $0.sets,
                    reps: WorkoutInputRules.repRange($0.reps) ?? $0.reps
                )
            }
            do {
                try group.replacePlan(
                    title: WorkoutInputRules.capitalizedWords(title),
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
                .textInputAutocapitalization(.words)
                .accessibilityLabel("Exercise name")
            LabeledContent("Sets") {
                TextField("3 or 2–3", text: Binding(
                    get: { exercise.sets },
                    set: { value in
                        if value.allSatisfy({ "0123456789-–— ".contains($0) }) {
                            exercise.sets = value
                        }
                    }
                ))
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel("Sets")
            }
            LabeledContent("Reps") {
                TextField("8–12", text: Binding(
                    get: { exercise.reps },
                    set: { value in
                        if value.allSatisfy({ "0123456789-–— ".contains($0) }) {
                            exercise.reps = value
                        }
                    }
                ))
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel("Reps")
            }
            if WorkoutInputRules.setCount(exercise.sets) == nil {
                Text("Enter sets as a positive whole number or range, such as 3 or 2–3. The first number must not exceed the second.")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            if WorkoutInputRules.repRange(exercise.reps) == nil {
                Text("Enter a rep range such as 8–12. The first number must not exceed the second.")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}
