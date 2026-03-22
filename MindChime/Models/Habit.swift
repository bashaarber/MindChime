import Foundation
import SwiftData
import SwiftUI

@Model
final class Habit {
    var name: String
    var iconName: String
    var colorHex: String
    var reminderTime: Date?
    var isArchived: Bool
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion]

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    init(
        name: String,
        iconName: String = "checkmark.circle.fill",
        colorHex: String = "#007AFF",
        reminderTime: Date? = nil
    ) {
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.reminderTime = reminderTime
        self.isArchived = false
        self.createdAt = .now
        self.completions = []
    }

    func isCompletedToday() -> Bool {
        let calendar = Calendar.current
        return completions.contains { completion in
            calendar.isDateInToday(completion.date)
        }
    }

    func currentStreak() -> Int {
        let calendar = Calendar.current
        let sortedDates = completions
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)

        guard !sortedDates.isEmpty else { return 0 }

        let uniqueDates = Array(Set(sortedDates)).sorted(by: >)

        var streak = 0
        var expectedDate = calendar.startOfDay(for: .now)

        // If not completed today, start from yesterday
        if uniqueDates.first != expectedDate {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: expectedDate) else {
                return 0
            }
            expectedDate = yesterday
        }

        for date in uniqueDates {
            if date == expectedDate {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: expectedDate) else {
                    break
                }
                expectedDate = previousDay
            } else if date < expectedDate {
                break
            }
        }

        return streak
    }

    func completionRate(days: Int = 30) -> Double {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: .now) else {
            return 0
        }
        let recentCompletions = completions.filter { $0.date >= startDate }
        let uniqueDays = Set(recentCompletions.map { calendar.startOfDay(for: $0.date) })
        return Double(uniqueDays.count) / Double(days)
    }
}
