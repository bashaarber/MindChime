import SwiftData
import SwiftUI

struct QuoteFeedView: View {
    @Query(sort: \Quote.createdAt) private var allQuotes: [Quote]
    @State private var viewModel = QuotesViewModel()

    private var dailyQuote: Quote? {
        guard !allQuotes.isEmpty else { return nil }
        let dayNumber = Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 0
        return allQuotes[dayNumber % allQuotes.count]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Daily Thought card (always visible, not filtered)
                    if let quote = dailyQuote {
                        DailyThoughtCard(quote: quote)
                            .padding(.horizontal)
                    }

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

struct DailyThoughtCard: View {
    @Bindable var quote: Quote
    @State private var speechService = SpeechService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Today's Thought", systemImage: "sun.max.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)

                Spacer()

                Text(Date.now, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Text(quote.text)
                .font(.headline)
                .fontDesign(.serif)
                .lineSpacing(4)
                .foregroundStyle(.primary)

            HStack {
                Text("— \(quote.author)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    if speechService.isSpeaking {
                        speechService.stop()
                    } else {
                        AudioService.shared.playChimeSound()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            speechService.speak(quote.text, author: quote.author)
                        }
                    }
                } label: {
                    Image(systemName: speechService.isSpeaking ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)

                ShareLink(
                    item: "\"\(quote.text)\" — \(quote.author)",
                    subject: Text("Chime Rise Daily Thought"),
                    message: Text("Today's thought from Chime Rise")
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.10), Color.yellow.opacity(0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.orange.opacity(0.18), lineWidth: 1)
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
