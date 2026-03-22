import SwiftUI
import SwiftData

struct AlarmListView: View {
    @Query(sort: \ChimeAlarm.time) private var alarms: [ChimeAlarm]
    @Query private var quotes: [Quote]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AlarmViewModel()
    @State private var selectedAlarm: ChimeAlarm?

    var body: some View {
        NavigationStack {
            Group {
                if alarms.isEmpty {
                    ContentUnavailableView {
                        Label("No Chimes", systemImage: "bell.slash")
                    } description: {
                        Text("Add a chime to wake up with a meaningful thought each morning.")
                    } actions: {
                        Button("Add Chime") {
                            addAlarm()
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    List {
                        ForEach(alarms) { alarm in
                            AlarmRowView(alarm: alarm) {
                                viewModel.toggleAlarm(alarm, quotes: quotes, context: modelContext)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedAlarm = alarm
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteAlarm(alarms[index], context: modelContext)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chimes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addAlarm()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedAlarm) { alarm in
                AlarmDetailView(alarm: alarm, quotes: quotes)
            }
        }
    }

    private func addAlarm() {
        let alarm = viewModel.createAlarm(context: modelContext)
        selectedAlarm = alarm
    }
}

struct AlarmRowView: View {
    @Bindable var alarm: ChimeAlarm
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.time, style: .time)
                    .font(.system(.title, design: .rounded, weight: .light))

                Text(alarm.label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(alarm.repeatDaysText)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .tint(.green)
        }
        .padding(.vertical, 4)
        .opacity(alarm.isEnabled ? 1.0 : 0.5)
    }
}

#Preview {
    AlarmListView()
        .modelContainer(for: ChimeAlarm.self, inMemory: true)
}
