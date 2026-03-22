import SwiftUI
import SwiftData

@Observable
final class HabitsViewModel {
    var showingAddHabit = false
    var showingArchived = false

    func toggleCompletion(for habit: Habit, context: ModelContext) {
        let calendar = Calendar.current

        if let todayCompletion = habit.completions.first(where: {
            calendar.isDateInToday($0.date)
        }) {
            context.delete(todayCompletion)
        } else {
            let completion = HabitCompletion(date: .now, habit: habit)
            context.insert(completion)
        }

        try? context.save()
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
