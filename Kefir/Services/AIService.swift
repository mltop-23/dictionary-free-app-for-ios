import Foundation

// Абстракция над AI-провайдерами. Вся генерация (примеры, извлечение карточек,
// аудит переводов, словарь) идёт через AIBackend.generate(...), а он выбирает
// провайдера по настройке. Так если один провайдер сломается/исчерпает лимит —
// можно переключиться на другой, не трогая остальной код.

enum AIProvider: String, CaseIterable, Identifiable {
    case gemini
    case openai

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gemini: return "Google Gemini"
        case .openai: return "OpenAI (GPT)"
        }
    }

    /// Ключ в UserDefaults, где хранится API-ключ провайдера.
    var keyDefaultsKey: String {
        switch self {
        case .gemini: return "gemini_api_key"
        case .openai: return "openai_api_key"
        }
    }

    /// Где взять ключ.
    var keyURL: String {
        switch self {
        case .gemini: return "https://aistudio.google.com/apikey"
        case .openai: return "https://platform.openai.com/api-keys"
        }
    }

    /// Модель по умолчанию (быстрая и дешёвая).
    var defaultModel: String {
        switch self {
        case .gemini: return "gemini-2.0-flash"
        case .openai: return "gpt-4o-mini"
        }
    }
}

enum AISettings {
    private static let providerKey = "ai_provider"

    static var provider: AIProvider {
        get { AIProvider(rawValue: UserDefaults.standard.string(forKey: providerKey) ?? "") ?? .gemini }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: providerKey) }
    }

    static func apiKey(for p: AIProvider) -> String? {
        let k = (UserDefaults.standard.string(forKey: p.keyDefaultsKey) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return k.isEmpty ? nil : k
    }

    /// Есть ли хоть какой-то рабочий ключ для текущего провайдера.
    static var isConfigured: Bool { apiKey(for: provider) != nil }
}

enum AIError: LocalizedError {
    case noApiKey(AIProvider)
    case badResponse(String)
    case parse(String)

    var errorDescription: String? {
        switch self {
        case .noApiKey(let p):
            return "Не задан API-ключ (\(p.title)). Настройки → AI-провайдер."
        case .badResponse(let s):
            return "Ошибка AI: \(s)"
        case .parse(let s):
            return "Не удалось разобрать ответ: \(s)"
        }
    }
}

// MARK: - Низкоуровневый вызов выбранного провайдера

enum AIBackend {

    static func generate(prompt: String, temperature: Double = 0.3) async throws -> String {
        let provider = AISettings.provider
        guard let key = AISettings.apiKey(for: provider) else { throw AIError.noApiKey(provider) }
        switch provider {
        case .gemini: return try await generateGemini(prompt: prompt, key: key, temperature: temperature)
        case .openai: return try await generateOpenAI(prompt: prompt, key: key, temperature: temperature)
        }
    }

    // MARK: Google Gemini (generateContent)

    private static func generateGemini(prompt: String, key: String, temperature: Double) async throws -> String {
        let model = AIProvider.gemini.defaultModel
        guard var comps = URLComponents(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent") else {
            throw AIError.badResponse("bad url")
        }
        comps.queryItems = [URLQueryItem(name: "key", value: key)]
        guard let url = comps.url else { throw AIError.badResponse("bad url") }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": ["temperature": temperature, "maxOutputTokens": 4096]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        try checkStatus(resp, data)

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
        if text.isEmpty { throw AIError.badResponse("пустой ответ Gemini") }
        return text
    }

    // MARK: OpenAI (chat completions)

    private static func generateOpenAI(prompt: String, key: String, temperature: Double) async throws -> String {
        let model = AIProvider.openai.defaultModel
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw AIError.badResponse("bad url")
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = [
            "model": model,
            "messages": [["role": "user", "content": prompt]],
            "temperature": temperature,
            "max_tokens": 4096
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        try checkStatus(resp, data)

        struct OResp: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable { let content: String? }
                let message: Message?
            }
            let choices: [Choice]?
        }
        let parsed = try JSONDecoder().decode(OResp.self, from: data)
        let text = parsed.choices?.first?.message?.content ?? ""
        if text.isEmpty { throw AIError.badResponse("пустой ответ OpenAI") }
        return text
    }

    private static func checkStatus(_ resp: URLResponse, _ data: Data) throws {
        guard let http = resp as? HTTPURLResponse else { throw AIError.badResponse("нет HTTP-ответа") }
        if http.statusCode != 200 {
            let msg = String(data: data, encoding: .utf8) ?? "status \(http.statusCode)"
            throw AIError.badResponse(msg.prefix(400).description)
        }
    }
}
