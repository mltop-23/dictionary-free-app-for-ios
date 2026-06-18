import Foundation

// Интеграция с Google Gemini API.
// Бесплатный tier: получи ключ на https://aistudio.google.com/apikey
// Модель gemini-2.0-flash — быстрая и дешёвая.

enum GeminiError: LocalizedError {
    case noApiKey
    case badResponse(String)
    case parse(String)

    var errorDescription: String? {
        switch self {
        case .noApiKey: return "Не задан API ключ Gemini. Настройки → Gemini API."
        case .badResponse(let s): return "Gemini: \(s)"
        case .parse(let s): return "Не удалось разобрать ответ: \(s)"
        }
    }
}

struct GeminiCardCandidate: Identifiable, Codable {
    var id: UUID = UUID()
    var front: String       // для classic — оригинал, для japanese — kanji
    var back: String        // для classic — перевод, для japanese — meaning (русский)
    var example: String     // пример использования
    // Японские доп. поля (опционально)
    var kanji: String = ""
    var kana: String = ""
    var romaji: String = ""
    var selected: Bool = true   // галка в UI
}

struct GeminiService {
    static let shared = GeminiService()

    private let model = "gemini-2.0-flash"
    private var endpoint: String {
        "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent"
    }

    private var apiKey: String? {
        let k = UserDefaults.standard.string(forKey: "gemini_api_key") ?? ""
        return k.isEmpty ? nil : k
    }

    // MARK: - Извлечение карточек из текста

    func extractCards(from text: String, mode: DeckMode, targetLang: String = "русский") async throws -> [GeminiCardCandidate] {
        let prompt: String
        switch mode {
        case .classic:
            prompt = """
            Извлеки из следующего текста незнакомые или редкие слова/словосочетания, которые стоит выучить (уровень B1-C1). Для каждого дай:
            - front: слово или выражение (в базовой форме, как в словаре)
            - back: краткий перевод на \(targetLang)
            - example: короткое предложение с этим словом (если в тексте есть — бери оттуда, иначе сочини)

            Верни ТОЛЬКО валидный JSON-массив, без markdown-блока, без пояснений. Формат:
            [{"front":"...","back":"...","example":"..."}]

            Максимум 30 карточек. Не включай совсем простые слова (the, is, and). Только содержательные.

            Текст:
            \(text)
            """
        case .japanese:
            prompt = """
            Извлеки из следующего текста японские слова или выражения, которые стоит выучить (уровень N5-N2). Для каждого верни:
            - kanji: запись кандзи (если нет — пустая строка)
            - kana: хирагана или катакана
            - romaji: транскрипция ромадзи
            - meaning: перевод на \(targetLang)
            - example: короткое предложение с этим словом

            Верни ТОЛЬКО валидный JSON-массив, без markdown, без пояснений. Формат:
            [{"kanji":"...","kana":"...","romaji":"...","meaning":"...","example":"..."}]

            Максимум 30 слов. Только содержательные.

            Текст:
            \(text)
            """
        }
        let raw = try await generate(prompt: prompt)
        return try parseCards(from: raw, mode: mode)
    }

    // MARK: - Аудит переводов колоды

    struct TranslationIssue: Identifiable {
        let id = UUID()
        let cardID: UUID
        let front: String
        let currentBack: String
        let issue: String
        let suggestedBack: String
    }

    func auditTranslations(cards: [Card]) async throws -> [TranslationIssue] {
        // Батч по 30 карточек за запрос
        var all: [TranslationIssue] = []
        let batchSize = 30
        for i in stride(from: 0, to: cards.count, by: batchSize) {
            let batch = Array(cards[i..<min(i + batchSize, cards.count)])
            let issues = try await auditBatch(batch)
            all.append(contentsOf: issues)
        }
        return all
    }

    private func auditBatch(_ cards: [Card]) async throws -> [TranslationIssue] {
        let listing = cards.enumerated().map { idx, c in
            "\(idx). \(c.front) — \(c.back)"
        }.joined(separator: "\n")

        let prompt = """
        Ты — эксперт по английско-русским переводам. Проверь этот список карточек и найди только те, где перевод ОЧЕВИДНО неправильный, неточный или вводит в заблуждение.

        НЕ отмечай:
        - Слова с несколькими валидными значениями (если текущий перевод — одно из них)
        - Контекстуальные/идиоматические переводы (они часто намеренно неполны)
        - Стилистические варианты (одно и то же разными словами)

        Отмечай только реальные ошибки: не те слова, противоположные значения, opečatки.

        Для каждой проблемы верни:
        - index: номер в списке
        - issue: краткое описание проблемы (одна фраза на русском)
        - suggested_back: исправленный перевод

        Верни ТОЛЬКО JSON-массив, без markdown, без пояснений:
        [{"index":N,"issue":"...","suggested_back":"..."}]

        Если всё нормально — верни пустой массив: []

        Список:
        \(listing)
        """

        let raw = try await generate(prompt: prompt)
        let cleaned = stripCodeFence(raw)
        guard let data = cleaned.data(using: .utf8) else {
            throw GeminiError.parse("not utf8")
        }
        struct Row: Decodable { let index: Int; let issue: String; let suggested_back: String }
        let rows = (try? JSONDecoder().decode([Row].self, from: data)) ?? []
        return rows.compactMap { row in
            guard row.index >= 0 && row.index < cards.count else { return nil }
            let c = cards[row.index]
            return TranslationIssue(
                cardID: c.id,
                front: c.front,
                currentBack: c.back,
                issue: row.issue,
                suggestedBack: row.suggested_back
            )
        }
    }

