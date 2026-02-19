//
//  ExerciseDetailView.swift
//  FitnessApp
//
//  Created by Cheeto on 2/18/26.
//
import SwiftUI

struct ExerciseDetailView : View {
    let workout: Workout
    
    var body: some View {
        VStack(spacing: 20) {
            Text(workout.name)
                .font(.largeTitle)
                .bold()
            
            Text("Target: \(workout.sets) sets • \(workout.reps) reps")
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationBarTitle(Text(workout.name))
        .navigationBarTitleDisplayMode(.inline)
    }
}
