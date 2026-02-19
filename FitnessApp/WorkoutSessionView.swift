//
//  WorkoutSessionView.swift
//  FitnessApp
//
//  Created by Cheeto on 2/18/26.
//
import SwiftUI

struct WorkoutSessionView: View {
    
    let workoutGroup: WorkoutGroup
    
    var body: some View {
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
    }
}
