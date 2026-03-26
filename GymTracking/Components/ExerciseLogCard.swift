import SwiftUI

struct ExerciseLogCard: View {
    let log: ExerciseLog

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(log.sentiment.color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(log.exercise?.name ?? "Unknown")
                    .font(.headline)
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: log.sentiment.systemImage)
                .font(.title3)
                .foregroundStyle(log.sentiment.color)
        }
        .padding(.vertical, 4)
    }

    private var summary: String {
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

        return parts.isEmpty ? "No data" : parts.joined(separator: " + ")
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
