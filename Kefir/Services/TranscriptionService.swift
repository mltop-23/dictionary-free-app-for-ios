import Foundation

// Ищет IPA-транскрипцию английских слов в бандловом словаре (ipa_en.json).
// Загружается один раз, хранит 126k пар word → /IPA/.
final class TranscriptionService {
    static let shared = TranscriptionService()

    private var dict: [String: String] = [:]
    private var loaded = false

    private init() {}

    private func loadIfNeeded() {
        guard !loaded else { return }
        loaded = true
        guard let url = Bundle.main.url(forResource: "ipa_en", withExtension: "json") else {
            print("[TranscriptionService] ipa_en.json не найден")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            dict = try JSONDecoder().decode([String: String].self, from: data)
            print("[TranscriptionService] загружено \(dict.count) IPA записей")
        } catch {
            print("[TranscriptionService] ошибка: \(error)")
        }
    }

    // Возвращает транскрипцию или nil если слова нет.
    // Слово чистится от markdown-звёздочек, скобок, точек и т.п.
    func ipa(for word: String) -> String? {
        loadIfNeeded()
        let clean = normalize(word)
        guard !clean.isEmpty else { return nil }
        if let direct = dict[clean] { return direct }
        // Попытка с первым словом (если это фраза вроде "give up")
        let first = clean.split(separator: " ").first.map(String.init) ?? clean
        return dict[first]
    }

    private func normalize(_ s: String) -> String {
        var result = s.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // убрать markdown и пунктуацию
        let remove: [Character] = ["*", "_", "(", ")", "[", "]", "{", "}", ",", ".", "!", "?", "\"", "'"]
        result.removeAll { remove.contains($0) }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
