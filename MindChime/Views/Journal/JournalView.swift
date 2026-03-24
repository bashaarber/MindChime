import SwiftData
import SwiftUI

struct JournalView: View {
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @Query(sort: \Quote.createdAt) private var quotes: [Quote]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddEntry = false
    @State private var showingPremium = false
    @State private var store = StoreKitService.shared

    private var todayEntries: [JournalEntry] {
        entries.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var pastEntries: [JournalEntry] {
        entries.filter { !Calendar.current.isDateInToday($0.date) }
    }

    private var todayQuote: Quote? {
        guard !quotes.isEmpty else { return nil }
        let dayNumber = Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 0
        return quotes[dayNumber % quotes.count]
    }

    var body: some View {
        NavigationStack {
            Group {
                if !store.isPremium {
                    premiumGate
                } else {
                    journalContent
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                if store.isPremium {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAddEntry = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddJournalEntryView(suggestedQuote: todayQuote)
            }
            .sheet(isPresented: $showingPremium) {
                PremiumView()
            }
        }
    }

    private var premiumGate: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.purple)
            }

            VStack(spacing: 10) {
                Text("Daily Journal")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Reflect on your day, track your mood, and grow with guided daily prompts. A Premium feature.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }

            Button("Unlock with Premium") {
                showingPremium = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var journalContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Today's prompt card
                if let quote = todayQuote {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Today's Reflection Prompt", systemImage: "lightbulb.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)

                        Text("\"\(quote.text)\"")
                            .font(.subheadline)
                            .fontDesign(.serif)
                            .italic()
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)

                        Text("— \(quote.author)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                }

                // Today's entry or prompt to write
                if todayEntries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "pencil.and.scribble")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)

                        Text("How's your day going?")
                            .font(.headline)

                        Text("Take a moment to reflect. It only takes a minute.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Write Today's Entry") {
                            showingAddEntry = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 20)
                } else {
                    sectionBlock(title: "Today", entries: todayEntries)
                }

                if !pastEntries.isEmpty {
                    sectionBlock(title: "Earlier", entries: pastEntries)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func sectionBlock(title: String, entries: [JournalEntry]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

            ForEach(entries) { entry in
                JournalEntryCard(entry: entry)
                    .padding(.horizontal)
            }
        }
    }
}

struct JournalEntryCard: View {
    @Bindable var entry: JournalEntry
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(entry.moodEmoji + " " + entry.moodLabel)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Text(entry.text)
                .font(.body)
                .lineSpacing(3)

            if let quoteText = entry.linkedQuoteText {
                Divider()
                Text("\"\(quoteText)\"")
                    .font(.caption)
                    .fontDesign(.serif)
                    .italic()
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        .contextMenu {
            Button("Delete", systemImage: "trash", role: .destructive) {
                modelContext.delete(entry)
                try? modelContext.save()
            }
        }
    }
}

struct AddJournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let suggestedQuote: Quote?

    @State private var text = ""
    @State private var selectedMood = 1

    private let moods: [(emoji: String, label: String)] = [
        ("😊", "Great"),
        ("🙂", "Good"),
        ("😐", "Okay"),
        ("😔", "Tough"),
        ("😤", "Stressed")
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("How are you feeling?") {
                    HStack(spacing: 0) {
                        ForEach(moods.indices, id: \.self) { index in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedMood = index
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(moods[index].emoji)
                                        .font(.title2)
                                    Text(moods[index].label)
                                        .font(.caption2)
                                        .foregroundStyle(selectedMood == index ? .primary : .tertiary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    selectedMood == index
                                        ? Color.accentColor.opacity(0.12)
                                        : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 10)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .sensoryFeedback(.selection, trigger: selectedMood)
                }

                if let quote = suggestedQuote {
                    Section("Today's Prompt") {
                        Text("\"\(quote.text)\"")
                            .font(.subheadline)
                            .fontDesign(.serif)
                            .italic()
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                        Text("— \(quote.author)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Section("Your Reflection") {
                    TextEditor(text: $text)
                        .frame(minHeight: 120)
                        .font(.body)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveEntry() {
        let entry = JournalEntry(
            text: text.trimmingCharacters(in: .whitespaces),
            mood: selectedMood,
            linkedQuoteText: suggestedQuote?.text,
            linkedQuoteAuthor: suggestedQuote?.author
        )
        modelContext.insert(entry)
        try? modelContext.save()
    }
}

#Preview {
    JournalView()
        .modelContainer(for: [JournalEntry.self, Quote.self], inMemory: true)
}
