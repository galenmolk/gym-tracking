import SwiftUI

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var notes = ""
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Exercise name", text: $name)
                        .focused($nameFieldFocused)
                }
                Section("Notes (optional)") {
                    TextField("e.g., use wide grip", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .onAppear { nameFieldFocused = true }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let exercise = Exercise(name: name.trimmingCharacters(in: .whitespaces), notes: notes.trimmingCharacters(in: .whitespaces))
                        modelContext.insert(exercise)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
