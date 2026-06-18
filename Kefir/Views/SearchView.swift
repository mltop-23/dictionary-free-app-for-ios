import SwiftUI
import SwiftData

struct SearchView: View {
    @Query private var allCards: [Card]
    @State private var query: String = ""

    private var results: [Card] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return allCards.filter { card in
            card.front.lowercased().contains(q)
            || card.back.lowercased().contains(q)
            || card.example.lowercased().contains(q)
            || card.kanji.lowercased().contains(q)
            || card.kana.lowercased().contains(q)
            || card.romaji.lowercased().contains(q)
            || card.meaning.lowercased().contains(q)
        }
    }

    private var grouped: [(deckName: String, cards: [Card])] {
        let dict = Dictionary(grouping: results) { $0.deck?.name ?? "Без колоды" }
        return dict
            .map { (deckName: $0.key, cards: $0.value) }
            .sorted { $0.deckName < $1.deckName }
    }

    var body: some View {
        Group {
            if query.isEmpty {
                ContentUnavailableView {
                    Label("Поиск по карточкам", systemImage: "magnifyingglass")
                } description: {
                    Text("Ищет по всем колодам (всего \(allCards.count) карточек): front, back, kanji, kana, romaji, meaning, примеры.")
                }
            } else if results.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                List {
                    Text("Найдено: \(results.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(grouped, id: \.deckName) { group in
                        Section(group.deckName) {
                            ForEach(group.cards) { card in
                                SearchResultRow(card: card, query: query)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Поиск")
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Слово, перевод, иероглиф…")
    }
}

struct SearchResultRow: View {
    @Bindable var card: Card
    let query: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.questionText(for: card.deck?.mode ?? .classic))
                    .font(.body)
                Text(card.answerText(for: card.deck?.mode ?? .classic))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !card.example.isEmpty {
                    Text(card.example)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Button {
                card.isFavorite.toggle()
            } label: {
                Image(systemName: card.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(card.isFavorite ? .yellow : .secondary)
            }
            .buttonStyle(.plain)
        }
    }
}
