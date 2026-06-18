import SwiftUI
import SwiftData

struct CardEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx

    let deck: Deck
    let card: Card?

    @State private var front: String = ""
    @State private var back: String = ""
    @State private var example: String = ""
    @State private var kanji: String = ""
    @State private var kana: String = ""
    @State private var romaji: String = ""
    @State private var meaning: String = ""
    @State private var isFavorite: Bool = false
    @State private var aiExamples: [String] = []
    @State private var aiLoading = false
    @State private var aiError: String?
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                if deck.mode == .classic {
                    Section("Лицевая") {
                        TextField("Front", text: $front, axis: .vertical)
                    }
                    Section("Обратная") {
                        TextField("Back", text: $back, axis: .vertical)
                    }
                    Section("Пример (опционально)") {
                        TextField("Пример использования", text: $example, axis: .vertical)
                    }
                } else {
                    Section("Кандзи") {
                        TextField("漢字", text: $kanji)
                    }
                    Section("Кана") {
                        TextField("かな / カナ", text: $kana)
                    }
                    Section("Ромадзи") {
                        TextField("romaji", text: $romaji)
                    }
                    Section("Значение") {
                        TextField("Значение", text: $meaning, axis: .vertical)
                    }
                    Section("Пример (опционально)") {
                        TextField("Пример", text: $example, axis: .vertical)
                    }
                }
                Section {
                    Toggle(isOn: $isFavorite) {
                        Label("Избранное", systemImage: isFavorite ? "star.fill" : "star")
                            .foregroundStyle(isFavorite ? .yellow : .primary)
                    }
                }

                if card != nil {
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Удалить карточку", systemImage: "trash")
                        }
                    }
                }

                Section("AI") {
                    Button {
                        Task { await loadExamples() }
                    } label: {
                        HStack {
                            if aiLoading { ProgressView() }
                            Label("Сгенерировать 3 примера", systemImage: "sparkles")
                        }
                    }
                    .disabled(aiLoading || !hasMinimumContent)
                    if let err = aiError {
                        Text(err).font(.caption).foregroundStyle(.red)
                    }
                    ForEach(aiExamples.indices, id: \.self) { i in
                        HStack(alignment: .top) {
                            Text(aiExamples[i]).font(.callout)
                            Spacer()
                            Button {
                                example = aiExamples[i]
                            } label: {
                                Image(systemName: "arrow.up.doc.on.clipboard")
                            }
                            .buttonStyle(.plain)
                            .help("Вставить как пример")
                        }
                    }
                }
            }
            .navigationTitle(card == nil ? "Новая карточка" : "Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { save() }
                        .disabled(isEmpty)
                }
            }
            .onAppear(perform: load)
            .confirmationDialog("Удалить карточку?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Удалить", role: .destructive) { deleteCard() }
                Button("Отмена", role: .cancel) {}
            }
        }
    }

    private func deleteCard() {
        guard let card else { return }
        ctx.delete(card)
        dismiss()
    }

    private var isEmpty: Bool {
        switch deck.mode {
        case .classic: return front.trimmingCharacters(in: .whitespaces).isEmpty || back.trimmingCharacters(in: .whitespaces).isEmpty
        case .japanese: return (kanji + kana).trimmingCharacters(in: .whitespaces).isEmpty || meaning.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private var hasMinimumContent: Bool {
        switch deck.mode {
        case .classic: return !front.trimmingCharacters(in: .whitespaces).isEmpty
        case .japanese: return !(kanji + kana).trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private func loadExamples() async {
        aiError = nil
        aiLoading = true
        defer { aiLoading = false }
        let temp = Card(
            deck: deck, front: front, back: back,
            kanji: kanji, kana: kana, romaji: romaji, meaning: meaning
        )
        do {
            aiExamples = try await GeminiService.shared.generateExamples(for: temp, mode: deck.mode)
        } catch {
            aiError = error.localizedDescription
        }
    }

    private func load() {
        guard let card else { return }
        front = card.front
        back = card.back
        example = card.example
        kanji = card.kanji
        kana = card.kana
        romaji = card.romaji
        meaning = card.meaning
        isFavorite = card.isFavorite
    }

    private func save() {
        let c = card ?? Card(deck: deck)
        c.front = front
        c.back = back
        c.example = example
        c.kanji = kanji
        c.kana = kana
        c.romaji = romaji
        c.meaning = meaning
        c.isFavorite = isFavorite
        c.updatedAt = Date()
        if card == nil {
            ctx.insert(c)
            deck.cards.append(c)
        }
        deck.updatedAt = Date()
        // Явно фиксируем запись: не полагаемся только на autosave — гарантируем,
        // что новая/изменённая карточка точно сохранится на диск.
        try? ctx.save()
        dismiss()
    }
}
