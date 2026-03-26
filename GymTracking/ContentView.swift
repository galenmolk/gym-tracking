import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SessionTabView()
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                }

            ExerciseLibraryView()
                .tabItem {
                    Label("Exercises", systemImage: "list.bullet")
                }

            CostPeriodsView()
                .tabItem {
                    Label("Costs", systemImage: "dollarsign.circle")
                }
        }
    }
}
