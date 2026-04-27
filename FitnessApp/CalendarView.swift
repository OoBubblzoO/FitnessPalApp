//
//  CalendarView.swift
//  FitnessApp
//
//  Created by Cheeto on 3/24/26.
//

/*
    TODO: ADD EDIT BUTTTON TO EDIT / DELETE WORKOUTS / RUNS
    - Start with editing cardio sheet
    - Change name, distqance, duration
    - Allow save / deletion
 
    - Tap log in workout logs
    - Open Edit Log sheet
    - Change weight/reps
    - Save / delete
 */

import SwiftUI
import SwiftData

struct CalendarView: View {

    // Keep the workout sessions query because the finished calendar will use it.
    @Query(sort: \WorkoutSession.date, order: .reverse)
    private var sessions: [WorkoutSession]

    
    @Query(sort: \CardioSession.date, order: .reverse)
    private var cardioSessions: [CardioSession]
    // Store month being shown
    @State private var displayedMonth: Date = Date()
    
    // Store Selected date : Optional (nil)
    @State private var selectedDate: Date?
    
    // Allows us to shift our shown month forward or backwards
    func shiftMonth(by value: Int){
        if let newmonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth){
            displayedMonth = newmonth
        }
    }
    
    // Uses short weekday names within an array
    var weekdaySymbols: [String] {
        Calendar.current.shortWeekdaySymbols
    }
    
    // Reusable calendar
    var calendar: Calendar {
        Calendar.current
    }
    
    // Finds how many days in month, first day of that month, builds array of Date vals for every day
    var daysInMonth: [Date] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: displayedMonth),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))
        else {
            return []
        }
        // Start on first day of month, add number of days to it and get new date back
        // monthStart = starting point, byAdding = MoveForward, value = How far to move
        return monthRange.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }
    }
    
   // take saved WorkoutSessions group by date | startOfDay so times don't mess up
    var sessionsByDay: [Date: [WorkoutSession]] {
        Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.date)
        }
    }
    
    // take saved CardioSessions group by datae | startOfDay so times don't mess up
    var cardioSessionsByDay: [Date: [CardioSession]] {
        Dictionary(grouping: cardioSessions) { session in
            calendar.startOfDay(for: session.date)
        }
    }
    
    // create 7 columns
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)
    
    // Gets first day of displayed month | ask what calendsar what weekday it is | converts blank cells before day 1 (1 for sunday 2 for monday etc etc.
    // EX : Sunday -> 1 - 1 = 0  | Monday = 2 - 1 = 1 Blank
    
    
    var leadingEmptyDays: Int {
        guard let firstDay = daysInMonth.first else {
            return 0
        }
        return calendar.component(.weekday, from: firstDay) - 1
    }
    
    // Converts selectedDate to true/false control
    // if selectedDate != nil, open => when closed false | set selectedDate to nil
    var selectedDateBinding: Binding<Bool> {
        Binding(
            get: {
                selectedDate != nil
            },
            set: { isPresented in
                if !isPresented {
                    selectedDate = nil
                }
            }
        )
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button {
                        shiftMonth(by: -1)// fill after
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color("PrimaryColor"))
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color("AccentColor").opacity(0.15))
                            )
                    }

                    Spacer()

                    VStack(spacing: 4) {
                        Text(displayedMonth.formatted(.dateTime.month(.wide)))
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color("PrimaryColor"))

                        Text(displayedMonth.formatted(.dateTime.year()))
                            .font(.subheadline)
                            .foregroundStyle(Color("AccentColor"))
                    }

                    Spacer()

                    Button {
                        shiftMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color("PrimaryColor"))
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color("AccentColor").opacity(0.15))
                            )
                    }
                }

                Text("Sessions loaded: \(sessions.count)")
                    .foregroundStyle(Color("AccentColor"))
                
                // Calendar View
                // *REMEMBER* ForEach loops through each weekdayString!
                HStack(spacing: 12){
                    ForEach(weekdaySymbols, id: \.self) { day in // self use with \
                        Text(day)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AccentColor"))
                            .frame(maxWidth: .infinity) // Max reach + equal space
                    }

                }
                
                LazyVGrid(columns: columns, spacing: 12) {
                    
                    // Create invisible cells
                    ForEach(0..<leadingEmptyDays, id: \.self) { _ in
                        Color.clear
                            .frame(height: 56)
                    }
                    
                    // Draws days
                    ForEach(daysInMonth, id: \.self) { date in
                       // let hasWorkout = sessionsByDay[calendar.startOfDay(for: date )] != nil
                        
                        let day = calendar.startOfDay(for: date)
                        let hasWorkout = sessionsByDay[day] != nil
                        let hasCardio = cardioSessionsByDay[day] != nil
                        let hasActivity = hasWorkout || hasCardio
                        
                        Button {
                            selectedDate =  date
                        } label: {
                            Text("\(calendar.component(.day, from: date))")
                                .font(.headline)
                                .foregroundStyle(Color("PrimaryColor"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                            // Normal days get subtle background, Workout days get stronger fill + border + dot
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(hasActivity ? Color("PrimaryColor").opacity(0.12) : Color.white.opacity(0.05)
                                             )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(hasActivity ? Color("PrimaryColor") : Color.clear, lineWidth: 2)
                                        )
                                        .overlay(alignment: .bottom) {
                                            if hasActivity {
                                                Capsule()
                                                    .fill(Color("PrimaryColor"))
                                                    .frame(width: 16, height: 4)
                                                    .padding(.bottom, 8)
                                            }
                                        }
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                if let selectedDate {
                    Text("Selected: \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                        .foregroundStyle(Color("AccentColor"))
                }
            }
            .padding()
        }
        
        // Enables sheet to pop up
        // finds sessions for selected day useing sessionsByDay
        // show each session in List
        
        .sheet(isPresented: selectedDateBinding) {
            if let selectedDate {
                let selectedDay = calendar.startOfDay(for: selectedDate)
                
                // If selected day has sessions USE else use empty array
                let selectedSessions = sessionsByDay[selectedDay] ?? []
                let selectedCardioSessions = cardioSessionsByDay[selectedDay] ?? []
                ZStack {
                    Color("BackgroundColor")
                        .ignoresSafeArea()
                    NavigationStack {
                        List {
                            Section {
                                Text(selectedDay.formatted(date: .complete, time: .omitted))
                                    .font(.headline)
                                    .foregroundStyle(Color("PrimaryColor"))
                            }
                            if selectedSessions.isEmpty && selectedCardioSessions.isEmpty {
                                Text("No activity was saved on this day.")
                                    .foregroundStyle(Color("AccentColor"))
                            }
                            
                            if !selectedSessions.isEmpty {
                                ForEach(selectedSessions) { session in
                                    Section {
//                                        if let groupTitle = session.workoutGroup?.title {
//                                            Text("Group: \(groupTitle)")
//                                                .font(.subheadline)
//                                                .foregroundStyle(Color("AccentColor"))
//                                        }
                                        if session.logs.isEmpty {
                                            Text("No exercise logs recorded.")
                                                .foregroundStyle(Color("AccentColor"))
                                        } else {
                                            ForEach(session.logs) { log in
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(log.name)
                                                        .font(.headline)
                                                        .foregroundStyle(Color("PrimaryColor"))
                                                    
                                                    Text("\(log.weight, specifier: "%.1f") lbs x \(log.reps) reps")
                                                        .font(.subheadline)
                                                        .foregroundStyle(Color("AccentColor"))
                                                }
                                                .padding(.vertical, 4)
                                            }
                                        }
                                    } header: {
                                        Text(session.name)
                                            .foregroundStyle(Color("AccentColor"))
                                    }
                                    
                                }
                            }
                                
                            if !selectedCardioSessions.isEmpty {
                                ForEach(selectedCardioSessions) { cardioSession in
                                    Section {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(cardioSession.distance, specifier: "%.2f") miles")
                                                .font(.subheadline)
                                                .foregroundStyle(Color("PrimaryColor"))
                                            
                                            Text(cardioSession.formattedDuration)
                                                .font(.subheadline.monospacedDigit())
                                                .foregroundStyle(Color("AccentColor"))
                                        }
                                        .padding(.vertical, 4)
                                    } header: {
                                        Text(cardioSession.name)
                                            .foregroundStyle(Color("AccentColor"))
                                    }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Workout Details")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [WorkoutGroup.self, Workout.self, WorkoutSession.self, ExerciseLog.self, CardioSession.self])
}
