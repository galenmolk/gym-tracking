import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var searchText = ""
    @State private var showingAddExercise = false

    private var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredExercises.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Exercises" : "No Results",
                        systemImage: searchText.isEmpty ? "dumbbell" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Tap + to add your first exercise." : "No exercises match \"\(searchText)\".")
                    )
                } else {
                    ForEach(filteredExercises) { exercise in
                        NavigationLink(value: exercise) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name)
                                        .font(.body)
                                    if !exercise.notes.isEmpty {
                                        Text(exercise.notes)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Text("\(exercise.logs.count)")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Exercises")
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddExercise = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView()
            }
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
        }
    }

}
