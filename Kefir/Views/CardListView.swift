import SwiftUI
import SwiftData

// Показывает карточки по фильтру. Используется из Dashboard и из DeckDetailView.
struct CardListView: View {
    enum Filter {
        case new            // ещё не начинал (stage == .new)
        case due            // пора повторить прямо сейчас
        case upcoming       // в процессе, но ещё не время
        case reviewedToday  // трогал сегодня
        case mastered       // stage == .mastered
        case learning       // stage == .learning или .review
        case notMastered    // всё что НЕ mastered (new + learning + review)
        case all            // все

        var title: String {
            switch self {
            case .new: return "Новые — не изучал"
            case .due: return "К повтору сейчас"
            case .upcoming: return "Будут позже"
            case .reviewedToday: return "Повторено сегодня"
            case .mastered: return "Готово (освоено)"
            case .learning: return "В процессе изучения"
            case .notMastered: return "Ещё учить"
            case .all: return "Все карточки"
            }
        }
        var hint: String {
            switch self {
            case .new: return "Карточки, которые ты ещё ни разу не учил. После первого «Норм»/«Легко» они перейдут в «Учу»."
            case .due: return "Карточки, у которых наступил срок повтора прямо сейчас. Их Learn и покажет в первую очередь."
            case .upcoming: return "Карточки в процессе изучения, но алгоритм пока их не даёт — ещё не забылись. Смотри, когда подойдёт очередь."
            case .reviewedToday: return "Карточки, которые ты оценил сегодня (через Learn). Обновляется каждую сессию."
            case .mastered: return "Карточки с интервалом ≥ 60 дней. Выучены."
            case .learning: return "Активно изучаемые карточки (всё, что не «Новое» и не «Готово»)."
            case .notMastered: return "Всё, что ты ещё не выучил — новые + в процессе. Именно этим словам стоит уделить время."
            case .all: return "Все карточки колоды."
            }
        }
    }

    // Либо передать конкретные карточки (для dashboard), либо deck (для колоды)
    let filter: Filter
    let cards: [Card]
    let title: String

    @State private var showResetConfirm = false
    @State private var groupByDeck = false
    @AppStorage("study_force_reversed") private var forceReversed: Bool = false
    @Environment(\.modelContext) private var ctx

    private var filtered: [Card] {
        let now = Date()
        switch filter {
        case .new:
            return cards.filter { $0.stage == .new }
        case .due:
            return cards.filter { $0.dueAt <= now && $0.stage != .mastered && $0.stage != .new }
        case .upcoming:
            return cards.filter { $0.dueAt > now && $0.stage != .mastered && $0.stage != .new }
                .sorted { $0.dueAt < $1.dueAt }
        case .notMastered:
            return cards.filter { $0.stage != .mastered }
        case .reviewedToday:
            let today = Calendar.current.startOfDay(for: Date())
            return cards.filter {
                guard let r = $0.lastReviewedAt else { return false }
                return Calendar.current.startOfDay(for: r) == today
            }
        case .mastered:
            return cards.filter { $0.stage == .mastered }
        case .learning:
            return cards.filter { $0.stage == .learning || $0.stage == .review }
        case .all:
            return cards
        }
    }

    private var upcomingCards: [Card] {
        let now = Date()
        return cards.filter { $0.dueAt > now && $0.stage != .mastered && $0.stage != .new }
            .sorted { $0.dueAt < $1.dueAt }
    }

