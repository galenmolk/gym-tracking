import SwiftUI
import SwiftData

struct SessionTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<WorkoutSession> { $0.endedAt != nil },
        sort: \WorkoutSession.startedAt,
        order: .reverse
    ) private var pastSessions: [WorkoutSession]

    @Query(
        filter: #Predicate<WorkoutSession> { $0.endedAt == nil }
    ) private var activeSessions: [WorkoutSession]

    @State private var completedSession: WorkoutSession?

    private var activeSession: WorkoutSession? {
        activeSessions.first
    }

    var body: some View {
        NavigationStack {
            if let session = activeSession {
                ActiveSessionView(session: session, onEnd: { completedSession = $0 })
            } else {
                idleView
            }
        }
        .sheet(item: $completedSession) { session in
            SessionSummaryView(session: session)
        }
    }

    private var idleView: some View {
        List {
            Section {
                Button {
                    let session = WorkoutSession()
                    modelContext.insert(session)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Start Workout")
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(.borderedProminent)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                .listRowBackground(Color.clear)
            }

            if pastSessions.isEmpty {
                ContentUnavailableView("No Past Workouts", systemImage: "figure.strengthtraining.traditional", description: Text("Your completed workouts will appear here."))
            } else {
                Section("Recent Sessions") {
                    ForEach(pastSessions.prefix(20)) { session in
                        NavigationLink(value: session) {
                            HStack(spacing: 12) {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .frame(width: 32)
                                    .foregroundStyle(.secondary)
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
            }
        }
        .navigationTitle("Workout")
        .navigationDestination(for: WorkoutSession.self) { session in
            PastSessionDetailView(session: session)
        }
    }

    private func sessionDuration(_ session: WorkoutSession) -> String {
        guard let end = session.endedAt else { return "" }
        return DateFormatting.elapsedTime(from: session.startedAt, to: end)
    }
}
