import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(filter: #Predicate<Card> { $0.isFavorite == true }) private var favorites: [Card]
    @AppStorage("favorites_sort") private var sortRaw: String = SortOrder.alpha.rawValue
    @State private var searchText: String = ""

    enum SortOrder: String, CaseIterable {
        case alpha, recent
        var title: String {
            switch self { case .alpha: return "А → Я"; case .recent: return "По времени" }
        }
    }

    private var sortOrder: SortOrder {
        SortOrder(rawValue: sortRaw) ?? .alpha
    }

    private var sorted: [Card] {
        switch sortOrder {
        case .alpha:
            return favorites.sorted { a, b in
                let aKey = a.questionText(for: a.deck?.mode ?? .classic).lowercased()
                let bKey = b.questionText(for: b.deck?.mode ?? .classic).lowercased()
                return aKey < bKey
            }
        case .recent:
            return favorites.sorted { $0.updatedAt > $1.updatedAt }
        }
    }

    private var filtered: [Card] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return sorted }
        return sorted.filter { card in
            card.front.lowercased().contains(q)
            || card.back.lowercased().contains(q)
            || card.example.lowercased().contains(q)
            || card.kanji.lowercased().contains(q)
            || card.kana.lowercased().contains(q)
            || card.romaji.lowercased().contains(q)
            || card.meaning.lowercased().contains(q)
        }
    }

    var body: some View {
        Group {
            if favorites.isEmpty {
                ContentUnavailableView {
                    Label("Нет избранного", systemImage: "star")
                } description: {
                    Text("Помечай сложные слова звёздочкой прямо во время учёбы — соберутся здесь плоским списком.")
                }
            } else {
                List {
                    Section {
                        NavigationLink {
                            FavoritesStudyView(cards: filtered, mode: .flashcards)
                        } label: {
                            Label("Карточки (\(filtered.count))", systemImage: "rectangle.portrait.on.rectangle.portrait")
                        }
                        NavigationLink {
                            FavoritesStudyView(cards: filtered, mode: .test)
                        } label: {
                            Label("Test", systemImage: "checkmark.square")
                        }
                        .disabled(filtered.count < 4)
                        NavigationLink {
                            FavoritesStudyView(cards: filtered, mode: .match)
                        } label: {
                            Label("Match", systemImage: "square.grid.2x2")
                        }
                        .disabled(filtered.count < 4)
                    } header: {
                        HStack {
                            Text("Учить")
                            Spacer()
                            Picker("Сортировка", selection: $sortRaw) {
                                ForEach(SortOrder.allCases, id: \.rawValue) { s in
                                    Text(s.title).tag(s.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                            .font(.caption)
                        }
                    }

                    Section("Слова (\(filtered.count))") {
                        ForEach(filtered) { card in
                            FavoriteRow(card: card)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Слово, перевод, синоним…")
            }
        }
        .navigationTitle("⭐ Избранное")
    }
}

struct FavoriteRow: View {
    @Bindable var card: Card

    private var mode: DeckMode { card.deck?.mode ?? .classic }

    private var synonyms: String? {
        // В example обычно лежит «Синонимы: a, b, c»
        let ex = card.example.trimmingCharacters(in: .whitespaces)
        if ex.hasPrefix("Синонимы:") {
            return String(ex.dropFirst("Синонимы:".count)).trimmingCharacters(in: .whitespaces)
        }
        return ex.isEmpty ? nil : ex
    }

    private var ipa: String? {
        guard mode == .classic,
              card.deck?.frontLanguage.hasPrefix("en") == true
        else { return nil }
        return TranscriptionService.shared.ipa(for: card.front)
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(card.questionText(for: mode))
                        .font(.body.bold())
                    if let ipa {
                        Text(ipa)
                            .font(.caption.monospaced())
                            .foregroundStyle(.blue)
                    }
                }
                Text(card.answerText(for: mode))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                if let syns = synonyms {
                    Text(syns)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                }
            }
            Spacer()
            Button {
                card.isFavorite.toggle()
            } label: {
                Image(systemName: card.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
            }
            .buttonStyle(.plain)
        }
        .contextMenu {
            if card.stage != .mastered {
                Button {
                    card.stage = .mastered
                    card.intervalDays = 90
                    card.repetitions = max(card.repetitions, 5)
                    card.dueAt = Date().addingTimeInterval(90 * 86400)
                    card.lastReviewedAt = Date()
                } label: {
                    Label("В Готово", systemImage: "checkmark.seal.fill")
                }
            }
            Button(role: .destructive) {
                card.isFavorite = false
            } label: {
                Label("Убрать из избранного", systemImage: "star.slash")
            }
        }
    }
}

// MARK: - Study modes для избранного (reuse существующих вьюх через shim)

struct FavoritesStudyView: View {
    enum Mode { case flashcards, test, match }
    let cards: [Card]
    let mode: Mode

    var body: some View {
        switch mode {
        case .flashcards:
            FlashcardsCoreView(cards: cards)
        case .test:
            TestCoreView(cards: cards)
        case .match:
            MatchCoreView(cards: cards)
        }
    }
}
