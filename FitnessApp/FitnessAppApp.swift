//
//  FitnessAppApp.swift
//  FitnessApp
//
//  Created by Cheeto on 2/10/26.
//

import SwiftUI

@main
struct FitnessAppApp: App {
    
    // 1 instance and keep alive with the app
    @StateObject private var manager = WorkoutManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
        }
    }
}

