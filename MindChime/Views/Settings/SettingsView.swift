import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var quotes: [Quote]
    @Query private var habits: [Habit]
    @Query private var alarms: [ChimeAlarm]
    @AppStorage("speechRate") private var speechRate: Double = 0.9
    @AppStorage("autoPlayChime") private var autoPlayChime: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Chime Settings") {
                    Toggle("Auto-play chime sound", isOn: $autoPlayChime)

                    VStack(alignment: .leading) {
                        Text("Speech Rate")
                        Slider(value: $speechRate, in: 0.3...1.0, step: 0.1)
                        HStack {
                            Text("Slow")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("Fast")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Statistics") {
                    LabeledContent("Total Thoughts", value: "\(quotes.count)")
                    LabeledContent("Favorites", value: "\(quotes.filter(\.isFavorite).count)")
                    LabeledContent("Active Habits", value: "\(habits.filter { !$0.isArchived }.count)")
                    LabeledContent("Active Chimes", value: "\(alarms.filter(\.isEnabled).count)")
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Built with", value: "SwiftUI & SwiftData")
                }

                Section {
                    Button("Reset All Notifications") {
                        NotificationService.shared.removeAllNotifications()
                    }
                    .foregroundStyle(.orange)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(
            for: [Quote.self, Habit.self, ChimeAlarm.self],
            inMemory: true
        )
}