    // MARK: - Примеры для одной карточки

    func generateExamples(for card: Card, mode: DeckMode) async throws -> [String] {
        let word: String
        let lang: String
        switch mode {
        case .classic:
            word = card.front
            lang = "английском"
        case .japanese:
            word = card.kanji.isEmpty ? card.kana : "\(card.kanji) (\(card.kana))"
            lang = "японском"
        }
        let prompt = """
        Дай 3 разных коротких предложения на \(lang) с использованием слова «\(word)» (перевод: \(card.back.isEmpty ? card.meaning : card.back)). Каждое предложение — с переводом на русский в скобках.

        Формат вывода — чистый JSON массив строк, без markdown, без пояснений:
        ["предложение 1 (перевод)", "предложение 2 (перевод)", "предложение 3 (перевод)"]
        """
        let raw = try await generate(prompt: prompt)
        let cleaned = stripCodeFence(raw)
        guard let data = cleaned.data(using: .utf8),
              let arr = try? JSONDecoder().decode([String].self, from: data) else {
            // Фолбэк — просто разбиение по строкам
            return raw.split(whereSeparator: \.isNewline).map { String($0) }.filter { !$0.isEmpty }
        }
        return arr
    }

    // MARK: - Публичный доступ к генерации (для словаря)
    func generateRaw(prompt: String) async throws -> String {
        return try await generate(prompt: prompt)
    }

    // MARK: - Низкоуровневый вызов

    private func generate(prompt: String) async throws -> String {
        guard let key = apiKey else { throw GeminiError.noApiKey }
        guard var comps = URLComponents(string: endpoint) else {
            throw GeminiError.badResponse("bad url")
        }
        comps.queryItems = [URLQueryItem(name: "key", value: key)]
        guard let url = comps.url else { throw GeminiError.badResponse("bad url") }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.3,
                "maxOutputTokens": 4096
            ]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw GeminiError.badResponse("no http response")
        }
        if http.statusCode != 200 {
            let msg = String(data: data, encoding: .utf8) ?? "status \(http.statusCode)"
            throw GeminiError.badResponse(msg.prefix(400).description)
        }

        struct GResp: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable { let text: String? }
                    let parts: [Part]?
                }
                let content: Content?
            }
            let candidates: [Candidate]?
        }
        let parsed = try JSONDecoder().decode(GResp.self, from: data)
        let text = parsed.candidates?.first?.content?.parts?.compactMap { $0.text }.joined() ?? ""
        if text.isEmpty { throw GeminiError.badResponse("empty response") }
        return text
    }

    // MARK: - Парсинг

    private func parseCards(from raw: String, mode: DeckMode) throws -> [GeminiCardCandidate] {
        let cleaned = stripCodeFence(raw)
        guard let data = cleaned.data(using: .utf8) else {
            throw GeminiError.parse("not utf8")
        }
        switch mode {
        case .classic:
            struct Row: Decodable { let front: String; let back: String; let example: String? }
            let rows = try JSONDecoder().decode([Row].self, from: data)
            return rows.map { GeminiCardCandidate(front: $0.front, back: $0.back, example: $0.example ?? "") }
        case .japanese:
            struct Row: Decodable {
                let kanji: String?; let kana: String?; let romaji: String?
                let meaning: String; let example: String?
            }
            let rows = try JSONDecoder().decode([Row].self, from: data)
            return rows.map {
                var c = GeminiCardCandidate(
                    front: $0.kanji?.isEmpty == false ? $0.kanji! : ($0.kana ?? ""),
                    back: $0.meaning,
                    example: $0.example ?? ""
                )
                c.kanji = $0.kanji ?? ""
                c.kana = $0.kana ?? ""
                c.romaji = $0.romaji ?? ""
                return c
            }
        }
    }

    private func stripCodeFence(_ s: String) -> String {
        var t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasPrefix("```json") { t = String(t.dropFirst(7)) }
        else if t.hasPrefix("```") { t = String(t.dropFirst(3)) }
        if t.hasSuffix("```") { t = String(t.dropLast(3)) }
        return t.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
