import SwiftUI

struct SessionSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    let session: WorkoutSession

    private var sortedLogs: [ExerciseLog] {
        session.exerciseLogs.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.green)
                        Text("Workout Complete")
                            .font(.title2)
                            .bold()
                        Text(DateFormatting.sessionDate(session.startedAt))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 16) {
                            if let end = session.endedAt {
                                Label(DateFormatting.elapsedTime(from: session.startedAt, to: end), systemImage: "clock.fill")
                            }
                            Label("\(sortedLogs.count) exercises", systemImage: "dumbbell.fill")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

                if let notes = session.notes, !notes.isEmpty {
                    Section("Notes") {
                        Text(notes)
                            .font(.subheadline)
                    }
                }

                if !sortedLogs.isEmpty {
                    Section("Exercises") {
                        ForEach(sortedLogs) { log in
                            ExerciseLogCard(log: log)
                        }
                    }
                }
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .interactiveDismissDisabled()
        }
    }
}
