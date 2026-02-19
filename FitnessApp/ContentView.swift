//
//  ContentView.swift
//  FitnessApp
//
//  Created by Cheeto on 2/10/26.
//

import SwiftUI

// Dynamic list that can be updated
struct Workout: Identifiable {
    var id = UUID()
    var name: String
    var sets: String
    var reps: String
    
}

// each group has name and array of workout(s)
struct WorkoutGroup: Identifiable {
    var id = UUID()
    var title: String
    var workouts: [Workout]
}

struct ContentView: View {
    // dynamic array
    let workoutGroups = [
        WorkoutGroup(title: "Lower (quad/hinges)", workouts: [
            Workout(name: "Squat", sets: "3", reps: "6–8"),
            Workout(name: "RDL", sets: "3", reps: "6–10"),
            Workout(name: "Single-leg Press", sets: "3", reps: "10–12"),
            Workout(name: "Leg Curl", sets: "3", reps: "8–12"),
            Workout(name: "Calf Raise", sets: "3", reps: "10–15")
        ] ),
        WorkoutGroup(title: "Push (+ verical pull)", workouts: [
            Workout(name: "Dumbell Bench", sets: "3", reps: "6–10"),
            Workout(name: "Incline Dumbell Press", sets: "3", reps: "8–10"),
            Workout(name: "Lat Pulldown", sets: "2–3", reps: "6–10"),
            Workout(name: "Skull Crushers", sets: "3", reps: "10–15"),
            Workout(name: "Tricep Pushdown", sets: "3", reps: "10–15"),
            Workout(name: "Lateral Raise", sets: "3", reps: "12–15"),
            Workout(name: "Face Pulls", sets: "2–3", reps: "12–15")
        ])
    ]

    // Local state
    @State private var isSheetPresented: Bool = false
    @State private var selectedGroup: WorkoutGroup? = nil
    @State private var activeGroup: WorkoutGroup? = nil

    var body: some View {
        NavigationStack {
            if let group = activeGroup {
                WorkoutSessionView(workoutGroup: group)
            } else {
                VStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .imageScale(.large)
                        .foregroundStyle(.tint)

                    Text("READY TO WORK OUT?")
                        .font(.title)
                        .bold()

                    Button("I'm at the gym") {
                        isSheetPresented.toggle()
                        print("isSheetPresented has been toggled to ", isSheetPresented)
                    }
                }
                .padding()
                .sheet(isPresented: $isSheetPresented) {
                    VStack {
                        Text("SELECT WORK OUT")
                            .font(.title)
                            .bold()
                            .padding(12)

                        List {
                            ForEach(workoutGroups) { workoutGroup in
                                let isSelected = selectedGroup?.id == workoutGroup.id

                                Section(header: Text(workoutGroup.title)) {
                                    ForEach(workoutGroup.workouts) { workout in
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
                                        .contentShape(Rectangle())
                                        .listRowBackground(isSelected ? Color.accentColor.opacity(0.15) : Color.white)
                                        .onTapGesture {
                                            selectedGroup = workoutGroup
                                        }
                                    }
                                }
                            }
                        }

                        Button("Start Workout") {
                            guard let group = selectedGroup else { return }
                            activeGroup = group
                            isSheetPresented = false
                        }
                        .disabled(selectedGroup == nil)

                        Divider()

                        Button("Cancel Check in") {
                            isSheetPresented = false
                            selectedGroup = nil
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
