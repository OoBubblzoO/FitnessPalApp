//
//  CalendarView.swift
//  FitnessApp
//
//  Created by Cheeto on 3/24/26.
//
import SwiftUI
import SwiftData


struct CalendarView: View {
    
    @Environment(\.modelContext) private var context
//    @Query(sort: \WorkoutSession.date, order: .reverse)
//    private var sessions: [WorkoutSession]
//    
    @Query(sort: \ExerciseLog.date, order: .reverse)
    var logs: [ExerciseLog]
    
    var body: some View {
        Text("Calendar")
        
//        Text("Sessions count: \(sessions.count)")
//        List(logs, id: \.self) { log in
//            VStack(alignment: .leading) {
//                Text("Weight: \(log.weight)")
//                Text("Reps: \(log.reps)")
//            }
//        }
//        .frame(height: 200)
    }
}
