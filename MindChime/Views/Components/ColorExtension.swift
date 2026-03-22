import SwiftUI

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double((rgb & 0x0000FF)) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

struct HabitIcon: Identifiable {
    let id: String
    let name: String
    let symbol: String

    static let allIcons: [HabitIcon] = [
        HabitIcon(id: "bed", name: "Make Bed", symbol: "bed.double.fill"),
        HabitIcon(id: "exercise", name: "Exercise", symbol: "figure.run"),
        HabitIcon(id: "water", name: "Drink Water", symbol: "drop.fill"),
        HabitIcon(id: "read", name: "Read", symbol: "book.fill"),
        HabitIcon(id: "meditate", name: "Meditate", symbol: "brain.head.profile"),
        HabitIcon(id: "journal", name: "Journal", symbol: "pencil.and.scribble"),
        HabitIcon(id: "sleep", name: "Sleep Early", symbol: "moon.fill"),
        HabitIcon(id: "walk", name: "Walk", symbol: "figure.walk"),
        HabitIcon(id: "cook", name: "Cook", symbol: "frying.pan.fill"),
        HabitIcon(id: "clean", name: "Clean", symbol: "sparkles"),
        HabitIcon(id: "study", name: "Study", symbol: "graduationcap.fill"),
        HabitIcon(id: "stretch", name: "Stretch", symbol: "figure.flexibility"),
        HabitIcon(id: "vitamins", name: "Vitamins", symbol: "pill.fill"),
        HabitIcon(id: "noscreen", name: "No Screen", symbol: "iphone.slash"),
        HabitIcon(id: "gratitude", name: "Gratitude", symbol: "heart.fill"),
        HabitIcon(id: "check", name: "Custom", symbol: "checkmark.circle.fill"),
    ]
}

let habitColors: [String] = [
    "#007AFF", "#34C759", "#FF9500", "#FF3B30",
    "#AF52DE", "#FF2D55", "#5856D6", "#00C7BE",
    "#FF6482", "#30B0C7", "#A2845E", "#8E8E93"
]
