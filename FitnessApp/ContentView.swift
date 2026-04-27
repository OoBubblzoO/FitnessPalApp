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
    // The group currently being performed in a session
    @State private var activeGroup: WorkoutGroup? = nil
    
    @State private var cardioType: String = ""
    @State private var cardioDistance: String = ""
    @State private var cardioTime: String = ""
    
    
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
                            
                            let workout = Workout(name: "Hammer Curl", sets: "3", reps: "10-15")
                            Button("Save Test Log") {
                                let log = ExerciseLog(
                                    workout: workout,
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
                    .sheet(isPresented: $isCardioSheetPresented){
                        CardioSessionSheet
                    }
                }
            }
        }
        .task {
            seedDefaultWorkoutGroupsIfNeeded()
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
                        
                        let isSelected = selectedGroup?.title == workoutGroup.title
                        
                        Section(header: Text(workoutGroup.title)
                            .foregroundStyle(Color("AccentColor"))) {
                            
                            ForEach(workoutGroup.workouts) { workout in
                                
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
    }
    
    // CARDIO VIEW
    private var CardioSessionSheet: some View {
        ZStack{
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Text("ENTER YOUR CARDIO")
                    .font(.system(size: 20, weight: .medium))
                    .bold()
                    .padding(12)
                    .foregroundStyle(Color("AccentColor"))
                HStack {
                    TextField("Type", text: $cardioType)
                        .textFieldStyle(.roundedBorder)
                    TextField("Distance", text: $cardioDistance)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    TextField("Duration", text: $cardioTime)
                        .textFieldStyle(.roundedBorder)
                }
                    
                Button("Save Cardio") {
                    guard
                        !cardioType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                        !cardioDistance.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                        let distance = Double(cardioDistance.trimmingCharacters(in: .whitespacesAndNewlines)),
                        let durationSeconds = parsedDurationSeconds(from: cardioTime)
                    else {
                        return
                    }
                    let cardioSession = CardioSession(
                        name: cardioType.trimmingCharacters(in: .whitespacesAndNewlines),
                        distance: distance,
                        durationSeconds: durationSeconds,
                        date: Date()
                        
                    )
                    
                    modelContext.insert(cardioSession)
                    try? modelContext.save()
                    
                    // Reset fields upon opening 
                    cardioType = ""
                    cardioDistance = ""
                    cardioTime = ""
                    isCardioSheetPresented = false
                }
                .buttonStyle(FitnessSecondaryButtonStyle())
                
                Spacer()
                
            }
            .padding()
        }
    }
}



private extension ContentView {
    
    func parsedDurationSeconds(from text: String) -> Int? {
        let parts = text.split(separator: ":")
        
        guard parts.count == 3,
              let hours = Int(parts[0]),
              let minutes = Int(parts[1]),
              let seconds = Int(parts[2]),
              minutes >= 0, minutes < 60,
              seconds >= 0, seconds < 60
        else {
            return nil
        }
        
        return (hours * 3600) + (minutes * 60) + seconds
    }
    
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
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
    
        // Load models I want stored and queried
        .modelContainer(for: [WorkoutGroup.self, Workout.self, WorkoutSession.self , ExerciseLog.self])
}
