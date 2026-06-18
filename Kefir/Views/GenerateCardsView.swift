import SwiftUI
import SwiftData

// Вставляешь текст → Gemini достаёт слова → выбираешь галочки → добавить в колоду
struct GenerateCardsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx

    let deck: Deck

    @State private var inputText: String = ""
    @State private var candidates: [GeminiCardCandidate] = []
    @State private var isLoading = false
    @State private var errorMsg: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Вставь текст") {
                    TextEditor(text: $inputText)
                        .font(.callout)
                        .frame(minHeight: 140)
                    Button {
                        Task { await generate() }
                    } label: {
                        if isLoading {
                            HStack { ProgressView(); Text("Gemini думает…") }
                        } else {
                            Label("Сгенерировать карточки", systemImage: "sparkles")
                        }
                    }
                    .disabled(isLoading || inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                if let err = errorMsg {
                    Section {
                        Text(err).font(.callout).foregroundStyle(.red)
                    }
                }

                if !candidates.isEmpty {
                    Section("Предложенные (\(selectedCount) из \(candidates.count))") {
                        HStack {
                            Button("Все") { setAllSelected(true) }
                            Spacer()
                            Button("Никакие") { setAllSelected(false) }
                        }
                        .font(.caption)
                        ForEach($candidates) { $c in
                            CandidateRow(candidate: $c, mode: deck.mode)
                        }
                    }
                }
            }
            .navigationTitle("AI из текста")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить (\(selectedCount))") { addSelected() }
                        .disabled(selectedCount == 0)
                }
            }
        }
    }

    private var selectedCount: Int { candidates.filter { $0.selected }.count }

    private func setAllSelected(_ value: Bool) {
        for i in candidates.indices { candidates[i].selected = value }
    }

    private func generate() async {
        errorMsg = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await GeminiService.shared.extractCards(from: inputText, mode: deck.mode)
            candidates = result
            if result.isEmpty { errorMsg = "Gemini не вернул карточек — попробуй другой текст" }
        } catch {
            errorMsg = error.localizedDescription
        }
    }

    private func addSelected() {
        for c in candidates where c.selected {
            let card: Card
            switch deck.mode {
            case .classic:
                card = Card(deck: deck, front: c.front, back: c.back, example: c.example)
            case .japanese:
                card = Card(
                    deck: deck,
                    example: c.example,
                    kanji: c.kanji,
                    kana: c.kana,
                    romaji: c.romaji,
                    meaning: c.back
                )
            }
            deck.cards.append(card)
            ctx.insert(card)
        }
        deck.updatedAt = Date()
        dismiss()
    }
}

struct CandidateRow: View {
    @Binding var candidate: GeminiCardCandidate
    let mode: DeckMode

    var body: some View {
        HStack(alignment: .top) {
            Button {
                candidate.selected.toggle()
            } label: {
                Image(systemName: candidate.selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(candidate.selected ? .blue : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                switch mode {
                case .classic:
                    Text(candidate.front).font(.body.bold())
                    Text(candidate.back).font(.callout).foregroundStyle(.secondary)
                case .japanese:
                    HStack(spacing: 6) {
                        if !candidate.kanji.isEmpty {
                            Text(candidate.kanji).font(.body.bold())
                        }
                        if !candidate.kana.isEmpty {
                            Text(candidate.kana).font(.callout).foregroundStyle(.secondary)
                        }
                    }
                    if !candidate.romaji.isEmpty {
                        Text("[\(candidate.romaji)]").font(.caption).foregroundStyle(.tertiary)
                    }
                    Text(candidate.back).font(.callout).foregroundStyle(.secondary)
                }
                if !candidate.example.isEmpty {
                    Text(candidate.example)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}
