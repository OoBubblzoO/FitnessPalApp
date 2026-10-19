import Foundation
import SwiftData
import Testing
@testable import FitnessApp

@MainActor
struct WorkoutGroupEditingTests {
    @Test func editsPreserveHistoricalAndUnfinishedSessionsAfterReload() throws {
        let container = try ModelContainer(
            for: WorkoutGroup.self, Workout.self, WorkoutSession.self, ExerciseLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let original = Workout(name: "RDL", sets: "3", reps: "6–8")
        let removed = Workout(name: "Leg Curl", sets: "2", reps: "10")
        let group = WorkoutGroup(title: "Lower", workouts: [original, removed])
        context.insert(group)
        let completed = WorkoutSession(workoutGroup: group, name: group.title, isCompleted: true)
        // Simulate a record from the schema before plannedWorkouts existed.
        completed.plannedWorkouts = nil
        completed.hasPlanSnapshot = false
        let active = WorkoutSession(workoutGroup: group, name: group.title)
        let extra = Workout(name: "Calf Raise", sets: "2", reps: "15")
        active.additionalWorkouts.append(extra)
        context.insert(completed)
        context.insert(active)
        let log = ExerciseLog(workout: original, name: original.name, date: Date(),
                              weight: 100, reps: 7, session: completed)
        context.insert(log)
        try context.save()

        try group.replacePlan(title: "Lower Updated", workouts: [
            Workout(name: "RDL", sets: "4", reps: "8–12"),
            Workout(name: "Hip Thrust", sets: "3", reps: "10")
        ], in: context)
        try context.save()
        let next = WorkoutSession(workoutGroup: group, name: group.title)
        context.insert(next)
        try context.save()

        try group.replacePlan(title: "Lower Final", workouts: [
            Workout(name: "RDL", sets: "5", reps: "5")
        ], in: context)
        try context.save()

        let reloaded = ModelContext(container)
        let sessions = try reloaded.fetch(FetchDescriptor<WorkoutSession>())
        let old = try #require(sessions.first { $0.isCompleted })
        #expect(old.name == "Lower")
        #expect(Set(old.sessionWorkouts.map(\.name)) == ["RDL", "Leg Curl"])
        let oldRDL = try #require(old.sessionWorkouts.first { $0.name == "RDL" })
        #expect(oldRDL.sets == "3")
        #expect(oldRDL.reps == "6–8")
        #expect(old.logs.count == 1)
        #expect(old.logs.first?.weight == 100)
        #expect(old.logs.first?.reps == 7)
        #expect(old.logs.first?.workout == oldRDL)

        let unfinished = try #require(sessions.first { !$0.isCompleted && $0.name == "Lower" })
        #expect(Set(unfinished.sessionWorkouts.map(\.name)) == ["RDL", "Leg Curl", "Calf Raise"])
        let middle = try #require(sessions.first { $0.name == "Lower Updated" })
        #expect(middle.sessionWorkouts.first { $0.name == "RDL" }?.sets == "4")
        let savedGroup = try #require(reloaded.fetch(FetchDescriptor<WorkoutGroup>()).first)
        #expect(savedGroup.title == "Lower Final")
        #expect(savedGroup.workouts.count == 1)
        #expect(savedGroup.workouts.first?.sets == "5")
    }
}
