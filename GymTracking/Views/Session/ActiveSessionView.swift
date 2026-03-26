import SwiftUI
import SwiftData

struct ActiveSessionView: View {
    @Environment(\.modelContext) private var modelContext
    let session: WorkoutSession
    var onEnd: (WorkoutSession) -> Void

    @State private var elapsedTime = ""
    @State private var showingExercisePicker = false
    @State private var showingEndConfirmation = false
    @State private var showingExerciseLibrary = false
    @FocusState private var notesFieldFocused: Bool

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var sortedLogs: [ExerciseLog] {
        session.exerciseLogs.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text(elapsedTime)
                                .font(.system(.largeTitle, design: .monospaced))
                                .fontWeight(.medium)
                            Text("Elapsed")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                Section {
                    TextField("Session notes (e.g. locker #, code)", text: Binding(
                        get: { session.notes ?? "" },
                        set: { session.notes = $0 }
                    ), axis: .vertical)
                        .font(.subheadline)
                        .focused($notesFieldFocused)
                }

                if sortedLogs.isEmpty {
                    Section {
                        ContentUnavailableView("No Exercises Yet", systemImage: "dumbbell", description: Text("Tap Log Exercise to get started."))
                    }
                } else {
                    Section("Exercises (\(sortedLogs.count))") {
                        ForEach(sortedLogs) { log in
                            ExerciseLogCard(log: log)
                        }
                        .onDelete(perform: deleteLogs)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 70)
            }

            Button {
                showingExercisePicker = true
            } label: {
                Label("Log Exercise", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .accentColor.opacity(0.3), radius: 8, y: 4)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .navigationTitle("Active Workout")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingExerciseLibrary = true
                } label: {
                    Label("Exercises", systemImage: "list.bullet")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEndConfirmation = true
                } label: {
                    Label("End Workout", systemImage: "stop.fill")
                }
                .tint(.red)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { notesFieldFocused = false }
            }
        }
        .onAppear { updateElapsed() }
        .onReceive(timer) { _ in updateElapsed() }
        .sheet(isPresented: $showingExercisePicker) {
            ExerciseLogEntryView(session: session)
        }
        .sheet(isPresented: $showingExerciseLibrary) {
            NavigationStack {
                ExerciseLibraryView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showingExerciseLibrary = false }
                        }
                    }
            }
        }
        .alert("End Workout?", isPresented: $showingEndConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("End Workout", role: .destructive) {
                session.endedAt = Date()
                onEnd(session)
            }
        } message: {
            Text("You logged \(session.exerciseLogs.count) exercise(s) over \(elapsedTime).")
        }
    }

    private func updateElapsed() {
        elapsedTime = DateFormatting.elapsedTime(from: session.startedAt)
    }

    private func deleteLogs(at offsets: IndexSet) {
        for index in offsets {
            let log = sortedLogs[index]
            modelContext.delete(log)
        }
    }
}
