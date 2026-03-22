import Foundation
import SwiftData

@Model
final class ChimeAlarm {
    var time: Date
    var label: String
    var isEnabled: Bool
    var selectedCategoriesRaw: [String]
    var soundName: String
    var repeatDays: [Int] // 1 = Sunday, 7 = Saturday

    var selectedCategories: [QuoteCategory] {
        get {
            selectedCategoriesRaw.compactMap { QuoteCategory(rawValue: $0) }
        }
        set {
            selectedCategoriesRaw = newValue.map(\.rawValue)
        }
    }

    init(
        time: Date = .now,
        label: String = "Morning Chime",
        isEnabled: Bool = true,
        selectedCategories: [QuoteCategory] = QuoteCategory.allCases,
        soundName: String = "chime_gentle",
        repeatDays: [Int] = [1, 2, 3, 4, 5, 6, 7]
    ) {
        self.time = time
        self.label = label
        self.isEnabled = isEnabled
        self.selectedCategoriesRaw = selectedCategories.map(\.rawValue)
        self.soundName = soundName
        self.repeatDays = repeatDays
    }

    var repeatDaysText: String {
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        if repeatDays.count == 7 { return "Every day" }
        if repeatDays.sorted() == [2, 3, 4, 5, 6] { return "Weekdays" }
        if repeatDays.sorted() == [1, 7] { return "Weekends" }
        return repeatDays.sorted().map { dayNames[$0 - 1] }.joined(separator: ", ")
    }
}
