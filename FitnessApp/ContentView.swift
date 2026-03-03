//
//  ContentView.swift
//  FitnessApp
//
//  Created by Cheeto on 2/10/26.
//

import Foundation
import SwiftUI
struct ContentView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var manager: WorkoutManager
    
    // Controls the sheet that lets you pick a workout group
    @State private var isSheetPresented: Bool = false
    // The group the user tapped in the list
    @State private var selectedGroup: WorkoutGroup? = nil
    // The group currently being performed in a session
    @State private var activeGroup: WorkoutGroup? = nil
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            
            // Show the session view only after a group is chosen
            if let group = activeGroup {
                WorkoutSessionView(workoutGroup: group) {
                    activeGroup = nil
                    selectedGroup = nil
                }
            } else {
                
                VStack(spacing: 20) {
                    
                    Image(systemName: "figure.strengthtraining.traditional")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    
                    Text("READY TO WORK OUT?")
                        .font(.title)
                        .bold()
                    
                    Button("I'm at the gym") {
                        isSheetPresented.toggle()
                    }
                }
                .padding()
                .sheet(isPresented: $isSheetPresented) {
                    workoutSelectionSheet
                }
            }
        }
    }
    
    // MARK: - Sheet View
    
    private var workoutSelectionSheet: some View {
        VStack {
            
            Text("SELECT WORK OUT")
                .font(.title)
                .bold()
                .padding(12)
            
            // Lists workoutGroups for user to select from
            List {
                ForEach(manager.workoutGroups) { workoutGroup in
                    
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
                            .listRowBackground(
                                isSelected
                                ? Color.accentColor.opacity(0.15)
                                : Color.white
                            ) // Highlight the selected group's rows
                            .onTapGesture {
                                selectedGroup = workoutGroup
                            }
                        }
                    }
                }
            }
            
            // Start session with selected group and close sheet
            Button("Start Workout") {
                guard let group = selectedGroup else { return }
                
                manager.startSession(for: group)   // HUGE!!
                activeGroup = group
                isSheetPresented = false
            }
            .disabled(selectedGroup == nil)
            
            Divider()
            
            // Dismiss sheet without starting a session
            Button("Cancel Check in") {
                isSheetPresented = false
                selectedGroup = nil
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
}
