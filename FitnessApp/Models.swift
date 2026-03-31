//
//  Models.swift
//  FitnessApp
//
//  Created by Cheeto on 3/1/26.
//

import Foundation
import SwiftUI
import SwiftData


// MARK: UPDATE TO BE ABLE TO USE SWIFTDATA

/**
 This means we're going to change the struct to a class. Struct is a value type that gets copied when changed. Class references the same object that's shared and updated
 Struct - a screenshot
 Class - live document that can be edited
 .modelContext connects to database  *DO NOT FORGET* (pen)
 context.insert writing page
 Query going to allow to retrieve from Database
 
 modelContainer - database
 modelContext - talk  to it
 @Model - what's getting stored
 @Query - how to read
 
 Change WorkoutGroup, Workout, WorkoutSession, ExerciseLog to classes and @Model
 */

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
@Model
final class ExerciseLog {
    var workoutID: UUID
    var name: String
    var date: Date
    var weight: Double
    var reps: Int
    var session: WorkoutSession? // Belongs to workout session -> workoutSession creates logs
    
    init(workoutID: UUID, name: String, date: Date, weight: Double, reps: Int, session: WorkoutSession? = nil) {
        self.workoutID = workoutID
        self.name = name
        self.date = date
        self.weight = weight
        self.reps = reps
        self.session = session
    }
}

// A full session ties logs to a group on specific date
@Model
final class WorkoutSession {
    //var id = UUID()
    var workoutGroupID: UUID     // Links back to the selected group
    var name : String
    var date: Date               // Date recorded to group
    var logs: [ExerciseLog]      // All sets recorded in this session
    var isCompleted: Bool        // Marks if the session was finished
    
    
    // Provide default values for saved time
    init(workoutGroupID: UUID, name: String,  date: Date = Date(), logs: [ExerciseLog] = [], isCompleted: Bool = false) {
        self.workoutGroupID = workoutGroupID
        self.name = name
        self.date = date
        self.logs = logs
        self.isCompleted = isCompleted
    }
}

// Filled button style
struct FitnessButtonStyle: ButtonStyle {
    // Background color
    let fillColor: Color
    // Text/icon color
    let foregroundColor: Color
    // Outline + shadow color
    let borderColor: Color

    // SwiftUI builds button UI here
    func makeBody(configuration: Configuration) -> some View {
        // Original button label
        configuration.label
            .font(.headline.weight(.semibold))
            .textCase(.uppercase)
            .tracking(0.8)
            // Full available width
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            // Label color
            .foregroundStyle(foregroundColor)
            .background(
                // Button shape
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    // Fill shape with chosen color
                    .fill(fillColor)
            )
            .overlay(
                // Border on top of fill
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    // Pressed state changes opacity a bit
                    .stroke(borderColor.opacity(configuration.isPressed ? 0.55 : 0.9), lineWidth: 1.5)
            )
            // Depth effect, softer when pressed
            .shadow(color: borderColor.opacity(configuration.isPressed ? 0.08 : 0.22), radius: configuration.isPressed ? 6 : 14, y: configuration.isPressed ? 3 : 8)
            // Slight press-down effect
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            // Smooth press animation
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

// Lighter outlined button style
struct FitnessSecondaryButtonStyle: ButtonStyle {
    // Same button builder, different look
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .foregroundStyle(Color("PrimaryColor"))
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("BackgroundColor"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color("AccentColor").opacity(configuration.isPressed ? 0.45 : 0.8), lineWidth: 1.5)
            )
            // Small press effect
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

// Shortcut names for reusable button styles
extension ButtonStyle where Self == FitnessButtonStyle {
    // Primary app button colors
    static func fitnessPrimary() -> FitnessButtonStyle {
        FitnessButtonStyle(
            fillColor: Color("PrimaryColor"),
            foregroundColor: Color("BackgroundColor"),
            borderColor: Color("AccentColor")
        )
    }

    // Accent version for stronger emphasis
    static func fitnessAccent() -> FitnessButtonStyle {
        FitnessButtonStyle(
            fillColor: Color("AccentColor"),
            foregroundColor: Color("BackgroundColor"),
            borderColor: Color("PrimaryColor")
        )
    }
}
