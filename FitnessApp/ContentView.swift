//
//  ContentView.swift
//  FitnessApp
//
//  Created by Cheeto on 2/10/26.
//

import SwiftUI

struct ContentView: View {
    
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
    
    // dynamic array of workout instances
//    @State var workouts = [
//        Workout(name: "Upper"),
//        Workout(name: "Lower"),
//        Workout(name: "Core"),
//        Workout(name: "Full Body")
//    ]
    
    // Local state
    @State private var isSheetPresented: Bool = false
    var body: some View {
        VStack {
            
            Image(systemName: "figure.strengthtraining.traditional")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("READY TO WORK OUT?")
                .font(.title)
                .bold()
            
            Button("I'm at the gym") {
                isSheetPresented.toggle()
                print("isSheetPresented has been toggled to " , isSheetPresented)
                
            }
            
            .sheet(isPresented: $isSheetPresented) {
                Text("SELECT WORK OUT")
                    .font(.title)
                    .bold()
                    .padding(12)
                
                
                // dynamic creation for each section
                List {
                    // loop over every workoutGroup in workoutGroups
                    ForEach(workoutGroups) { workoutGroup in
                        Section(header: Text(workoutGroup.title)) {
                            // loop over every workout in workoutGroup
                            ForEach(workoutGroup.workouts){ workout in
                                // for every workout do below
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
                            }
                        }
                    }
                }
                
                Button("Start Workout"){
                    isSheetPresented.toggle()
                    print("Workout has been selected... Entering workout mode...")
                }
                
                Divider()
                
                Button("Cancel Check in ") {
                    isSheetPresented.toggle()
                    print("isSheetPresented has been toggled to " , isSheetPresented, " and is now cancelled")
                }
                
            
                
                
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
