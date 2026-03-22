import SwiftUI
import SwiftData

struct QuoteFeedView: View {
    @Query(sort: \Quote.createdAt) private var allQuotes: [Quote]
    @State private var viewModel = QuotesViewModel()
    @State private var showingFilters = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    CategoryFilterChips(
                        selectedCategories: $viewModel.selectedCategories
                    )
                    .padding(.horizontal)

                    ForEach(viewModel.filteredQuotes(from: allQuotes)) { quote in
                        QuoteCardView(quote: quote)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Thoughts")
            .searchable(text: $viewModel.searchText, prompt: "Search thoughts...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showFavoritesOnly.toggle()
                    } label: {
                        Image(systemName: viewModel.showFavoritesOnly ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.showFavoritesOnly ? .red : .primary)
                    }
                }
            }
        }
    }
}

struct CategoryFilterChips: View {
    @Binding var selectedCategories: Set<QuoteCategory>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(QuoteCategory.allCases) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategories.contains(category)
                    ) {
                        if selectedCategories.contains(category) {
                            if selectedCategories.count > 1 {
                                selectedCategories.remove(category)
                            }
                        } else {
                            selectedCategories.insert(category)
                        }
                    }
                }
            }
        }
    }
}

struct CategoryChip: View {
    let category: QuoteCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? category.color.opacity(0.15) : Color(.tertiarySystemFill)
            )
            .foregroundStyle(isSelected ? category.color : .secondary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    QuoteFeedView()
        .modelContainer(for: Quote.self, inMemory: true)
}
