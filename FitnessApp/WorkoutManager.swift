//
//  WorkoutManager.swift
//  FitnessApp
//
//  Created by Cheeto on 3/2/26.
//

import Foundation
import Combine
import SwiftData

class WorkoutManager: ObservableObject {
    
    // Hardcoded workout groups for now, will be dynamic later
    // Published as workout would update states, CRUD 
    @Published var workoutGroups: [WorkoutGroup] = [
        WorkoutGroup(title: "Lower (quad/hinges)", workouts: [
            Workout(name: "Squat", sets: "3", reps: "6–8"),
            Workout(name: "RDL", sets: "3", reps: "6–10"),
            Workout(name: "Single-leg Press", sets: "3", reps: "10–12"),
            Workout(name: "Leg Curl", sets: "3", reps: "8–12"),
            Workout(name: "Calf Raise", sets: "3", reps: "10–15")
        ]),
        WorkoutGroup(title: "Push (+ vertical pull)", workouts: [
            Workout(name: "Dumbbell Bench", sets: "3", reps: "6–10"),
            Workout(name: "Incline Dumbbell Press", sets: "3", reps: "8–10"),
            Workout(name: "Lat Pulldown", sets: "2–3", reps: "6–10"),
            Workout(name: "Skull Crushers", sets: "3", reps: "10–15"),
            Workout(name: "Tricep Pushdown", sets: "3", reps: "10–15"),
            Workout(name: "Lateral Raise", sets: "3", reps: "12–15"),
            Workout(name: "Face Pulls", sets: "2–3", reps: "12–15")
        ])
    ]
    
    
    // @Published tells swift UI to update when vars change
    @Published var activeSession: WorkoutSession?
    @Published var completedSessions: [WorkoutSession] = []
    
    
    func startSession(for group: WorkoutGroup) {
        activeSession = WorkoutSession(
            workoutGroupID: group.id,
            name: group.title,
            date: Date(),
            logs: [],
            isCompleted: false
        )
    }
    
    // add log for current workout of the weights and reps
    func addLog(for workout: Workout, weight: Double, reps: Int, session: WorkoutSession, context: ModelContext) {
        //guard var session = activeSession else { return }
        
        let log = ExerciseLog(
            workoutID: workout.id,
            name: workout.name,
            date: Date(),
            weight: weight,
            reps: reps,
            session: session // Links log to session
        )
        
        session.logs.append(log)
        context.insert(log) //saves to SwiftData
        
        activeSession = session
    }
    
    func completeSession() {
        guard var session = activeSession else { return }
        
        session.isCompleted = true
        completedSessions.append(session)
        activeSession = nil // workout session no longer active
    }
    
    
    func lastCompletedLog(for workout: Workout) -> ExerciseLog? {
        completedSessions
            .flatMap { $0.logs }
            .filter { $0.workoutID == workout.id }
            .sorted { $0.date > $1.date }
            .first
    }
    
    func addWorkoutGroup(title: String, workouts:[Workout]){
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines) // Remove spaces and new lines
        
        guard !cleanedTitle.isEmpty, !workouts.isEmpty else { return } // If empty exit
        
        let newGroup = WorkoutGroup(title: cleanedTitle, workouts: workouts)
        workoutGroups.append(newGroup)
    }
    
    func addWorkout(to groupID: UUID, name: String, reps: String, sets: String){
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanSets = sets.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanReps = reps.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanName.isEmpty, !cleanSets.isEmpty, !cleanReps.isEmpty else { return } // Exit if empty
        guard let groupIndex = workoutGroups.firstIndex(where: { $0.id == groupID }) else { return }
        
        let newWorkout = Workout(name: cleanName, sets: cleanSets, reps: cleanReps)
        workoutGroups[groupIndex].workouts.append(newWorkout)
        
        
        
    }
}

