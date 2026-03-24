import SwiftData
import SwiftUI

@Observable
final class HabitsViewModel {
    var showingAddHabit = false
    var showingArchived = false
    var streakMilestone: Int? = nil

    static let milestones: Set<Int> = [7, 14, 21, 30, 50, 100, 365]
    static let freeHabitLimit = 5

    func toggleCompletion(for habit: Habit, context: ModelContext) {
        let calendar = Calendar.current

        if let todayCompletion = habit.completions.first(where: {
            calendar.isDateInToday($0.date)
        }) {
            context.delete(todayCompletion)
            try? context.save()
        } else {
            let completion = HabitCompletion(date: .now, habit: habit)
            context.insert(completion)
            try? context.save()

            let streak = habit.currentStreak()
            if Self.milestones.contains(streak) {
                streakMilestone = streak
            }
        }
    }

    func deleteHabit(_ habit: Habit, context: ModelContext) {
        context.delete(habit)
        try? context.save()
    }

    func archiveHabit(_ habit: Habit, context: ModelContext) {
        habit.isArchived.toggle()
        try? context.save()
    }
}
