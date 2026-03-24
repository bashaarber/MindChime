import SwiftData
import SwiftUI

struct HabitListView: View {
    @Query(
        filter: #Predicate<Habit> { !$0.isArchived },
        sort: \Habit.createdAt
    ) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HabitsViewModel()
    @State private var store = StoreKitService.shared
    @State private var showingPremiumLimit = false
    @State private var showingPremium = false

    private var completedCount: Int {
        habits.filter { $0.isCompletedToday() }.count
    }

    private var canAddHabit: Bool {
        store.isPremium || habits.count < HabitsViewModel.freeHabitLimit
    }

    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    ContentUnavailableView {
                        Label("No Habits", systemImage: "leaf")
                    } description: {
                        Text("Start building positive habits. Track your daily progress and build streaks.")
                    } actions: {
                        Button("Add Habit") {
                            viewModel.showingAddHabit = true
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            DailyProgressView(
                                completed: completedCount,
                                total: habits.count
                            )
                            .padding(.horizontal)

                            if !store.isPremium && habits.count >= HabitsViewModel.freeHabitLimit {
                                PremiumLimitBanner(limit: HabitsViewModel.freeHabitLimit, item: "habits") {
                                    showingPremium = true
                                }
                                .padding(.horizontal)
                            }

                            LazyVStack(spacing: 12) {
                                ForEach(habits) { habit in
                                    HabitRowView(habit: habit) {
                                        withAnimation(.bouncy) {
                                            viewModel.toggleCompletion(
                                                for: habit,
                                                context: modelContext
                                            )
                                        }
                                    }
                                    .contextMenu {
                                        Button("Archive", systemImage: "archivebox") {
                                            viewModel.archiveHabit(habit, context: modelContext)
                                        }
                                        Button("Delete", systemImage: "trash", role: .destructive) {
                                            viewModel.deleteHabit(habit, context: modelContext)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if canAddHabit {
                            viewModel.showingAddHabit = true
                        } else {
                            showingPremiumLimit = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddHabit) {
                AddHabitView()
            }
            .sheet(isPresented: $showingPremium) {
                PremiumView()
            }
            .alert("Streak Milestone! 🎉", isPresented: Binding(
                get: { viewModel.streakMilestone != nil },
                set: { if !$0 { viewModel.streakMilestone = nil } }
            )) {
                Button("Keep it up!", role: .cancel) {
                    viewModel.streakMilestone = nil
                }
            } message: {
                if let milestone = viewModel.streakMilestone {
                    Text("Amazing! You've hit a \(milestone)-day streak. Consistency is the key to lasting change.")
                }
            }
            .alert("Habit Limit Reached", isPresented: $showingPremiumLimit) {
                Button("Upgrade to Premium") {
                    showingPremiumLimit = false
                    showingPremium = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Free accounts can track up to \(HabitsViewModel.freeHabitLimit) habits. Upgrade to Premium for unlimited habits.")
            }
        }
    }
}

struct PremiumLimitBanner: View {
    let limit: Int
    let item: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundStyle(.yellow)

            VStack(alignment: .leading, spacing: 2) {
                Text("Free limit: \(limit) \(item)")
                    .font(.caption)
                    .fontWeight(.medium)
                Text("Upgrade for unlimited")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Upgrade", action: action)
                .font(.caption)
                .fontWeight(.semibold)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.accentColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.yellow.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.yellow.opacity(0.2), lineWidth: 1)
        }
    }
}

struct DailyProgressView: View {
    let completed: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Progress")
                        .font(.headline)
                    Text("\(completed) of \(total) completed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color(.tertiarySystemFill), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            progress >= 1.0 ? Color.green : Color.accentColor,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring, value: progress)
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                }
                .frame(width: 50, height: 50)
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

#Preview {
    HabitListView()
        .modelContainer(for: Habit.self, inMemory: true)
}
