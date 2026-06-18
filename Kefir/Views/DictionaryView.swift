import SwiftUI
import SwiftData

// AI-словарь: вводишь слово на любом языке → перевод, транскрипция, синонимы, примеры.
struct DictionaryView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: [SortDescriptor(\Deck.name)]) private var decks: [Deck]

    @State private var query: String = ""
    @State private var result: LookupResult?
    @State private var isLoading = false
    @State private var errorMsg: String?
    @State private var showAddToDeck = false
    @FocusState private var focused: Bool

    struct LookupResult {
        let word: String
        let translation: String
        let ipa: String
        let synonyms: [String]
        let examples: [String]
        let partOfSpeech: String
        let relatedWords: [String]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Поле ввода
                    HStack {
                        TextField("Слово или фраза…", text: $query)
                            .focused($focused)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.title3)
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onSubmit { Task { await lookup() } }

                        Button {
                            Task { await lookup() }
                        } label: {
                            Image(systemName: isLoading ? "hourglass" : "magnifyingglass.circle.fill")
                                .font(.title)
                                .foregroundStyle(.blue)
                        }
                        .disabled(isLoading || query.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal)

                    // Мгновенные локальные данные (до Gemini)
                    if !query.trimmingCharacters(in: .whitespaces).isEmpty && result == nil && !isLoading {
                        localPreview
                    }

                    if let err = errorMsg {
                        Text(err).foregroundStyle(.red).font(.callout).padding(.horizontal)
                    }

                    if let r = result {
                        resultView(r)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("🔎 Словарь")
        }
        .onAppear { focused = true }
    }

    // MARK: - Локальный превью (IPA + синонимы из бандла)

    private var localPreview: some View {
        let word = query.trimmingCharacters(in: .whitespaces)
        let ipa = TranscriptionService.shared.ipa(for: word)
        let syns = SynonymsService.shared.synonyms(for: word, limit: 5)

        return Group {
            if ipa != nil || syns != nil {
                VStack(alignment: .leading, spacing: 8) {
                    if let ipa {
                        HStack {
                            Text(ipa).font(.title3.monospaced()).foregroundStyle(.blue)
                            Button {
                                SpeechService.shared.speak(word, language: "en-US")
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                            }
                        }
                    }
                    if let syns {
                        Text("Синонимы: " + syns.joined(separator: ", "))
                            .font(.callout).foregroundStyle(.purple)
                    }
                    Text("Нажми 🔍 для полного разбора через AI")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Результат AI

    private func resultView(_ r: LookupResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(r.word).font(.largeTitle.bold())
                    if !r.partOfSpeech.isEmpty {
                        Text(r.partOfSpeech)
                            .font(.caption)
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(.blue.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                Spacer()
                Button {
                    SpeechService.shared.speak(r.word, language: detectLang(r.word))
                } label: {
                    Image(systemName: "speaker.wave.2.fill").font(.title2)
                }
            }

            // Перевод
            VStack(alignment: .leading, spacing: 4) {
                Text("Перевод").font(.caption.bold()).foregroundStyle(.secondary)
                Text(r.translation).font(.title2)
            }

            // IPA
            if !r.ipa.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Транскрипция").font(.caption.bold()).foregroundStyle(.secondary)
                    Text(r.ipa).font(.title3.monospaced()).foregroundStyle(.blue)
                }
            }

            // Синонимы
            if !r.synonyms.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Синонимы").font(.caption.bold()).foregroundStyle(.secondary)
                    Text(r.synonyms.joined(separator: ", "))
                        .font(.callout).foregroundStyle(.purple)
                }
            }

            // Примеры
            if !r.examples.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Примеры").font(.caption.bold()).foregroundStyle(.secondary)
                    ForEach(r.examples.indices, id: \.self) { i in
                        HStack(alignment: .top) {
                            Text("•").foregroundStyle(.secondary)
                            Text(r.examples[i]).font(.callout)
                        }
                    }
                }
            }

            // Связанные слова
            if !r.relatedWords.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Связанные слова").font(.caption.bold()).foregroundStyle(.secondary)
                    Text(r.relatedWords.joined(separator: ", "))
                        .font(.callout).foregroundStyle(.teal)
                }
            }

            // Кнопки
            HStack(spacing: 12) {
                Button { showAddToDeck = true } label: {
                    Label("В колоду", systemImage: "plus.rectangle.on.rectangle")
                        .frame(maxWidth: .infinity).padding()
                        .background(.blue).foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button {
                    query = ""
                    result = nil
                    focused = true
                } label: {
                    Label("Ещё", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity).padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .sheet(isPresented: $showAddToDeck) {
            if let r = result {
                AddToDeckSheet(result: r, decks: decks.filter { $0.mode == .classic })
            }
        }
    }

    // MARK: - Lookup

    private func lookup() async {
        let word = query.trimmingCharacters(in: .whitespaces)
        guard !word.isEmpty else { return }
        isLoading = true
        errorMsg = nil
        result = nil
        focused = false
        defer { isLoading = false }

        let prompt = """
        Ты — словарь. Пользователь ввёл слово или фразу: «\(word)»

        Определи язык. Если это русский → переведи на английский. Если английский → на русский. Если японский → на русский.

        Верни ТОЛЬКО JSON без markdown, без пояснений:
        {
          "word": "слово в базовой форме",
          "translation": "перевод",
          "ipa": "IPA транскрипция (если английское слово)",
          "part_of_speech": "noun / verb / adjective / ...",
          "synonyms": ["syn1", "syn2", "syn3"],
          "examples": ["пример 1 (перевод)", "пример 2 (перевод)", "пример 3 (перевод)"],
          "related": ["связанное1", "связанное2"]
        }
        """

        do {
            let raw = try await GeminiService.shared.generateRaw(prompt: prompt)
            let cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard let data = cleaned.data(using: .utf8) else {
                errorMsg = "Не удалось разобрать ответ"
                return
            }
            struct R: Decodable {
                let word: String?; let translation: String?; let ipa: String?
                let part_of_speech: String?; let synonyms: [String]?
                let examples: [String]?; let related: [String]?
            }
            let parsed = try JSONDecoder().decode(R.self, from: data)

            // Дополняем локальными данными
            let localIPA = TranscriptionService.shared.ipa(for: parsed.word ?? word)
            let localSyns = SynonymsService.shared.synonyms(for: parsed.word ?? word, limit: 5) ?? []

            let combinedSyns = Array(Set((parsed.synonyms ?? []) + localSyns)).prefix(8)

            result = LookupResult(
                word: parsed.word ?? word,
                translation: parsed.translation ?? "—",
                ipa: parsed.ipa ?? localIPA ?? "",
                synonyms: Array(combinedSyns),
                examples: parsed.examples ?? [],
                partOfSpeech: parsed.part_of_speech ?? "",
                relatedWords: parsed.related ?? []
            )
        } catch {
            errorMsg = error.localizedDescription
        }
    }

    private func detectLang(_ s: String) -> String {
        for c in s.unicodeScalars {
            if (0x0400...0x04FF).contains(c.value) { return "ru-RU" }
            if (0x3040...0x30FF).contains(c.value) || (0x4E00...0x9FFF).contains(c.value) { return "ja-JP" }
        }
        return "en-US"
    }
}

// MARK: - Добавить слово в колоду

struct AddToDeckSheet: View {
    let result: DictionaryView.LookupResult
    let decks: [Deck]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    @State private var selectedDeck: Deck?

    var body: some View {
        NavigationStack {
            List {
                Section("Слово") {
                    Text("\(result.word) → \(result.translation)")
                }
                Section("Выбери колоду") {
                    ForEach(decks) { deck in
                        Button {
                            selectedDeck = deck
                            addCard(to: deck)
                        } label: {
                            HStack {
                                Text(deck.name)
                                Spacer()
                                if selectedDeck?.id == deck.id {
                                    Image(systemName: "checkmark").foregroundStyle(.green)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("В колоду")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }

    private func addCard(to deck: Deck) {
        let example = result.examples.first ?? ""
        let synonymsStr = result.synonyms.isEmpty ? "" : "Синонимы: " + result.synonyms.joined(separator: ", ")
        let fullExample = [example, synonymsStr].filter { !$0.isEmpty }.joined(separator: "\n")
        let card = Card(deck: deck, front: result.word, back: result.translation, example: fullExample)
        deck.cards.append(card)
        ctx.insert(card)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { dismiss() }
    }
}