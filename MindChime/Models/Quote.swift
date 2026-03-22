import Foundation
import SwiftData

@Model
final class Quote {
    var text: String
    var author: String
    var categoryRaw: String
    var isFavorite: Bool
    var createdAt: Date

    var category: QuoteCategory {
        get { QuoteCategory(rawValue: categoryRaw) ?? .wisdom }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        text: String,
        author: String,
        category: QuoteCategory,
        isFavorite: Bool = false
    ) {
        self.text = text
        self.author = author
        self.categoryRaw = category.rawValue
        self.isFavorite = isFavorite
        self.createdAt = .now
    }
}
