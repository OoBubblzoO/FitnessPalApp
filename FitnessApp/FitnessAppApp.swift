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
    
    // 1 instance and keep alive with the app
    @StateObject private var manager = WorkoutManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
        }
        .modelContainer(for: [WorkoutGroup.self, Workout.self, WorkoutSession.self , ExerciseLog.self])
    }
}

