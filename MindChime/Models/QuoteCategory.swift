import Foundation
import SwiftUI

enum QuoteCategory: String, Codable, CaseIterable, Identifiable {
    case motivation = "Motivation"
    case stoicism = "Stoicism"
    case mindfulness = "Mindfulness"
    case gratitude = "Gratitude"
    case courage = "Courage"
    case wisdom = "Wisdom"
    case happiness = "Happiness"
    case discipline = "Discipline"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .motivation: return "flame.fill"
        case .stoicism: return "building.columns.fill"
        case .mindfulness: return "leaf.fill"
        case .gratitude: return "heart.fill"
        case .courage: return "shield.fill"
        case .wisdom: return "book.fill"
        case .happiness: return "sun.max.fill"
        case .discipline: return "figure.strengthtraining.traditional"
        }
    }

    var color: Color {
        switch self {
        case .motivation: return .orange
        case .stoicism: return .indigo
        case .mindfulness: return .green
        case .gratitude: return .pink
        case .courage: return .red
        case .wisdom: return .purple
        case .happiness: return .yellow
        case .discipline: return .blue
        }
    }
}
