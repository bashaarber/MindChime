import SwiftUI
import SwiftData

@main
struct MindChimeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Quote.self,
            Habit.self,
            HabitCompletion.self,
            ChimeAlarm.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            QuoteSeeder.seedIfNeeded(context: container.mainContext)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NotificationService.shared.requestAuthorization()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
