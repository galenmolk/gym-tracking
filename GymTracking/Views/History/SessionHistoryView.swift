import SwiftUI
import SwiftData

struct SessionHistoryView: View {
    @Query(
        filter: #Predicate<WorkoutSession> { $0.endedAt != nil },
        sort: \WorkoutSession.startedAt,
        order: .reverse
    ) private var sessions: [WorkoutSession]

    var body: some View {
        List {
            if sessions.isEmpty {
                ContentUnavailableView(
                    "No Past Sessions",
                    systemImage: "clock",
                    description: Text("Completed workouts will appear here.")
                )
            } else {
                ForEach(sessions) { session in
                    NavigationLink(value: session) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(DateFormatting.sessionDate(session.startedAt))
                                .font(.body)
                            Text("\(session.exerciseLogs.count) exercises \u{2022} \(sessionDuration(session))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
    }

    private func sessionDuration(_ session: WorkoutSession) -> String {
        guard let end = session.endedAt else { return "" }
        return DateFormatting.elapsedTime(from: session.startedAt, to: end)
    }
}
