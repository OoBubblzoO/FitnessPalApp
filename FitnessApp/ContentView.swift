//
//  ContentView.swift
//  FitnessApp
//
//  Created by Cheeto on 2/10/26.
//

import Foundation
import SwiftUI
import SwiftData
struct ContentView: View {
    
    // MARK: Environment
    
    @EnvironmentObject var manager: WorkoutManager
    
    // Controls the view of creating new workout
    @State private var isWorkoutCreating: Bool = false
    // Controls the sheet that lets you pick a workout group
    @State private var isSheetPresented: Bool = false
    // The group the user tapped in the list
    @State private var selectedGroup: WorkoutGroup? = nil
    // The group currently being performed in a session
    @State private var activeGroup: WorkoutGroup? = nil
    
    // Starting sessions
    @Environment(\.modelContext) private var modelContext
    @State private var currentSession: WorkoutSession?
    @Query(sort: \WorkoutSession.date, order: .reverse)
    var sessions: [WorkoutSession]
    
    @Query(sort: \ExerciseLog.date, order: .reverse)
    var logs: [ExerciseLog]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                // Show the session view only after a group is chosen
                if let group = activeGroup {
                    WorkoutSessionView(workoutGroup: group, currentSession: currentSession,
                                       onWorkoutCompleted: {
                        currentSession = nil
                        activeGroup = nil
                        selectedGroup = nil
                    })
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundStyle(Color("PrimaryColor"))
                            .padding(18)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color("AccentColor").opacity(0.16))
                            )
                        
                        Text("READY TO WORK OUT?")
                            .font(.title.weight(.black))
                            .bold()
                            .foregroundStyle(Color("AccentColor"))
                        
                        VStack(spacing: 14) {
                            Button("Save Test Log") {
                                let log = ExerciseLog(
                                    workoutID: UUID(),
                                    name: "Hammer Curl",
                                    date: Date(),
                                    weight: 135,
                                    reps: 10
                                )
                                
                                modelContext.insert(log)
                                try? modelContext.save()
                                print("Saved Log", log.name, log.date, log.weight, log.reps)
                                print("Logs count, \(logs.count)")
                            }
                            Button("I'm at the gym") {
                                isSheetPresented.toggle()
                            }
                            .buttonStyle(.fitnessPrimary())
                            
                            // Takes to another view
                            NavigationLink {
                                AddWorkoutView()
                            } label: {
                                Text("Create Workout")
                            }
                            .buttonStyle(FitnessSecondaryButtonStyle())
                        }
                        .padding(.top, 8)
                        .navigationTitle("TESTING")
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                NavigationLink(destination: CalendarView()){
                                    Image(systemName: "calendar")
                                }
                            }
                        }
                    }
                    .padding()
                    .sheet(isPresented: $isSheetPresented) {
                        workoutSelectionSheet
                    }
                }
            }
            Text("Sessions count: \(sessions.count)!")
            Text("Logs count: \(logs.count)")
            List(logs, id: \.self) { log in
                VStack(alignment: .leading) {
                    Text("Name: \(log.name)")
                    Text("Weight: \(log.weight)")
                    Text("Reps: \(log.reps)")
                }
            }
            .frame(height: 200)
        }
    }
    
    // MARK: Sheet View
    
    private var workoutSelectionSheet: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack {
                Text("SELECT WORK OUT")
                    .font(.system(size: 20, weight: .medium))
                    .bold()
                    .padding(12)
                    .foregroundStyle(Color("AccentColor"))
                
                // Lists workoutGroups for user to select from
                List {
                    ForEach(manager.workoutGroups) { workoutGroup in
                        
                        let isSelected = selectedGroup?.id == workoutGroup.id
                        
                        Section(header: Text(workoutGroup.title)
                            .foregroundStyle(Color("AccentColor"))) {
                            
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
                                    : Color("AccentColor")
                                ) // Highlight the selected group's rows
                                .onTapGesture {
                                    selectedGroup = workoutGroup
                                }
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .scrollContentBackground(.hidden)
                
                // Start session with selected group and close sheet
                VStack(spacing: 12) {
                    Button("Start Workout") {
                        guard let group = selectedGroup else { return }
                        
                        let newSession = WorkoutSession(workoutGroupID: group.id, name: group.title)
                        modelContext.insert(newSession)
                        currentSession = newSession
                        
                        activeGroup = group
                        isSheetPresented = false
                        
                        print("Session created: \(newSession.date)")
                    }
                    .buttonStyle(.fitnessPrimary())
                    .opacity(selectedGroup == nil ? 0.45 : 1)
                    .disabled(selectedGroup == nil)
                    
                    // Dismiss sheet without starting a session
                    Button("Cancel Check in") {
                        isSheetPresented = false
                        selectedGroup = nil
                    }
                    .buttonStyle(FitnessSecondaryButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
    }
    
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
        .modelContainer(for: [WorkoutSession.self , ExerciseLog.self])
}
