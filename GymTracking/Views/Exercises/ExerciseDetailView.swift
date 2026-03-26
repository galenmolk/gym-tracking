import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise

    @State private var isEditing = false
    @State private var editName = ""
    @State private var editNotes = ""
    @State private var showDeleteConfirmation = false

    private var sortedLogs: [ExerciseLog] {
        exercise.logs.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        List {
            if isEditing {
                Section("Name") {
                    TextField("Exercise name", text: $editName)
                }
                Section("Notes") {
                    TextField("Notes", text: $editNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            } else {
                if !exercise.notes.isEmpty {
                    Section("Notes") {
                        Text(exercise.notes)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("History") {
                if sortedLogs.isEmpty {
                    Text("No logs yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedLogs) { log in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(DateFormatting.sessionDate(log.createdAt))
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                Spacer()
                                Image(systemName: log.sentiment.systemImage)
                                    .foregroundStyle(log.sentiment.color)
                            }
                            Text(logSummary(log))
                                .font(.body)
                                .fontWeight(.medium)
                            if !log.notes.isEmpty {
                                Text(log.notes)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            if !isEditing {
                Section {
                    Button("Delete Exercise", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
        }
        .navigationTitle(exercise.name)
        .alert("Delete Exercise?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                modelContext.delete(exercise)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete this exercise and all its logs.")
        }
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isEditing = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        exercise.name = editName.trimmingCharacters(in: .whitespaces)
                        exercise.notes = editNotes.trimmingCharacters(in: .whitespaces)
                        isEditing = false
                    }
                    .disabled(editName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        editName = exercise.name
                        editNotes = exercise.notes
                        isEditing = true
                    }
                }
            }
        }
    }

    private func logSummary(_ log: ExerciseLog) -> String {
        var parts: [String] = []

        let sets = log.sortedSets
        if !sets.isEmpty {
            let allSameWeight = Set(sets.map(\.weight)).count == 1
            let allSameReps = Set(sets.map(\.reps)).count == 1

            if allSameWeight && allSameReps {
                let s = sets[0]
                parts.append("\(sets.count)x\(s.reps) @ \(weightString(s.weight)) lbs")
            } else {
                parts.append(sets.map { "\(weightString($0.weight))x\($0.reps)" }.joined(separator: ", "))
            }
        }

        if log.durationSeconds > 0 {
            parts.append(durationString(log.durationSeconds))
        }

        return parts.isEmpty ? "No data recorded" : parts.joined(separator: " + ")
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
