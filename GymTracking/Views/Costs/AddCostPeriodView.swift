import SwiftUI

struct AddCostPeriodView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var startDate = Date()
    @State private var totalCost: Double?

    @FocusState private var costFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name (e.g. Winter 2026 Term)", text: $name)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                }

                Section {
                    HStack {
                        Text("$")
                        TextField("Total Cost", value: $totalCost, format: .number)
                            .keyboardType(.decimalPad)
                            .focused($costFieldFocused)
                    }
                } footer: {
                    Text("The total amount paid for this period. You can change this later.")
                }
            }
            .navigationTitle("New Cost Period")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let period = CostPeriod(
                            name: name,
                            startDate: startDate,
                            totalCost: totalCost ?? 0
                        )
                        modelContext.insert(period)
                        dismiss()
                    }
                    .disabled(name.isEmpty || (totalCost ?? 0) <= 0)
                }
            }
        }
    }
}
