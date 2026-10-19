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
    
    // SwiftData is now the source of truth for the workout list shown in the sheet.
    @Query(sort: \WorkoutGroup.title) var workoutGroups: [WorkoutGroup]
    
    // Controls the view of creating new workout
    @State private var isWorkoutCreating: Bool = false
    // Controls the sheet that lets you pick a workout group
    @State private var isSheetPresented: Bool = false
    // Controls Cardio Sheet
    @State private var isCardioSheetPresented: Bool = false
    // The group the user tapped in the list
    @State private var selectedGroup: WorkoutGroup? = nil
    @State private var editingGroup: WorkoutGroup?
    // The group currently being performed in a session
    @State private var activeGroup: WorkoutGroup? = nil
    
    // Starting sessions
    @Environment(\.modelContext) private var modelContext
    @State private var currentSession: WorkoutSession?
   
    @Query(
        filter: #Predicate<WorkoutSession> { $0.isCompleted == false },
        sort: \WorkoutSession.date,
        order: .reverse )
    private var unfinishedSessions: [WorkoutSession]
    
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
                            
                            Button("Record cardio session"){
                                isCardioSheetPresented.toggle()
                                print("Toggling Cardio Session")
                            }
                            .buttonStyle(.fitnessPrimary())
                            
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
                        //.navigationTitle("TESTING")
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
                    .sheet(isPresented: $isCardioSheetPresented){
                        CardioSessionEntryView()
                    }
                }
            }
        }
        .task {
            seedDefaultWorkoutGroupsIfNeeded()
            resumedUnfinishedSessionIfNeeded()
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
                    ForEach(workoutGroups) { workoutGroup in
                        
                        let isSelected = selectedGroup == workoutGroup
                        
                        Section(header: HStack {
                            Text(workoutGroup.title)
                            Spacer()
                            Button("Edit", systemImage: "pencil") {
                                editingGroup = workoutGroup
                            }
                            .accessibilityLabel("Edit \(workoutGroup.title)")
                        }
                            .foregroundStyle(Color("AccentColor"))) {
                            
                            ForEach(workoutGroup.orderedWorkouts) { workout in
                                
                                VStack(alignment: .leading) {
                                    
                                    Text(workout.name)
                                        .font(.headline)
                                        .foregroundStyle(Color("BackgroundColor")) // Force Dark Text
                                    
                                    HStack(spacing: 16) {
                                        Text("Sets: \(workout.sets)")
                                        Text("Reps: \(workout.reps)")
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(Color("BackgroundColor").opacity(0.72)) // Froce Dark Text but softer
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .listRowBackground(
                                    isSelected
                                    ? Color("PrimaryColor")
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
                        
                        let newSession = WorkoutSession(workoutGroup: group, name: group.title)
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
        .sheet(item: $editingGroup) { group in
            EditWorkoutGroupView(group: group)
        }
    }
    
}



private extension ContentView {
    
    func seedDefaultWorkoutGroupsIfNeeded() {
        // Seed starter group only when the database is empty so testing always has one list entry.
        guard workoutGroups.isEmpty else { return }
        
        let defaultWorkoutGroup = WorkoutGroup(
            title: "Lower (quad/hinges)",
            workouts: [
                Workout(name: "Squat", sets: "3", reps: "6-8"),
                Workout(name: "RDL", sets: "3", reps: "6-10"),
                Workout(name: "Single-leg Press", sets: "3", reps: "10-12"),
                Workout(name: "Leg Curl", sets: "3", reps: "8-12"),
                Workout(name: "Calf Raise", sets: "3", reps: "10-15")
            ]
        )
        
        modelContext.insert(defaultWorkoutGroup)
        try? modelContext.save()
    }
    
    func resumedUnfinishedSessionIfNeeded() {
        
        // session running? -> leave alone
        guard currentSession == nil else { return }
        
        // Resume something if within time frame to resume
        let cutoff = Date().addingTimeInterval(-6 * 60 * 60)
        
        // All 3 pass or do nothing
        guard let session = unfinishedSessions.first, // Potential Candidaet?
                  session.date > cutoff,              // Recent enough?
                  let group = session.workoutGroup    // Group?
        else { return }
        
        // Restore if pass
        currentSession = session
        activeGroup = group
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
    
        // Load models I want stored and queried
        .modelContainer(for: [WorkoutGroup.self, Workout.self, WorkoutSession.self , ExerciseLog.self])
}
