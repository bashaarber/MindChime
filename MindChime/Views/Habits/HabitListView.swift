import SwiftUI
import SwiftData

struct HabitListView: View {
    @Query(
        filter: #Predicate<Habit> { !$0.isArchived },
        sort: \Habit.createdAt
    ) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HabitsViewModel()

    private var completedCount: Int {
        habits.filter { $0.isCompletedToday() }.count
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
                            // Progress header
                            DailyProgressView(
                                completed: completedCount,
                                total: habits.count
                            )
                            .padding(.horizontal)

                            // Habit list
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
                        viewModel.showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddHabit) {
                AddHabitView()
            }
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
