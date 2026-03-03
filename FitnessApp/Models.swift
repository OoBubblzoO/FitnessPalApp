//
//  Models.swift
//  FitnessApp
//
//  Created by Cheeto on 3/1/26.
//

import Foundation

// A single exercise with display info for sets and reps
// Dynamic list that can be updated
struct Workout: Identifiable {
    var id = UUID()
    var name: String
    var sets: String
    var reps: String
}

// A named group of workouts shown together in the UI
// each group has name and array of workout(s)
struct WorkoutGroup: Identifiable {
    var id = UUID()
    var title: String
    var workouts: [Workout]
}

// A record of what you lifted for a workout on a date
// on this date workout was performed with this weight and reps
struct ExerciseLog: Identifiable {
    var id = UUID()
    var workoutID: UUID
    var date: Date
    var weight: Double
    var reps: Int
}

// A full session ties logs to a group on specific date
struct WorkoutSession: Identifiable {
    var id = UUID()
    var workoutGroupID: UUID     // links back to the selected group
    var date: Date               // date recorded to group 
    var logs: [ExerciseLog]      // all sets recorded in this session
    var isCompleted: Bool        // marks if the session was finished
}
