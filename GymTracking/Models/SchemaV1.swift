import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Exercise.self, WorkoutSession.self, ExerciseLog.self, ExerciseSet.self]
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

        @Relationship(deleteRule: .cascade, inverse: \ExerciseLog.session)
        var exerciseLogs: [ExerciseLog]

        var isActive: Bool {
            endedAt == nil
        }

        init() {
            self.id = UUID()
            self.startedAt = Date()
            self.endedAt = nil
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

typealias Exercise = SchemaV2.Exercise
typealias WorkoutSession = SchemaV2.WorkoutSession
typealias ExerciseLog = SchemaV2.ExerciseLog
typealias ExerciseSet = SchemaV2.ExerciseSet
typealias CostPeriod = SchemaV2.CostPeriod
