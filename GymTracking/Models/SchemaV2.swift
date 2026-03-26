import Foundation
import SwiftData

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Exercise.self, WorkoutSession.self, ExerciseLog.self, ExerciseSet.self, CostPeriod.self]
    }

    @Model
    final class Exercise {
        var id: UUID
        var name: String
        var notes: String
        var createdAt: Date
        var routineIDs: [UUID]

        @Relationship(deleteRule: .cascade, inverse: \ExerciseLog.exercise)
        var logs: [ExerciseLog]

        init(name: String, notes: String = "") {
            self.id = UUID()
            self.name = name
            self.notes = notes
            self.createdAt = Date()
            self.routineIDs = []
            self.logs = []
        }
    }

    @Model
    final class WorkoutSession {
        var id: UUID
        var startedAt: Date
        var endedAt: Date?
        var notes: String?

        @Relationship(deleteRule: .cascade, inverse: \ExerciseLog.session)
        var exerciseLogs: [ExerciseLog]

        var isActive: Bool {
            endedAt == nil
        }

        init() {
            self.id = UUID()
            self.startedAt = Date()
            self.endedAt = nil
            self.notes = ""
            self.exerciseLogs = []
        }
    }

    @Model
    final class ExerciseLog {
        var id: UUID
        var exercise: Exercise?
        var session: WorkoutSession?
        var sentimentRaw: Int
        var notes: String
        var createdAt: Date
        var durationSeconds: Int

        @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.exerciseLog)
        var sets: [ExerciseSet]

        var sentiment: Sentiment {
            get { Sentiment(rawValue: sentimentRaw) ?? .maintain }
            set { sentimentRaw = newValue.rawValue }
        }

        var sortedSets: [ExerciseSet] {
            sets.sorted { $0.setNumber < $1.setNumber }
        }

        init(exercise: Exercise, session: WorkoutSession, sentiment: Sentiment = .maintain, notes: String = "", durationSeconds: Int = 0) {
            self.id = UUID()
            self.exercise = exercise
            self.session = session
            self.sentimentRaw = sentiment.rawValue
            self.notes = notes
            self.createdAt = Date()
            self.durationSeconds = durationSeconds
            self.sets = []
        }
    }

    @Model
    final class CostPeriod {
        var id: UUID
        var name: String
        var startDate: Date
        var endDate: Date?
        var totalCost: Double

        var isActive: Bool {
            endDate == nil
        }

        init(name: String, startDate: Date, totalCost: Double) {
            self.id = UUID()
            self.name = name
            self.startDate = startDate
            self.endDate = nil
            self.totalCost = totalCost
        }
    }

    @Model
    final class ExerciseSet {
        var id: UUID
        var exerciseLog: ExerciseLog?
        var setNumber: Int
        var reps: Int
        var weight: Double
        var createdAt: Date

        init(exerciseLog: ExerciseLog, setNumber: Int, reps: Int = 0, weight: Double = 0) {
            self.id = UUID()
            self.exerciseLog = exerciseLog
            self.setNumber = setNumber
            self.reps = reps
            self.weight = weight
            self.createdAt = Date()
        }
    }
}
