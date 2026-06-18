import SwiftUI
import SwiftData

struct DeckListView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: [SortDescriptor(\Folder.sortOrder)]) private var allFolders: [Folder]
    @Query(sort: [SortDescriptor(\Deck.name)]) private var allDecks: [Deck]
    @Query(sort: [SortDescriptor(\StudyLog.date, order: .reverse)]) private var logs: [StudyLog]
    @State private var showNewDeck = false

    private var rootFolders: [Folder] {
        allFolders.filter { $0.parent == nil }.sorted { $0.sortOrder < $1.sortOrder }
    }

    // Карточки без папки — показать отдельно
    private var looseDecks: [Deck] {
        allDecks.filter { $0.folder == nil }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DashboardBar(decks: allDecks, logs: logs)
                    .padding(.horizontal)
                    .padding(.top, 8)

                List {
                        if rootFolders.isEmpty && looseDecks.isEmpty {
                        Section {
                            ContentUnavailableView {
                                Label("Нет колод", systemImage: "rectangle.stack.badge.plus")
                            } description: {
                                Text("Создай первую колоду, чтобы начать учить")
                            } actions: {
                                Button("Создать колоду") { showNewDeck = true }
                                    .buttonStyle(.borderedProminent)
                            }
                        }
                    } else {
                        ForEach(rootFolders) { folder in
                            FolderRow(folder: folder)
                        }
                        if !looseDecks.isEmpty {
                            Section("Без папки") {
                                ForEach(looseDecks) { deck in
                                    NavigationLink { DeckDetailView(deck: deck) } label: {
                                        DeckRow(deck: deck)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("MyDict")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showNewDeck = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showNewDeck) {
                DeckEditorView(deck: nil)
            }
        }
    }
}

// MARK: - Dashboard (сегодня)

// Dashboard живёт ВНЕ List, чтобы навигация на плитках работала независимо.
struct DashboardBar: View {
    let decks: [Deck]
    let logs: [StudyLog]

    private var allCards: [Card] { decks.flatMap { $0.cards } }

    private var dueCount: Int {
        let now = Date()
        return allCards.filter { $0.dueAt <= now && $0.stage != .mastered && $0.stage != .new }.count
    }
    private var newCount: Int { allCards.filter { $0.stage == .new }.count }
    private var masteredCount: Int { allCards.filter { $0.stage == .mastered }.count }
    private var notMasteredCount: Int { allCards.filter { $0.stage != .mastered }.count }
    private var reviewedTodayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return allCards.filter {
            guard let r = $0.lastReviewedAt else { return false }
            return Calendar.current.startOfDay(for: r) == today
        }.count
    }
    private var streak: Int {
        let cal = Calendar.current
        var count = 0
        var day = cal.startOfDay(for: Date())
        let byDay = Dictionary(uniqueKeysWithValues: logs.map { (cal.startOfDay(for: $0.date), $0) })
        while let log = byDay[day], log.cardsReviewed > 0 {
            count += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return count
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                NavigationLink {
                    CardListView(filter: .notMastered, cards: allCards, title: "Ещё учить")
                } label: {
                    DashStat(value: "\(notMasteredCount)", label: "Ещё учить", color: .purple, icon: "brain.head.profile")
                }
                NavigationLink {
                    CardListView(filter: .due, cards: allCards, title: "К повтору")
                } label: {
                    DashStat(value: "\(dueCount)", label: "К повтору", color: .orange, icon: "clock.badge")
                }
                NavigationLink {
                    CardListView(filter: .reviewedToday, cards: allCards, title: "Сегодня")
                } label: {
                    DashStat(value: "\(reviewedTodayCount)", label: "Сегодня", color: .blue, icon: "checkmark.circle")
                }
                NavigationLink {
                    CardListView(filter: .new, cards: allCards, title: "Новые")
                } label: {
                    DashStat(value: "\(newCount)", label: "Новые", color: .cyan, icon: "sparkle")
                }
                NavigationLink {
                    CardListView(filter: .mastered, cards: allCards, title: "Готово")
                } label: {
                    DashStat(value: "\(masteredCount)", label: "Готово", color: .green, icon: "checkmark.seal.fill")
                }
                DashStat(value: "\(streak)🔥", label: "Streak", color: .red, icon: "flame.fill")
                    .opacity(streak > 0 ? 1 : 0.5)
                    .frame(width: 90)
            }
        }
        .buttonStyle(.plain)
    }
}

struct DashStat: View {
    let value: String
    let label: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon).font(.callout).foregroundStyle(color)
            Text(value).font(.title3.bold()).foregroundStyle(color)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(width: 90)
        .padding(.vertical, 10)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Folder Row

struct FolderRow: View {
    let folder: Folder

    var body: some View {
        NavigationLink {
            FolderContentsView(folder: folder)
        } label: {
            HStack {
                Image(systemName: folder.icon)
                    .foregroundStyle(.blue)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(folder.name).font(.body.bold())
                    Text(folderSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }

    private var folderSubtitle: String {
        let decksN = folder.totalDecksCount
        let cardsN = folder.allCards.count
        return "\(decksN) колод • \(cardsN) карточек"
    }
}

// MARK: - Внутри папки

// Плашка для папки — кликабельный NavigationLink с цифрой и иконкой
struct FolderStatusTile: View {
    let value: Int
    let label: String
    let color: Color
    let icon: String
    let cards: [Card]
    let folderName: String

    var body: some View {
        NavigationLink {
            CardListView(filter: .all, cards: cards, title: "\(label) — \(folderName)")
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.title3).foregroundStyle(color)
                Text("\(value)").font(.title2.bold()).foregroundStyle(color)
                Text(label).font(.caption2).foregroundStyle(.secondary)
            }
            .frame(width: 95)
            .padding(.vertical, 12)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(value > 0 ? 1.0 : 0.4)
        }
        .buttonStyle(.plain)
        .disabled(value == 0)
    }
}

struct FolderContentsView: View {
    @Bindable var folder: Folder
    @Environment(\.modelContext) private var ctx
    @AppStorage("study_force_reversed") private var forceReversed: Bool = false

    private var allCardsInFolder: [Card] { folder.allCards }
    private var newCards: [Card] { allCardsInFolder.filter { $0.stage == .new } }
    private var dueCards: [Card] {
        let now = Date()
        return allCardsInFolder.filter { $0.dueAt <= now && $0.stage != .mastered && $0.stage != .new }
    }
    private var notMasteredCards: [Card] { allCardsInFolder.filter { $0.stage != .mastered } }
    private var masteredCards: [Card] { allCardsInFolder.filter { $0.stage == .mastered } }
    private var learningCards: [Card] { allCardsInFolder.filter { $0.stage == .learning || $0.stage == .review } }

    var body: some View {
        List {
            if !allCardsInFolder.isEmpty {
                Section {
                    Toggle(isOn: $forceReversed) {
                        Label(forceReversed ? "RU → EN" : "EN → RU",
                              systemImage: "arrow.left.arrow.right")
                            .font(.callout)
                    }
                } header: {
                    Text("Направление")
                } footer: {
                    Text("Применяется ко всем сессиям из этой папки")
                        .font(.caption2)
                }

                Section("Все слова в папке") {
                    NavigationLink {
                        FlashcardsCoreView(cards: allCardsInFolder.shuffled(), forceReversed: forceReversed)
                    } label: {
                        Label("Тренировать все (\(allCardsInFolder.count))", systemImage: "shuffle")
                    }
                    NavigationLink {
                        TestCoreView(cards: allCardsInFolder, forceReversed: forceReversed)
                    } label: {
                        Label("Тест по всем", systemImage: "checkmark.square")
                    }
                    .disabled(allCardsInFolder.count < 4)
                    NavigationLink {
                        CardListView(filter: .all, cards: allCardsInFolder, title: "Все слова — \(folder.name)")
                    } label: {
                        Label("Все карточки со статусом", systemImage: "list.bullet")
                    }
                }

                // Плашки по статусу — как на главной, кликабельные
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FolderStatusTile(
                                value: notMasteredCards.count,
                                label: "Ещё учить",
                                color: .purple,
                                icon: "brain.head.profile",
                                cards: notMasteredCards,
                                folderName: folder.name
                            )
                            FolderStatusTile(
                                value: dueCards.count,
                                label: "К повтору",
                                color: .orange,
                                icon: "clock.badge",
                                cards: dueCards,
                                folderName: folder.name
                            )
                            FolderStatusTile(
                                value: learningCards.count,
                                label: "В процессе",
                                color: .indigo,
                                icon: "book",
                                cards: learningCards,
                                folderName: folder.name
                            )
                            FolderStatusTile(
                                value: newCards.count,
                                label: "Новые",
                                color: .blue,
                                icon: "sparkle",
                                cards: newCards,
                                folderName: folder.name
                            )
                            FolderStatusTile(
                                value: masteredCards.count,
                                label: "Готово",
                                color: .green,
                                icon: "checkmark.seal.fill",
                                cards: masteredCards,
                                folderName: folder.name
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } footer: {
                    Text("Тапни плашку — увидишь карточки и кнопки для тренировки")
                        .font(.caption2)
                }
            }

            ForEach(folder.subfolders.sorted(by: { $0.sortOrder < $1.sortOrder })) { sub in
                FolderRow(folder: sub)
            }
            ForEach(folder.decks.sorted(by: { $0.name < $1.name })) { deck in
                NavigationLink { DeckDetailView(deck: deck) } label: {
                    DeckRow(deck: deck)
                }
            }
            .onDelete { offsets in
                let sorted = folder.decks.sorted(by: { $0.name < $1.name })
                for i in offsets { ctx.delete(sorted[i]) }
            }
        }
        .navigationTitle(folder.name)
    }
}

// MARK: - Deck Row

struct DeckRow: View {
    let deck: Deck

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(deck.name).font(.headline)
                Spacer()
                if deck.mode == .japanese {
                    Text("日本語").font(.caption).foregroundStyle(.secondary)
                }
            }
            if !deck.deckDescription.isEmpty {
                Text(deck.deckDescription).font(.caption).foregroundStyle(.secondary)
            }
            HStack(spacing: 10) {
                Label("\(deck.cards.count)", systemImage: "rectangle.on.rectangle")
                if deck.dueCards.count > 0 {
                    Label("\(deck.dueCards.count)", systemImage: "clock.badge")
                        .foregroundStyle(.orange)
                }
                if deck.masteredCount > 0 {
                    Label("\(deck.masteredCount)", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Deck editor

struct DeckEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx

    let deck: Deck?
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var mode: DeckMode = .classic
    @State private var frontLang: String = "en-US"
    @State private var backLang: String = "ru-RU"

    private let languages: [(String, String)] = [
        ("Русский", "ru-RU"), ("English", "en-US"), ("日本語", "ja-JP"),
        ("Deutsch", "de-DE"), ("Français", "fr-FR"), ("Español", "es-ES"),
        ("Italiano", "it-IT"), ("中文", "zh-CN"), ("한국어", "ko-KR")
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Основное") {
                    TextField("Название", text: $name)
                    TextField("Описание", text: $description, axis: .vertical)
                }
                Section("Режим") {
                    Picker("Режим", selection: $mode) {
                        ForEach(DeckMode.allCases, id: \.self) { m in Text(m.title).tag(m) }
                    }
                    .pickerStyle(.segmented)
                    if mode == .classic {
                        Picker("Лицевая сторона", selection: $frontLang) {
                            ForEach(languages, id: \.1) { Text($0.0).tag($0.1) }
                        }
                        Picker("Обратная сторона", selection: $backLang) {
                            ForEach(languages, id: \.1) { Text($0.0).tag($0.1) }
                        }
                    } else {
                        Text("Поля: кандзи / кана / ромадзи / значение")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(deck == nil ? "Новая колода" : "Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let deck {
                    name = deck.name
                    description = deck.deckDescription
                    mode = deck.mode
                    frontLang = deck.frontLanguage
                    backLang = deck.backLanguage
                }
            }
        }
    }

    private func save() {
        if let deck {
            deck.name = name; deck.deckDescription = description
            deck.mode = mode
            deck.frontLanguage = mode == .japanese ? "ja-JP" : frontLang
            deck.backLanguage = mode == .japanese ? "ru-RU" : backLang
            deck.updatedAt = Date()
        } else {
            let d = Deck(
                name: name, description: description, mode: mode,
                frontLanguage: mode == .japanese ? "ja-JP" : frontLang,
                backLanguage: mode == .japanese ? "ru-RU" : backLang
            )
            ctx.insert(d)
        }
        dismiss()
    }
}
