import StoreKit
import SwiftData
import SwiftUI

struct SettingsView: View {
    @Query private var quotes: [Quote]
    @Query private var habits: [Habit]
    @Query private var alarms: [ChimeAlarm]
    @Query private var journalEntries: [JournalEntry]
    @AppStorage("speechRate") private var speechRate: Double = 0.5
    @AppStorage("autoPlayChime") private var autoPlayChime: Bool = true
    @State private var store = StoreKitService.shared
    @State private var showingPremium = false
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        NavigationStack {
            Form {
                // Premium section
                Section {
                    Button {
                        showingPremium = true
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.yellow.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "sparkles")
                                    .font(.body)
                                    .foregroundStyle(.yellow)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(store.isPremium ? "MindChime Premium" : "Upgrade to Premium")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                Text(store.isPremium ? "All features unlocked" : "Unlimited habits, journal & more")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if store.isPremium {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(.green)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(store.isPremium)
                }

                Section("Chime Settings") {
                    Toggle("Auto-play chime sound", isOn: $autoPlayChime)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Speech Rate")
                            Spacer()
                            Text(speechRateLabel)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $speechRate, in: 0.3...0.9, step: 0.1)
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
                    LabeledContent("Journal Entries", value: "\(journalEntries.count)")
                }

                Section("Support") {
                    Button {
                        requestReview()
                    } label: {
                        Label("Rate MindChime", systemImage: "star.fill")
                            .foregroundStyle(.primary)
                    }

                    Button("Reset All Notifications") {
                        NotificationService.shared.removeAllNotifications()
                    }
                    .foregroundStyle(.orange)
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Built with", value: "SwiftUI & SwiftData")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPremium) {
                PremiumView()
            }
        }
    }

    private var speechRateLabel: String {
        switch speechRate {
        case ..<0.4: return "Slow"
        case ..<0.6: return "Normal"
        case ..<0.8: return "Fast"
        default: return "Very Fast"
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(
            for: [Quote.self, Habit.self, ChimeAlarm.self, JournalEntry.self],
            inMemory: true
        )
}
