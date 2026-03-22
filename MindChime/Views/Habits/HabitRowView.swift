import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let onToggle: () -> Void

    private var isCompleted: Bool {
        habit.isCompletedToday()
    }

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCompleted ? habit.color : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: isCompleted)

            Image(systemName: habit.iconName)
                .font(.body)
                .foregroundStyle(habit.color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(isCompleted, color: .secondary)
                    .foregroundStyle(isCompleted ? .secondary : .primary)

                HStack(spacing: 12) {
                    if habit.currentStreak() > 0 {
                        Label("\(habit.currentStreak()) day streak", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    let rate = habit.completionRate()
                    if rate > 0 {
                        Text("\(Int(rate * 100))% · 30d")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()

            // Mini streak visualization (last 7 days)
            HStack(spacing: 3) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(
                        byAdding: .day,
                        value: -(6 - dayOffset),
                        to: .now
                    ) ?? .now
                    let wasCompleted = habit.completions.contains {
                        Calendar.current.isDate($0.date, inSameDayAs: date)
                    }
                    Circle()
                        .fill(wasCompleted ? habit.color : Color(.tertiarySystemFill))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }
}
