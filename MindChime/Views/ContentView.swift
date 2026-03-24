import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .quotes

    enum Tab: String {
        case quotes, chimes, habits, journal, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(.quotes, systemImage: "quote.opening") {
                QuoteFeedView()
            }
            Tab(.chimes, systemImage: "bell.fill") {
                AlarmListView()
            }
            Tab(.habits, systemImage: "checkmark.circle.fill") {
                HabitListView()
            }
            Tab(.journal, systemImage: "book.pages.fill") {
                JournalView()
            }
            Tab(.settings, systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
        .tint(.primary)
    }
}

extension ContentView.Tab: CaseIterable {
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
