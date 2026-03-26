import SwiftUI
import SwiftData

@main
struct GymTrackingApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema(versionedSchema: SchemaV2.self)
            let config = ModelConfiguration(schema: schema)
            modelContainer = try ModelContainer(
                for: schema,
                migrationPlan: GymTrackingMigrationPlan.self,
                configurations: [config]
            )
        } catch {
            fatalError("Failed to configure SwiftData: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
