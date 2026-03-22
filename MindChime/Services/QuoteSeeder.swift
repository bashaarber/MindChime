import Foundation
import SwiftData

struct QuoteSeeder {
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Quote>()
        let count = (try? context.fetchCount(descriptor)) ?? 0

        guard count == 0 else { return }

        let quotes = defaultQuotes()
        for quote in quotes {
            context.insert(quote)
        }
        try? context.save()
    }

    static func defaultQuotes() -> [Quote] {
        [
            // Motivation
            Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs", category: .motivation),
            Quote(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius", category: .motivation),
            Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt", category: .motivation),
            Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt", category: .motivation),
            Quote(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill", category: .motivation),

            // Stoicism
            Quote(text: "The happiness of your life depends upon the quality of your thoughts.", author: "Marcus Aurelius", category: .stoicism),
            Quote(text: "We suffer more often in imagination than in reality.", author: "Seneca", category: .stoicism),
            Quote(text: "You have power over your mind — not outside events. Realize this, and you will find strength.", author: "Marcus Aurelius", category: .stoicism),
            Quote(text: "Wealth consists not in having great possessions, but in having few wants.", author: "Epictetus", category: .stoicism),
            Quote(text: "The best revenge is not to be like your enemy.", author: "Marcus Aurelius", category: .stoicism),

            // Mindfulness
            Quote(text: "The present moment is filled with joy and happiness. If you are attentive, you will see it.", author: "Thich Nhat Hanh", category: .mindfulness),
            Quote(text: "Feelings come and go like clouds in a windy sky. Conscious breathing is my anchor.", author: "Thich Nhat Hanh", category: .mindfulness),
            Quote(text: "In today's rush, we all think too much, seek too much, want too much, and forget about the joy of just being.", author: "Eckhart Tolle", category: .mindfulness),
            Quote(text: "Be where you are, not where you think you should be.", author: "Unknown", category: .mindfulness),
            Quote(text: "Almost everything will work again if you unplug it for a few minutes, including you.", author: "Anne Lamott", category: .mindfulness),

            // Gratitude
            Quote(text: "Gratitude turns what we have into enough.", author: "Melody Beattie", category: .gratitude),
            Quote(text: "Enjoy the little things, for one day you may look back and realize they were the big things.", author: "Robert Brault", category: .gratitude),
            Quote(text: "When I started counting my blessings, my whole life turned around.", author: "Willie Nelson", category: .gratitude),
            Quote(text: "The root of joy is gratefulness.", author: "David Steindl-Rast", category: .gratitude),

            // Courage
            Quote(text: "Courage is not the absence of fear, but the triumph over it.", author: "Nelson Mandela", category: .courage),
            Quote(text: "Life shrinks or expands in proportion to one's courage.", author: "Anaïs Nin", category: .courage),
            Quote(text: "You gain strength, courage, and confidence by every experience in which you really stop to look fear in the face.", author: "Eleanor Roosevelt", category: .courage),
            Quote(text: "He who is not courageous enough to take risks will accomplish nothing in life.", author: "Muhammad Ali", category: .courage),

            // Wisdom
            Quote(text: "The only true wisdom is in knowing you know nothing.", author: "Socrates", category: .wisdom),
            Quote(text: "In the middle of difficulty lies opportunity.", author: "Albert Einstein", category: .wisdom),
            Quote(text: "Knowing yourself is the beginning of all wisdom.", author: "Aristotle", category: .wisdom),
            Quote(text: "The mind is everything. What you think you become.", author: "Buddha", category: .wisdom),
            Quote(text: "Turn your wounds into wisdom.", author: "Oprah Winfrey", category: .wisdom),

            // Happiness
            Quote(text: "Happiness is not something ready-made. It comes from your own actions.", author: "Dalai Lama", category: .happiness),
            Quote(text: "The purpose of our lives is to be happy.", author: "Dalai Lama", category: .happiness),
            Quote(text: "For every minute you are angry you lose sixty seconds of happiness.", author: "Ralph Waldo Emerson", category: .happiness),
            Quote(text: "Happiness depends upon ourselves.", author: "Aristotle", category: .happiness),

            // Discipline
            Quote(text: "Discipline is the bridge between goals and accomplishment.", author: "Jim Rohn", category: .discipline),
            Quote(text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.", author: "Aristotle", category: .discipline),
            Quote(text: "The secret of your future is hidden in your daily routine.", author: "Mike Murdock", category: .discipline),
            Quote(text: "Small disciplines repeated with consistency every day lead to great achievements gained slowly over time.", author: "John C. Maxwell", category: .discipline),
            Quote(text: "Motivation gets you going, but discipline keeps you growing.", author: "John C. Maxwell", category: .discipline),
        ]
    }
}
