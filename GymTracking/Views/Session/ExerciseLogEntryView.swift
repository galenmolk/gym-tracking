import SwiftUI
import SwiftData

struct ExerciseLogEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    let session: WorkoutSession

    enum Field: Hashable {
        case reps(Int)
        case weight(Int)
    }

    @FocusState private var focusedField: Field?

    @State private var selectedExercise: Exercise?
    @State private var searchText = ""
    @State private var trackSets = true
    @State private var repsPerSet: [Int] = [8, 8, 8, 8]
    @State private var weightPerSet: [Double] = [0, 0, 0, 0]
    @State private var trackDuration = false
    @State private var durationMinutes = 0
    @State private var durationSeconds = 0
    @State private var sentiment: Sentiment = .maintain
    @State private var notes = ""
    @State private var showingAddExercise = false

    private var setCount: Int { repsPerSet.count }

    private var filteredExercises: [Exercise] {
        if searchText.isEmpty { return exercises }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var canSave: Bool {
        (trackSets && setCount > 0) || (trackDuration && totalDurationSeconds > 0)
    }

    private var totalDurationSeconds: Int {
        durationMinutes * 60 + durationSeconds
    }

    private var loggedExerciseIDs: Set<UUID> {
        Set(session.exerciseLogs.compactMap { $0.exercise?.id })
    }

    var body: some View {
        NavigationStack {
            Group {
                if selectedExercise == nil {
                    exercisePickerView
                } else {
                    logFormView
                }
            }
            .navigationTitle(selectedExercise == nil ? "Pick Exercise" : selectedExercise!.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if selectedExercise != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { saveLog() }
                            .disabled(!canSave)
                    }
                }
            }
        }
    }

    // MARK: - Exercise Picker

    private var exercisePickerView: some View {
        List {
            if filteredExercises.isEmpty {
                ContentUnavailableView(
                    "No Exercises",
                    systemImage: "dumbbell",
                    description: Text("Add exercises in the Exercises tab first.")
                )
            } else {
                ForEach(filteredExercises) { exercise in
                    Button {
                        selectedExercise = exercise
                        loadPreviousData(for: exercise)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.name)
                                    .foregroundStyle(.primary)
                                if !exercise.notes.isEmpty {
                                    Text(exercise.notes)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if loggedExerciseIDs.contains(exercise.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search exercises")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingAddExercise = true
                } label: {
                    Label("New Exercise", systemImage: "plus.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView()
        }
    }

    // MARK: - Log Form

    private var logFormView: some View {
        Form {
            previousLogSection

            Section {
                Toggle("Track sets", isOn: $trackSets)
            }

            if trackSets {
                Section("Sets") {
                    Stepper("Sets: \(setCount)",
                            onIncrement: {
                                guard setCount < 20 else { return }
                                repsPerSet.append(repsPerSet.last ?? 8)
                                weightPerSet.append(weightPerSet.last ?? 0)
                            },
                            onDecrement: {
                                guard setCount > 1 else { return }
                                repsPerSet.removeLast()
                                weightPerSet.removeLast()
                            })

                    if setCount > 1 {
                        Button("Copy Set 1 to All") {
                            let reps = repsPerSet[0]
                            let weight = weightPerSet[0]
                            for i in 1..<setCount {
                                repsPerSet[i] = reps
                                weightPerSet[i] = weight
                            }
                        }
                        .font(.caption)
                    }

                    ForEach(repsPerSet.indices, id: \.self) { index in
                        HStack {
                            Text("Set \(index + 1)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 50, alignment: .leading)

                            TextField("Reps", value: $repsPerSet[index], format: .number)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 70)
                                .focused($focusedField, equals: .reps(index))

                            Text("reps @")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            TextField("Weight", value: $weightPerSet[index], format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                                .focused($focusedField, equals: .weight(index))

                            Text("lbs")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                Toggle("Track duration", isOn: $trackDuration)
            }

            if trackDuration {
                Section("Duration") {
                    HStack {
                        Picker("Minutes", selection: $durationMinutes) {
                            ForEach(0..<121) { Text("\($0) min").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)

                        Picker("Seconds", selection: $durationSeconds) {
                            ForEach(Array(stride(from: 0, through: 55, by: 5)), id: \.self) { sec in
                                Text("\(sec) sec").tag(sec)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 120)
                }
            }

            Section("Next Session") {
                SentimentPicker(selection: $sentiment)
            }

            Section("Notes (optional)") {
                TextField("How'd it go?", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { notification in
            if let textField = notification.object as? UITextField {
                DispatchQueue.main.async {
                    textField.selectAll(nil)
                }
            }
        }
    }

    @ViewBuilder
    private var previousLogSection: some View {
        if let exercise = selectedExercise,
           let previousLog = mostRecentLog(for: exercise) {
            Section("Previous") {
                HStack {
                    Text(previousLogSummary(previousLog))
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: previousLog.sentiment.systemImage)
                        .foregroundStyle(previousLog.sentiment.color)
                }
                .foregroundStyle(.secondary)
                if !previousLog.notes.isEmpty {
                    Text(previousLog.notes)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    // MARK: - Data Helpers

    private func loadPreviousData(for exercise: Exercise) {
        guard let prev = mostRecentLog(for: exercise) else { return }
        let sets = prev.sortedSets

        if !sets.isEmpty {
            trackSets = true
            repsPerSet = sets.map(\.reps)
            weightPerSet = sets.map(\.weight)
        } else {
            trackSets = false
        }

        if prev.durationSeconds > 0 {
            trackDuration = true
            durationMinutes = prev.durationSeconds / 60
            durationSeconds = prev.durationSeconds % 60
            // Snap seconds to nearest 5
            durationSeconds = (durationSeconds / 5) * 5
        } else {
            trackDuration = false
        }

        sentiment = prev.sentiment
    }

    private func mostRecentLog(for exercise: Exercise) -> ExerciseLog? {
        exercise.logs
            .filter { $0.session?.id != session.id }
            .sorted { $0.createdAt > $1.createdAt }
            .first
    }

    private func previousLogSummary(_ log: ExerciseLog) -> String {
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

    private func saveLog() {
        guard let exercise = selectedExercise else { return }

        // Dismiss focus so TextField commits its pending value to the binding
        focusedField = nil

        // Defer the actual save to the next run-loop tick so the binding update lands
        DispatchQueue.main.async {
            let duration = trackDuration ? totalDurationSeconds : 0
            let log = ExerciseLog(exercise: exercise, session: session, sentiment: sentiment, notes: notes.trimmingCharacters(in: .whitespaces), durationSeconds: duration)
            modelContext.insert(log)

            if trackSets {
                for i in 0..<setCount {
                    let set = ExerciseSet(
                        exerciseLog: log,
                        setNumber: i + 1,
                        reps: repsPerSet[i],
                        weight: weightPerSet[i]
                    )
                    modelContext.insert(set)
                }
            }

            try? modelContext.save()
            dismiss()
        }
    }
}
