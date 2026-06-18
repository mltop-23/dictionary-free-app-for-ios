import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var decks: [Deck]
    @Query(sort: [SortDescriptor(\StudyLog.date, order: .reverse)]) private var logs: [StudyLog]

    var body: some View {
        NavigationStack {
            List {
                Section("Всего") {
                    HStack(spacing: 10) {
                        StatBadge(value: totalCards, label: "Карточек", color: .blue)
                        StatBadge(value: totalMastered, label: "Готово", color: .green)
                        StatBadge(value: streak, label: "Streak", color: .orange)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Активность 14 дней") {
                    if logs.isEmpty {
                        Text("Пока нет данных").foregroundStyle(.secondary)
                    } else {
                        Chart {
                            ForEach(last14Days, id: \.0) { day, count in
                                BarMark(
                                    x: .value("День", day, unit: .day),
                                    y: .value("Карточек", count)
                                )
                                .foregroundStyle(.blue)
                            }
                        }
                        .frame(height: 180)
                    }
                }

                Section("По колодам") {
                    if decks.isEmpty {
                        Text("Нет колод").foregroundStyle(.secondary)
                    } else {
                        ForEach(decks) { deck in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(deck.name).font(.headline)
                                ProgressView(value: progress(for: deck))
                                HStack {
                                    Text("\(deck.masteredCount) / \(deck.cards.count)")
                                        .font(.caption.monospacedDigit())
                                    Spacer()
                                    Text("\(Int(progress(for: deck) * 100))%")
                                        .font(.caption.monospacedDigit())
                                }
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Статистика")
        }
    }

    private var totalCards: Int { decks.reduce(0) { $0 + $1.cards.count } }
    private var totalMastered: Int { decks.reduce(0) { $0 + $1.masteredCount } }

    private var streak: Int {
        let cal = Calendar.current
        var count = 0
        var day = cal.startOfDay(for: Date())
        let logsByDay = Dictionary(uniqueKeysWithValues: logs.map { (cal.startOfDay(for: $0.date), $0) })
        while let log = logsByDay[day], log.cardsReviewed > 0 {
            count += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return count
    }

    private var last14Days: [(Date, Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let logsByDay = Dictionary(uniqueKeysWithValues: logs.map { (cal.startOfDay(for: $0.date), $0.cardsReviewed) })
        return (0..<14).reversed().map { offset in
            let d = cal.date(byAdding: .day, value: -offset, to: today)!
            return (d, logsByDay[d] ?? 0)
        }
    }

    private func progress(for deck: Deck) -> Double {
        guard deck.cards.count > 0 else { return 0 }
        return Double(deck.masteredCount) / Double(deck.cards.count)
    }
}
