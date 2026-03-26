import SwiftUI
import SwiftData

struct CostPeriodDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<WorkoutSession> { $0.endedAt != nil },
        sort: \WorkoutSession.startedAt,
        order: .reverse
    ) private var completedSessions: [WorkoutSession]

    @Bindable var period: CostPeriod

    @State private var editingCost: Double?
    @State private var isEditingCost = false
    @State private var showEndConfirmation = false

    private var visits: [WorkoutSession] {
        completedSessions.filter { session in
            session.startedAt >= period.startDate &&
            (period.endDate == nil || session.startedAt <= period.endDate!)
        }
    }

    private var costPerVisit: Double? {
        visits.isEmpty ? nil : period.totalCost / Double(visits.count)
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    if let cpv = costPerVisit {
                        Text(formatDollars(cpv))
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        Text("per visit")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                    } else {
                        Text("No visits yet")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            Section {
                HStack {
                    Text("Total Cost")
                    Spacer()
                    if isEditingCost {
                        HStack {
                            Text("$")
                            TextField("Cost", value: $editingCost, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                        Button("Save") {
                            period.totalCost = editingCost ?? period.totalCost
                            isEditingCost = false
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    } else {
                        Text(formatDollars(period.totalCost))
                            .foregroundStyle(.secondary)
                        Button("Edit") {
                            editingCost = period.totalCost
                            isEditingCost = true
                        }
                        .controlSize(.small)
                    }
                }

                HStack {
                    Text("Visits")
                    Spacer()
                    Text("\(visits.count)")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Started")
                    Spacer()
                    Text(DateFormatting.shortDate(period.startDate))
                        .foregroundStyle(.secondary)
                }

                if let endDate = period.endDate {
                    HStack {
                        Text("Ended")
                        Spacer()
                        Text(DateFormatting.shortDate(endDate))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if period.isActive {
                Section {
                    Button("End Period") {
                        showEndConfirmation = true
                    }
                    .foregroundStyle(.red)
                }
            }

            if !visits.isEmpty {
                Section("Sessions") {
                    ForEach(visits) { session in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(DateFormatting.sessionDate(session.startedAt))
                                    .font(.subheadline)
                                Text("\(session.exerciseLogs.count) exercises")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if let end = session.endedAt {
                                Text(DateFormatting.elapsedTime(from: session.startedAt, to: end))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(period.name)
        .alert("End Period?", isPresented: $showEndConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("End Period") {
                period.endDate = Date()
            }
        } message: {
            if let cpv = costPerVisit {
                Text("Final cost per visit: \(formatDollars(cpv)) over \(visits.count) visits.")
            } else {
                Text("No visits were logged during this period.")
            }
        }
    }
}
