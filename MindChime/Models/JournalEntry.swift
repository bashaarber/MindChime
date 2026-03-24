import Foundation
import SwiftData

@Model
final class JournalEntry {
    var text: String
    var mood: Int // 0=great, 1=good, 2=okay, 3=tough, 4=stressed
    var date: Date
    var linkedQuoteText: String?
    var linkedQuoteAuthor: String?

    var moodEmoji: String {
        let emojis = ["😊", "🙂", "😐", "😔", "😤"]
        return mood < emojis.count ? emojis[mood] : "🙂"
    }

    var moodLabel: String {
        let labels = ["Great", "Good", "Okay", "Tough", "Stressed"]
        return mood < labels.count ? labels[mood] : "Good"
    }

    init(
        text: String,
        mood: Int = 1,
        linkedQuoteText: String? = nil,
        linkedQuoteAuthor: String? = nil
    ) {
        self.text = text
        self.mood = mood
        self.date = .now
        self.linkedQuoteText = linkedQuoteText
        self.linkedQuoteAuthor = linkedQuoteAuthor
    }
}