    var body: some View {
        List {
            Section {
                Text(filter.hint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Быстрые режимы учёбы по отфильтрованным карточкам
            if filtered.count >= 1 {
                Section {
                    Toggle(isOn: $forceReversed) {
                        Label(forceReversed ? "RU → EN" : "EN → RU",
                              systemImage: "arrow.left.arrow.right")
                            .font(.callout)
                    }
                    NavigationLink {
                        FlashcardsCoreView(cards: filtered.shuffled(), forceReversed: forceReversed)
                    } label: {
                        Label("Карточки (\(filtered.count))", systemImage: "rectangle.portrait.on.rectangle.portrait")
                    }
                    if filtered.count >= 4 {
                        NavigationLink {
                            TestCoreView(cards: filtered, forceReversed: forceReversed)
                        } label: {
                            Label("Test", systemImage: "checkmark.square")
                        }
                        NavigationLink {
                            MatchCoreView(cards: filtered, forceReversed: forceReversed)
                        } label: {
                            Label("Match", systemImage: "square.grid.2x2")
                        }
                    }
                } header: {
                    Text("Учить только эти")
                }
            }

            if filtered.isEmpty {
                Section {
                    ContentUnavailableView("Пусто", systemImage: "tray",
                        description: Text(emptyDescription))
                }
                // Если "К повтору" пусто — покажем когда подойдёт следующая
                if filter == .due && !upcomingCards.isEmpty {
                    Section("Следующие повторы") {
                        ForEach(upcomingCards.prefix(10)) { card in
                            CardStateRow(card: card)
                        }
                        if upcomingCards.count > 10 {
                            Text("+ ещё \(upcomingCards.count - 10)…")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                Section {
                    Toggle("Группировать по колодам", isOn: $groupByDeck)
                        .font(.callout)
                }
                if groupByDeck {
                    let grouped = Dictionary(grouping: filtered.sorted(by: sortOrder)) {
                        $0.deck?.name ?? "Без колоды"
                    }
                    .sorted { $0.key < $1.key }
                    ForEach(grouped, id: \.key) { deckName, cards in
                        Section {
                            // Кнопки учёбы — только по карточкам этой колоды
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    NavigationLink {
                                        FlashcardsCoreView(cards: cards.shuffled(), forceReversed: forceReversed)
                                    } label: {
                                        Label("Карточки", systemImage: "rectangle.portrait.on.rectangle.portrait")
                                            .font(.caption.bold())
                                            .padding(.vertical, 6).padding(.horizontal, 10)
                                            .background(.blue.opacity(0.2))
                                            .foregroundStyle(.blue)
                                            .clipShape(Capsule())
                                    }
                                    if cards.count >= 4 {
                                        NavigationLink {
                                            TestCoreView(cards: cards, forceReversed: forceReversed)
                                        } label: {
                                            Label("Test", systemImage: "checkmark.square")
                                                .font(.caption.bold())
                                                .padding(.vertical, 6).padding(.horizontal, 10)
                                                .background(.green.opacity(0.2))
                                                .foregroundStyle(.green)
                                                .clipShape(Capsule())
                                        }
                                        NavigationLink {
                                            MatchCoreView(cards: cards, forceReversed: forceReversed)
                                        } label: {
                                            Label("Match", systemImage: "square.grid.2x2")
                                                .font(.caption.bold())
                                                .padding(.vertical, 6).padding(.horizontal, 10)
                                                .background(.orange.opacity(0.2))
                                                .foregroundStyle(.orange)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            ForEach(cards) { card in
                                CardStateRow(card: card)
                            }
                        } header: {
                            HStack {
                                Text(deckName).font(.subheadline.bold())
                                Spacer()
                                Text("\(cards.count)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8).padding(.vertical, 2)
                                    .background(Color(.tertiarySystemBackground))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                } else {
                    Section("Найдено: \(filtered.count)") {
                        ForEach(filtered.sorted(by: sortOrder)) { card in
                            CardStateRow(card: card)
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
        .toolbar {
            if canReset && !filtered.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
        }
        .confirmationDialog(resetTitle, isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("Сбросить прогресс (\(filtered.count))", role: .destructive) { resetAll() }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Карточки станут «новыми», статистика успехов обнулится. Избранное и сами карточки не удаляются.")
        }
    }

    private var canReset: Bool {
        switch filter {
        case .mastered, .learning, .all, .reviewedToday: return true
        default: return false
        }
    }

    private var resetTitle: String {
        "Сбросить прогресс \(filtered.count) карточек?"
    }

    private func sortOrder(_ a: Card, _ b: Card) -> Bool {
        switch filter {
        case .due, .upcoming:
            return a.dueAt < b.dueAt
        case .reviewedToday:
            return (a.lastReviewedAt ?? .distantPast) > (b.lastReviewedAt ?? .distantPast)
        default:
            return a.createdAt > b.createdAt
        }
    }

    private var emptyDescription: String {
        switch filter {
        case .due: return "Прямо сейчас ничего повторять не нужно — алгоритм расписал интервалы, жди своего часа."
        case .new: return "Все карточки уже в изучении или выучены. Добавь новые через импорт или AI."
        case .mastered: return "Пока ничего не выучено до «Готово» (интервал ≥ 60 дней). Продолжай повторять!"
        default: return "Под этот фильтр карточек нет."
        }
    }

    private func resetAll() {
        for card in filtered {
            card.stage = .new
            card.easeFactor = 2.5
            card.intervalDays = 0
            card.repetitions = 0
            card.dueAt = Date()
            card.lastReviewedAt = nil
            card.totalReviews = 0
            card.correctReviews = 0
        }
    }
}

struct CardStateRow: View {
    @Bindable var card: Card

    private var ipa: String? {
        let mode = card.deck?.mode ?? .classic
        guard mode == .classic,
              card.deck?.frontLanguage.hasPrefix("en") == true
        else { return nil }
        return TranscriptionService.shared.ipa(for: card.front)
    }

    var body: some View {
        HStack {
            stageBadge
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(card.questionText(for: card.deck?.mode ?? .classic))
                        .font(.body).lineLimit(1)
                    if let ipa {
                        Text(ipa)
                            .font(.caption.monospaced())
                            .foregroundStyle(.blue)
                    }
                }
                Text(card.answerText(for: card.deck?.mode ?? .classic))
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                HStack(spacing: 8) {
                    if let r = card.lastReviewedAt {
                        Text("✓ " + r.formatted(.relative(presentation: .named)))
                    }
                    if card.totalReviews > 0 {
                        Text("\(card.correctReviews)/\(card.totalReviews)")
                    }
                    if card.stage != .new {
                        Text("⏰ " + SRSEngine.formatInterval(days: card.intervalDays))
                    }
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
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
        .contextMenu {
            if card.stage != .mastered {
                Button {
                    markMastered()
                } label: {
                    Label("Я это знаю — в Готово", systemImage: "checkmark.seal.fill")
                }
            }
            if card.stage != .new {
                Button {
                    resetToNew()
                } label: {
                    Label("Сбросить в Новые", systemImage: "arrow.counterclockwise")
                }
            }
            Button {
                card.isFavorite.toggle()
            } label: {
                Label(card.isFavorite ? "Убрать из избранного" : "В избранное",
                      systemImage: card.isFavorite ? "star.slash" : "star")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if card.stage != .mastered {
                Button {
                    markMastered()
                } label: {
                    Label("Готово", systemImage: "checkmark.seal.fill")
                }
                .tint(.green)
            }
        }
    }

    private func markMastered() {
        card.stage = .mastered
        card.intervalDays = 90
        card.repetitions = max(card.repetitions, 5)
        card.dueAt = Date().addingTimeInterval(90 * 86400)
        card.lastReviewedAt = Date()
        card.correctReviews += 1
        card.totalReviews += 1
    }

    private func resetToNew() {
        card.stage = .new
        card.easeFactor = 2.5
        card.intervalDays = 0
        card.repetitions = 0
        card.dueAt = Date()
        card.lastReviewedAt = nil
    }

    private var stageBadge: some View {
        let (color, letter): (Color, String) = {
            switch card.stage {
            case .new: return (.blue, "N")
            case .learning: return (.orange, "L")
            case .review: return (.purple, "R")
            case .mastered: return (.green, "✓")
            }
        }()
        return Text(letter)
            .font(.caption2.bold())
            .frame(width: 22, height: 22)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Circle())
    }
}
