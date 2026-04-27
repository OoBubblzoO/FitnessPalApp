//
//  FitnessAppApp.swift
//  FitnessApp
//
//  Created by Cheeto on 2/10/26.
//


// MARK: Hook swiftData to app, swap out environmentObject using .modelcontainer creates a table 
import SwiftUI
import SwiftData

@main
struct FitnessAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Register every SwiftData model that the app reads or saves.
        .modelContainer(for: [WorkoutGroup.self, Workout.self, WorkoutSession.self , ExerciseLog.self, CardioSession.self])
    }
}
