import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .quotes

    enum AppTab: String {
        case quotes, chimes, habits, journal, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Thoughts", systemImage: "quote.opening", value: AppTab.quotes) {
                QuoteFeedView()
            }
            Tab("Chimes", systemImage: "bell.fill", value: AppTab.chimes) {
                AlarmListView()
            }
            Tab("Habits", systemImage: "checkmark.circle.fill", value: AppTab.habits) {
                HabitListView()
            }
            Tab("Journal", systemImage: "book.pages.fill", value: AppTab.journal) {
                JournalView()
            }
            Tab("Settings", systemImage: "gearshape.fill", value: AppTab.settings) {
                SettingsView()
            }
        }
        .tint(.accentColor)
    }
}

extension ContentView.AppTab: CaseIterable {
    var title: String {
        switch self {
        case .quotes: return "Thoughts"
        case .chimes: return "Chimes"
        case .habits: return "Habits"
        case .journal: return "Journal"
        case .settings: return "Settings"
        }
    }
}

#Preview {
    ContentView()
}
