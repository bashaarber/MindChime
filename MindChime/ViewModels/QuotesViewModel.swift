import SwiftUI
import SwiftData

@Observable
final class QuotesViewModel {
    var selectedCategories: Set<QuoteCategory> = Set(QuoteCategory.allCases)
    var searchText: String = ""
    var showFavoritesOnly: Bool = false

    func filteredQuotes(from quotes: [Quote]) -> [Quote] {
        quotes.filter { quote in
            let matchesCategory = selectedCategories.contains(quote.category)
            let matchesFavorite = !showFavoritesOnly || quote.isFavorite
            let matchesSearch = searchText.isEmpty ||
                quote.text.localizedCaseInsensitiveContains(searchText) ||
                quote.author.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesFavorite && matchesSearch
        }
    }

    func toggleCategory(_ category: QuoteCategory) {
        if selectedCategories.contains(category) {
            if selectedCategories.count > 1 {
                selectedCategories.remove(category)
            }
        } else {
            selectedCategories.insert(category)
        }
    }

    func selectAllCategories() {
        selectedCategories = Set(QuoteCategory.allCases)
    }

    func randomQuote(from quotes: [Quote]) -> Quote? {
        filteredQuotes(from: quotes).randomElement()
    }
}
