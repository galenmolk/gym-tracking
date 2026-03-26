import SwiftUI

struct PastSessionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let session: WorkoutSession

    @State private var showDeleteConfirmation = false
    @State private var showingExercisePicker = false

    private var sortedLogs: [ExerciseLog] {
        session.exerciseLogs.sorted { $0.createdAt < $1.createdAt }
    }

    private var totalSets: Int {
        sortedLogs.reduce(0) { $0 + $1.sortedSets.count }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    statItem(value: "\(session.exerciseLogs.count)", label: "Exercises", icon: "dumbbell.fill")
                    Spacer()
                    if let end = session.endedAt {
                        statItem(value: DateFormatting.elapsedTime(from: session.startedAt, to: end), label: "Duration", icon: "clock.fill")
                        Spacer()
                    }
                    statItem(value: "\(totalSets)", label: "Total Sets", icon: "list.number")
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            if let notes = session.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                        .font(.subheadline)
                }
            }

            Section("Exercises") {
                if sortedLogs.isEmpty {
                    Text("No exercises logged.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedLogs) { log in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(log.exercise?.name ?? "Unknown")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: log.sentiment.systemImage)
                                    .foregroundStyle(log.sentiment.color)
                            }

                            ForEach(log.sortedSets) { set in
                                Text("Set \(set.setNumber): \(set.reps) reps @ \(weightString(set.weight)) lbs")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if log.durationSeconds > 0 {
                                Text(durationString(log.durationSeconds))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if !log.notes.isEmpty {
                                Text(log.notes)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 2)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            Section {
                Button {
                    showingExercisePicker = true
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle")
                }
            }

            Section {
                Button("Delete Session", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }
        }
        .navigationTitle("Session Details")
        .sheet(isPresented: $showingExercisePicker) {
            ExerciseLogEntryView(session: session)
        }
        .alert("Delete Session?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                modelContext.delete(session)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete this session and all its exercise logs.")
        }
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
        }
    }

    private func weightString(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }

    private func durationString(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if secs == 0 {
            return "\(mins) min"
        }
        return "\(mins):\(String(format: "%02d", secs))"
    }
}
