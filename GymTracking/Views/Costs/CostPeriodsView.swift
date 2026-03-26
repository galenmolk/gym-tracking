import SwiftUI
import SwiftData

struct CostPeriodsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CostPeriod.startDate, order: .reverse) private var periods: [CostPeriod]
    @Query(filter: #Predicate<WorkoutSession> { $0.endedAt != nil }) private var completedSessions: [WorkoutSession]

    @State private var showingAddPeriod = false

    var body: some View {
        NavigationStack {
            List {
                if periods.isEmpty {
                    ContentUnavailableView(
                        "No Cost Periods",
                        systemImage: "dollarsign.circle",
                        description: Text("Track your gym membership cost per visit.")
                    )
                } else {
                    ForEach(periods) { period in
                        NavigationLink(value: period) {
                            CostPeriodRow(period: period, visitCount: visitCount(for: period))
                        }
                    }
                    .onDelete(perform: deletePeriods)
                }
            }
            .navigationTitle("Cost Tracking")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddPeriod = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPeriod) {
                AddCostPeriodView()
            }
            .navigationDestination(for: CostPeriod.self) { period in
                CostPeriodDetailView(period: period)
            }
        }
    }

    private func visitCount(for period: CostPeriod) -> Int {
        completedSessions.filter { session in
            session.startedAt >= period.startDate &&
            (period.endDate == nil || session.startedAt <= period.endDate!)
        }.count
    }

    private func deletePeriods(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(periods[index])
        }
    }
}

private struct CostPeriodRow: View {
    let period: CostPeriod
    let visitCount: Int

    private func dollarString(_ value: Double) -> String {
        formatDollars(value)
    }

    private var costPerVisit: Double? {
        visitCount > 0 ? period.totalCost / Double(visitCount) : nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(period.name)
                    .font(.headline)
                Spacer()
                if period.isActive {
                    Text("Active")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                }
            }

            HStack(spacing: 8) {
                Label(dollarString(period.totalCost), systemImage: "dollarsign.circle")
                Label("\(visitCount) visits", systemImage: "figure.strengthtraining.traditional")
                if let cpv = costPerVisit {
                    Label("\(dollarString(cpv))/visit", systemImage: "arrow.down.right")
                        .foregroundStyle(.green)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
        .padding(.vertical, 2)
    }
}

func formatDollars(_ value: Double) -> String {
    let cents = Int((value * 100).rounded())
    return cents % 100 == 0
        ? "$\(cents / 100)"
        : String(format: "$%.2f", value)
}
