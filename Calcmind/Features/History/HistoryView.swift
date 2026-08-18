import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalculationRecord.date, order: .reverse) private var records: [CalculationRecord]
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    HistoryEmptyStateView()
                } else if dayGroups.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(dayGroups, id: \.label) { group in
                            Section(group.label) {
                                ForEach(group.records) { record in
                                    NavigationLink {
                                        HistoryDetailView(record: record)
                                    } label: {
                                        HistoryRow(record: record)
                                    }
                                }
                                .onDelete { offsets in
                                    delete(offsets: offsets, from: group.records)
                                }
                            }
                        }
                    }
                }
            }
            .background(AppColor.background(colorScheme).ignoresSafeArea())
            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search calculations")
        }
    }

    // MARK: - Grouping

    private struct DayGroup {
        let sortDate: Date
        let label: String
        let records: [CalculationRecord]
    }

    private var filteredRecords: [CalculationRecord] {
        guard !searchText.isEmpty else { return records }
        return records.filter {
            $0.expression.localizedCaseInsensitiveContains(searchText)
                || $0.result.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var dayGroups: [DayGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredRecords) { calendar.startOfDay(for: $0.date) }
        return grouped.keys.sorted(by: >).map { day in
            let dayRecords = (grouped[day] ?? []).sorted { $0.date > $1.date }
            return DayGroup(sortDate: day, label: Self.dayLabel(for: day), records: dayRecords)
        }
    }

    private static func dayLabel(for day: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(day) { return "Today" }
        if calendar.isDateInYesterday(day) { return "Yesterday" }
        return day.formatted(date: .abbreviated, time: .omitted)
    }

    // MARK: - Delete

    private func delete(offsets: IndexSet, from groupRecords: [CalculationRecord]) {
        for index in offsets {
            modelContext.delete(groupRecords[index])
        }
    }
}

#Preview("Light") {
    HistoryView()
        .environment(ThemeManager())
        .modelContainer(for: CalculationRecord.self, inMemory: true)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    HistoryView()
        .environment(ThemeManager())
        .modelContainer(for: CalculationRecord.self, inMemory: true)
        .preferredColorScheme(.dark)
}
