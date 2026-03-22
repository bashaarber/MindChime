import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "checkmark.circle.fill"
    @State private var selectedColor = "#007AFF"
    @State private var hasReminder = false
    @State private var reminderTime = Calendar.current.date(
        from: DateComponents(hour: 8, minute: 0)
    ) ?? .now

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Name") {
                    TextField("e.g., Make the bed", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 4),
                        spacing: 16
                    ) {
                        ForEach(HabitIcon.allIcons) { icon in
                            Button {
                                selectedIcon = icon.symbol
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: icon.symbol)
                                        .font(.title2)
                                        .frame(width: 48, height: 48)
                                        .background(
                                            selectedIcon == icon.symbol
                                                ? Color(hex: selectedColor)?.opacity(0.15) ?? Color.blue.opacity(0.15)
                                                : Color(.tertiarySystemFill)
                                        )
                                        .foregroundStyle(
                                            selectedIcon == icon.symbol
                                                ? Color(hex: selectedColor) ?? .blue
                                                : .secondary
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))

                                    Text(icon.name)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Color") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 6),
                        spacing: 12
                    ) {
                        ForEach(habitColors, id: \.self) { hex in
                            Button {
                                selectedColor = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex) ?? .blue)
                                    .frame(width: 36, height: 36)
                                    .overlay {
                                        if selectedColor == hex {
                                            Image(systemName: "checkmark")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Reminder") {
                    Toggle("Daily Reminder", isOn: $hasReminder)
                    if hasReminder {
                        DatePicker(
                            "Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveHabit()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveHabit() {
        let habit = Habit(
            name: name.trimmingCharacters(in: .whitespaces),
            iconName: selectedIcon,
            colorHex: selectedColor,
            reminderTime: hasReminder ? reminderTime : nil
        )
        modelContext.insert(habit)
        try? modelContext.save()
    }
}

#Preview {
    AddHabitView()
        .modelContainer(for: Habit.self, inMemory: true)
}
