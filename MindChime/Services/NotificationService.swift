import UserNotifications
import Foundation

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    func scheduleAlarm(_ alarm: ChimeAlarm, quote: Quote) {
        guard alarm.isEnabled else { return }

        removeAlarmNotifications(for: alarm)

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: alarm.time)
        let minute = calendar.component(.minute, from: alarm.time)

        for day in alarm.repeatDays {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.weekday = day

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )

            let content = UNMutableNotificationContent()
            content.title = "Chime Rise"
            content.subtitle = alarm.label
            content.body = "\"\(quote.text)\" — \(quote.author)"
            content.sound = .default
            content.categoryIdentifier = "CHIME_ALARM"

            let identifier = "\(alarm.persistentModelID)-day\(day)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    print("Failed to schedule notification: \(error)")
                }
            }
        }
    }

    func removeAlarmNotifications(for alarm: ChimeAlarm) {
        let identifiers = alarm.repeatDays.map { "\(alarm.persistentModelID)-day\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }

    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
