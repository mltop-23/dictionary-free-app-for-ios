import SwiftUI

// Режим Write — ввод ответа с клавиатуры.
// Для японского: переключи клавиатуру на 日本語 (глобус) — romaji → kana / kanji автоматически.
// Добавить клавиатуру: Настройки iOS → Основные → Клавиатура → Клавиатуры → Добавить → Японская.
struct WriteView: View {
    let deck: Deck
    @Environment(\.modelContext) private var ctx
    @FocusState private var fieldFocused: Bool

    @State private var queue: [Card] = []
    @State private var userInput: String = ""
    @State private var showResult: Bool = false
    @State private var lastCorrect: Bool = false
    @State private var correctCount: Int = 0
    @State private var totalCount: Int = 0

    var body: some View {
        VStack(spacing: 12) {
            if let card = queue.first {
                // Прогресс
                HStack {
                    Text("Осталось: \(queue.count)")
                    Spacer()
                    Text("✓ \(correctCount) / \(totalCount)")
                }
                .font(.subheadline.monospacedDigit())
                .padding(.horizontal)

                // Подсказка
                VStack(spacing: 8) {
                    Text(promptText(for: card))
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    if let sub = subText(for: card), !sub.isEmpty {
                        Text(sub)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    Button {
                        SpeechService.shared.speak(
                            promptText(for: card),
                            language: promptLang(for: card)
                        )
                    } label: {
                        Label("Озвучить", systemImage: "speaker.wave.2.fill")
                            .font(.callout)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                if deck.mode == .japanese {
                    Text("💡 Переключи клавиатуру на 日本語 через 🌐")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Поле ввода
                TextField(placeholder(for: card), text: $userInput)
                    .focused($fieldFocused)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .onSubmit { if !showResult { check(card: card) } }

                // Результат
                if showResult {
                    resultBlock(for: card)
                } else {
                    HStack(spacing: 12) {
                        Button {
                            skip(card: card)
                        } label: {
                            Text("Пропустить")
                                .frame(maxWidth: .infinity).padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        Button {
                            check(card: card)
                        } label: {
                            Text("Проверить")
                                .frame(maxWidth: .infinity).padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal)
                }

                Spacer()
            } else {
                ContentUnavailableView {
                    Label("Готово!", systemImage: "checkmark.seal.fill").foregroundStyle(.green)
                } description: {
                    Text("Правильно: \(correctCount) из \(totalCount)")
                }
                Button("Ещё раз") { start() }.buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Write")
        .onAppear {
            start()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { fieldFocused = true }
        }
    }

    private var inputBackground: Color {
        guard showResult else { return Color(.secondarySystemBackground) }
        return lastCorrect ? .green.opacity(0.25) : .red.opacity(0.25)
    }

    // MARK: - Подсказки

    private func promptText(for card: Card) -> String {
        switch deck.mode {
        case .japanese: return card.meaning
        case .classic: return deck.isReversed ? card.front : card.back
        }
    }

    private func subText(for card: Card) -> String? {
        switch deck.mode {
        case .japanese:
            return card.romaji.isEmpty ? nil : "[\(card.romaji)]"
        case .classic: return nil
        }
    }

    private func promptLang(for card: Card) -> String {
        switch deck.mode {
        case .japanese: return "ru-RU"
        case .classic: return deck.isReversed ? deck.frontLanguage : deck.backLanguage
        }
    }

    private func placeholder(for card: Card) -> String {
        switch deck.mode {
        case .japanese: return "Введи кандзи или кану"
        case .classic: return deck.isReversed ? "Введи на \(deck.backLanguage)" : "Введи на \(deck.frontLanguage)"
        }
    }

    private func acceptedAnswers(for card: Card) -> [String] {
        switch deck.mode {
        case .japanese:
            return [card.kanji, card.kana, card.romaji].filter { !$0.isEmpty }
        case .classic:
            return [deck.isReversed ? card.back : card.front]
        }
    }

    // MARK: - Результат

    private func resultBlock(for card: Card) -> some View {
        VStack(spacing: 10) {
            if lastCorrect {
                Label("Верно!", systemImage: "checkmark.circle.fill")
                    .font(.title3.bold()).foregroundStyle(.green)
            } else {
                VStack(spacing: 6) {
                    Label("Не совсем", systemImage: "xmark.circle.fill")
                        .font(.title3.bold()).foregroundStyle(.red)
                    Text("Правильно: ")
                        .foregroundStyle(.secondary)
                    +
                    Text(acceptedAnswers(for: card).joined(separator: " / "))
                        .font(.title2.bold())

                    // Диагностика — видно где именно разница
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ты ввёл: \(userInput)")
                            .font(.caption)
                        Text("Коды: \(hexDump(userInput))")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.tertiary)
                        let expected = acceptedAnswers(for: card).first ?? ""
                        Text("Ожидалось: \(expected)")
                            .font(.caption)
                        Text("Коды: \(hexDump(expected))")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.tertiary)

                        // Быстрая кнопка «зачесть» если пользователь считает что совпало
                        Button {
                            lastCorrect = true
                            correctCount += 1
                            card.correctReviews += 1
                        } label: {
                            Label("Зачесть как правильный", systemImage: "hand.thumbsup")
                                .font(.caption)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.top, 4)
                }
            }
            Button {
                nextCard()
            } label: {
                Text("Дальше")
                    .frame(maxWidth: .infinity).padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Логика

    private func start() {
        let source = deck.cards.filter { !acceptedAnswers(for: $0).isEmpty }
        queue = source.shuffled()
        userInput = ""
        showResult = false
        correctCount = 0
        totalCount = 0
    }

    private func check(card: Card) {
        let input = normalize(userInput)
        let accepted = acceptedAnswers(for: card).map { normalize($0) }
        lastCorrect = !input.isEmpty && accepted.contains(input)
        showResult = true
        totalCount += 1
        if lastCorrect { correctCount += 1 }
        card.totalReviews += 1
        if lastCorrect { card.correctReviews += 1 }
        card.lastReviewedAt = Date()
        fieldFocused = false
    }

    // Нормализация: NFC + lowercase + без пробелов + маленькие каны → обычные + катакана → хирагана
    private func normalize(_ s: String) -> String {
        var result = s.precomposedStringWithCanonicalMapping.lowercased()
        // 1. убираем пробелы/переносы
        result = String(result.unicodeScalars
            .filter { !CharacterSet.whitespacesAndNewlines.contains($0) }
            .map { Character($0) })
        // 2. маленькие каны → обычные
        for (small, big) in Self.smallToBigKana {
            result = result.replacingOccurrences(of: small, with: big)
        }
        // 3. катакана → хирагана (одинаковый звук — засчитываем)
        result = String(result.unicodeScalars.map { scalar -> Character in
            let v = scalar.value
            // Katakana block U+30A1...U+30F6 → Hiragana U+3041...U+3096 (разница 0x60)
            if (0x30A1...0x30F6).contains(v) {
                return Character(Unicode.Scalar(v - 0x60)!)
            }
            return Character(scalar)
        })
        return result
    }

    private static let smallToBigKana: [(String, String)] = [
        ("ぁ", "あ"), ("ぃ", "い"), ("ぅ", "う"), ("ぇ", "え"), ("ぉ", "お"),
        ("ゃ", "や"), ("ゅ", "ゆ"), ("ょ", "よ"), ("ゎ", "わ"),
        ("ァ", "ア"), ("ィ", "イ"), ("ゥ", "ウ"), ("ェ", "エ"), ("ォ", "オ"),
        ("ャ", "ヤ"), ("ュ", "ユ"), ("ョ", "ヨ"), ("ヮ", "ワ")
    ]

    // Hex-дамп для диагностики — показывает реальные коды
    private func hexDump(_ s: String) -> String {
        s.unicodeScalars.map { String(format: "U+%04X", $0.value) }.joined(separator: " ")
    }

    private func skip(card: Card) {
        queue.removeFirst()
        queue.append(card)
        userInput = ""
        fieldFocused = true
    }

    private func nextCard() {
        let wasCorrect = lastCorrect
        let card = queue.removeFirst()
        if !wasCorrect { queue.append(card) }
        userInput = ""
        showResult = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { fieldFocused = true }
    }
}
