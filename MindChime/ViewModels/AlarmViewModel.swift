import SwiftUI
import SwiftData

@Observable
final class AlarmViewModel {
    var showingAddAlarm = false

    func createAlarm(context: ModelContext) -> ChimeAlarm {
        let alarm = ChimeAlarm()
        context.insert(alarm)
        try? context.save()
        return alarm
    }

    func deleteAlarm(_ alarm: ChimeAlarm, context: ModelContext) {
        NotificationService.shared.removeAlarmNotifications(for: alarm)
        context.delete(alarm)
        try? context.save()
    }

    func toggleAlarm(_ alarm: ChimeAlarm, quotes: [Quote], context: ModelContext) {
        alarm.isEnabled.toggle()
        if alarm.isEnabled, let quote = quotes.randomElement() {
            NotificationService.shared.scheduleAlarm(alarm, quote: quote)
        } else {
            NotificationService.shared.removeAlarmNotifications(for: alarm)
        }
        try? context.save()
    }

    func scheduleAllAlarms(_ alarms: [ChimeAlarm], quotes: [Quote]) {
        for alarm in alarms where alarm.isEnabled {
            if let quote = quotes.randomElement() {
                NotificationService.shared.scheduleAlarm(alarm, quote: quote)
            }
        }
    }
}
