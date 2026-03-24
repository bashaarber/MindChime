import SwiftData
import SwiftUI

@main
struct ChimeRiseApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Quote.self,
            Habit.self,
            HabitCompletion.self,
            ChimeAlarm.self,
            JournalEntry.self
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

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ContentView()
                    .onAppear {
                        NotificationService.shared.requestAuthorization()
                    }
            } else {
                OnboardingView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
