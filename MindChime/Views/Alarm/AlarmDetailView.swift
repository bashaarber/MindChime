import SwiftUI
import SwiftData

struct AlarmDetailView: View {
    @Bindable var alarm: ChimeAlarm
    let quotes: [Quote]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Time", selection: $alarm.time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }

                Section("Label") {
                    TextField("Alarm Label", text: $alarm.label)
                }

                Section("Repeat") {
                    HStack(spacing: 8) {
                        ForEach(1...7, id: \.self) { day in
                            let index = day == 1 ? 6 : day - 2 // Reorder to Mon-Sun
                            let actualDay = index == 6 ? 1 : index + 2
                            DayToggle(
                                label: dayLabels[actualDay - 1],
                                isSelected: alarm.repeatDays.contains(actualDay)
                            ) {
                                if alarm.repeatDays.contains(actualDay) {
                                    alarm.repeatDays.removeAll { $0 == actualDay }
                                } else {
                                    alarm.repeatDays.append(actualDay)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                Section("Thought Categories") {
                    ForEach(QuoteCategory.allCases) { category in
                        Toggle(isOn: Binding(
                            get: { alarm.selectedCategories.contains(category) },
                            set: { isOn in
                                if isOn {
                                    alarm.selectedCategoriesRaw.append(category.rawValue)
                                } else if alarm.selectedCategories.count > 1 {
                                    alarm.selectedCategoriesRaw.removeAll { $0 == category.rawValue }
                                }
                            }
                        )) {
                            Label(category.rawValue, systemImage: category.icon)
                                .foregroundStyle(category.color)
                        }
                        .tint(category.color)
                    }
                }

                Section {
                    Button("Preview Chime") {
                        previewChime()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Edit Chime")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func save() {
        if alarm.isEnabled, let quote = filteredQuote() {
            NotificationService.shared.scheduleAlarm(alarm, quote: quote)
        }
        try? modelContext.save()
    }

    private func filteredQuote() -> Quote? {
        let categories = alarm.selectedCategories
        return quotes.filter { categories.contains($0.category) }.randomElement()
    }

    private func previewChime() {
        AudioService.shared.playChimeSound()
        if let quote = filteredQuote() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                SpeechService.shared.speak(quote.text, author: quote.author)
            }
        }
    }
}

struct DayToggle: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(String(label.prefix(1)))
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 36, height: 36)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill))
                .foregroundStyle(isSelected ? .white : .secondary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}
