import SwiftUI
import SwiftData

struct DeckDetailView: View {
    @Bindable var deck: Deck
    @Environment(\.modelContext) private var ctx

    @State private var showEditDeck = false
    @State private var showAddCard = false
    @State private var editingCard: Card?
    @State private var showImport = false
    @State private var showAIGenerate = false
    @State private var showAIAudit = false
    @State private var editMode: EditMode = .inactive
    @State private var selectedCards = Set<UUID>()
    @State private var showResetProgress = false

    var body: some View {
        List {
            // Плитки-фильтры вынесены в отдельную секцию со Scrollview — чтобы навигация не цеплялась.
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        NavigationLink {
                            CardListView(filter: .notMastered, cards: deck.cards, title: "Ещё учить — \(deck.name)")
                        } label: {
                            StatBadge(value: deck.cards.filter { $0.stage != .mastered }.count, label: "Ещё учить", color: .indigo)
                        }
                        NavigationLink {
                            CardListView(filter: .new, cards: deck.cards, title: "Новые — \(deck.name)")
                        } label: {
                            StatBadge(value: deck.newCount, label: "Новые", color: .blue)
                        }
                        NavigationLink {
                            CardListView(filter: .due, cards: deck.cards, title: "К повтору — \(deck.name)")
                        } label: {
                            StatBadge(value: deck.dueCards.count, label: "К повтору", color: .orange)
                        }
                        NavigationLink {
                            CardListView(filter: .learning, cards: deck.cards, title: "Учу — \(deck.name)")
                        } label: {
                            StatBadge(value: deck.cards.filter { $0.stage == .learning || $0.stage == .review }.count, label: "Учу", color: .purple)
                        }
                        NavigationLink {
                            CardListView(filter: .mastered, cards: deck.cards, title: "Готово — \(deck.name)")
                        } label: {
                            StatBadge(value: deck.masteredCount, label: "Готово", color: .green)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            } footer: {
                Text("Нажми на плитку — увидишь какие слова внутри")
                    .font(.caption2)
            }

            // Направление учёбы
            Section {
                HStack {
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Направление")
                            .font(.subheadline)
                        Text(directionLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { deck.isReversed },
                        set: { deck.isReversed = $0; deck.updatedAt = Date() }
                    ))
                    .labelsHidden()
                }
            }

            // Режимы учёбы
            Section("Учить") {
                NavigationLink {
                    FlashcardsView(deck: deck)
                } label: {
                    Label("Карточки", systemImage: "rectangle.portrait.on.rectangle.portrait")
                }
                NavigationLink {
                    LearnView(deck: deck)
                } label: {
                    HStack {
                        Label("Learn (SRS)", systemImage: "brain.head.profile")
                        Spacer()
                        if deck.dueCards.count > 0 {
                            Text("\(deck.dueCards.count)")
                                .font(.caption.bold())
                                .padding(.horizontal, 8).padding(.vertical, 2)
                                .background(.orange)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                NavigationLink {
                    MatchView(deck: deck)
                } label: {
                    Label("Match", systemImage: "square.grid.2x2")
                }
                .disabled(deck.cards.count < 4)
                NavigationLink {
                    TestView(deck: deck)
                } label: {
                    Label("Test", systemImage: "checkmark.square")
                }
                .disabled(deck.cards.count < 4)
                NavigationLink {
                    WriteView(deck: deck)
                } label: {
                    Label("Write (печатать)", systemImage: "keyboard")
                }
                .disabled(deck.cards.isEmpty)
            }

            // Список карточек
            Section("Карточки (\(deck.cards.count))") {
                if editMode == .inactive {
                    Button { showAddCard = true } label: {
                        Label("Добавить карточку", systemImage: "plus.circle.fill")
                    }
                    Button { showImport = true } label: {
                        Label("Импорт из текста", systemImage: "square.and.arrow.down")
                    }
                    Button { showAIGenerate = true } label: {
                        Label("✨ AI: сгенерировать из текста", systemImage: "sparkles")
                    }
                }
                ForEach(deck.cards.sorted(by: { $0.createdAt > $1.createdAt })) { card in
                    if editMode == .active {
                        HStack {
                            Image(systemName: selectedCards.contains(card.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedCards.contains(card.id) ? .blue : .secondary)
                            CardPreviewRow(card: card, mode: deck.mode)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedCards.contains(card.id) {
                                selectedCards.remove(card.id)
                            } else {
                                selectedCards.insert(card.id)
                            }
                        }
                    } else {
                        Button { editingCard = card } label: {
                            CardPreviewRow(card: card, mode: deck.mode)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDelete(perform: deleteCards)
            }
        }
        .environment(\.editMode, $editMode)
        .navigationTitle(deck.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if editMode == .active {
                    Button("Готово") {
                        editMode = .inactive
                        selectedCards.removeAll()
                    }
                } else {
                    Menu {
                        Button { showEditDeck = true } label: { Label("Редактировать колоду", systemImage: "pencil") }
                        Button { showAddCard = true } label: { Label("Новая карточка", systemImage: "plus") }
                        Button { showImport = true } label: { Label("Импорт", systemImage: "square.and.arrow.down") }
                        Button { showAIAudit = true } label: { Label("🔍 AI-проверка переводов", systemImage: "magnifyingglass") }
                        Divider()
                        Button { editMode = .active } label: { Label("Выбрать несколько", systemImage: "checkmark.circle") }
                        Divider()
                        Button(role: .destructive) { showResetProgress = true } label: {
                            Label("Сбросить прогресс колоды", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            if editMode == .active {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("Все") {
                            selectedCards = Set(deck.cards.map { $0.id })
                        }
                        Spacer()
                        Text("Выбрано: \(selectedCards.count)")
                        Spacer()
                        Button(role: .destructive) {
                            deleteSelected()
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                        .disabled(selectedCards.isEmpty)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditDeck) {
            DeckEditorView(deck: deck)
        }
        .sheet(isPresented: $showAddCard) {
            CardEditView(deck: deck, card: nil)
        }
        .sheet(item: $editingCard) { card in
            CardEditView(deck: deck, card: card)
        }
        .sheet(isPresented: $showImport) {
            ImportView(deck: deck)
        }
        .sheet(isPresented: $showAIGenerate) {
            GenerateCardsView(deck: deck)
        }
        .sheet(isPresented: $showAIAudit) {
            TranslationAuditView(deck: deck)
        }
        .confirmationDialog("Сбросить прогресс?", isPresented: $showResetProgress, titleVisibility: .visible) {
            Button("Сбросить прогресс", role: .destructive) { resetDeckProgress() }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Все \(deck.cards.count) карточек станут «новыми», статистика ответов обнулится. Сами карточки и избранное останутся.")
        }
    }

    private func deleteCards(at offsets: IndexSet) {
        let sorted = deck.cards.sorted(by: { $0.createdAt > $1.createdAt })
        for idx in offsets {
            ctx.delete(sorted[idx])
        }
    }

    private func deleteSelected() {
        for card in deck.cards where selectedCards.contains(card.id) {
            ctx.delete(card)
        }
        selectedCards.removeAll()
        editMode = .inactive
    }

    private func resetDeckProgress() {
        for card in deck.cards {
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

    private var directionLabel: String {
        let front = shortLang(deck.frontLanguage)
        let back = shortLang(deck.backLanguage)
        let arrow = " → "
        switch deck.mode {
        case .classic:
            return deck.isReversed ? back + arrow + front : front + arrow + back
        case .japanese:
            return deck.isReversed ? "RU → JA" : "JA → RU"
        }
    }

    private func shortLang(_ code: String) -> String {
        let map: [String: String] = [
            "en-US": "EN", "ru-RU": "RU", "ja-JP": "JA",
            "de-DE": "DE", "fr-FR": "FR", "es-ES": "ES",
            "it-IT": "IT", "zh-CN": "ZH", "ko-KR": "KO"
        ]
        return map[code] ?? code.uppercased().prefix(2).description
    }
}

struct StatBadge: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CardPreviewRow: View {
    @Bindable var card: Card
    let mode: DeckMode

    var body: some View {
        HStack(spacing: 10) {
            stageBadge
            VStack(alignment: .leading, spacing: 2) {
                Text(card.questionText(for: mode))
                    .font(.body)
                    .lineLimit(1)
                Text(card.answerText(for: mode))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if card.stage != .new {
                    HStack(spacing: 6) {
                        Text(stageLabel).foregroundStyle(stageColor)
                        if card.totalReviews > 0 {
                            Text("\(card.correctReviews)/\(card.totalReviews)")
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .font(.caption2)
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
        .contextMenu {
            if card.stage != .mastered {
                Button {
                    card.stage = .mastered
                    card.intervalDays = 90
                    card.repetitions = max(card.repetitions, 5)
                    card.dueAt = Date().addingTimeInterval(90 * 86400)
                    card.lastReviewedAt = Date()
                } label: {
                    Label("Я это знаю — в Готово", systemImage: "checkmark.seal.fill")
                }
            }
            if card.stage != .new {
                Button {
                    card.stage = .new
                    card.intervalDays = 0
                    card.repetitions = 0
                    card.dueAt = Date()
                } label: {
                    Label("Сбросить в Новые", systemImage: "arrow.counterclockwise")
                }
            }
        }
    }

    private var stageBadge: some View {
        Text(stageLetter)
            .font(.caption2.bold())
            .frame(width: 24, height: 24)
            .background(stageColor.opacity(0.2))
            .foregroundStyle(stageColor)
            .clipShape(Circle())
    }

    private var stageLetter: String {
        switch card.stage {
        case .new: return "N"
        case .learning: return "L"
        case .review: return "R"
        case .mastered: return "✓"
        }
    }
    private var stageLabel: String {
        switch card.stage {
        case .new: return "Новая"
        case .learning: return "Учу"
        case .review: return "Повторение"
        case .mastered: return "✓ Готово"
        }
    }
    private var stageColor: Color {
        switch card.stage {
        case .new: return .blue
        case .learning: return .orange
        case .review: return .purple
        case .mastered: return .green
        }
    }
}
