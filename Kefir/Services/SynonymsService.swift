import Foundation

// Ищет английские синонимы в бандловом тезаурусе (synonyms_en.json).
// 45k слов с до 8 синонимов у каждого.
final class SynonymsService {
    static let shared = SynonymsService()

    private var dict: [String: [String]] = [:]
    private var loaded = false

    private init() {}

    private func loadIfNeeded() {
        guard !loaded else { return }
        loaded = true
        guard let url = Bundle.main.url(forResource: "synonyms_en", withExtension: "json") else {
            print("[SynonymsService] synonyms_en.json не найден")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            dict = try JSONDecoder().decode([String: [String]].self, from: data)
            print("[SynonymsService] загружено \(dict.count) слов с синонимами")
        } catch {
            print("[SynonymsService] ошибка: \(error)")
        }
    }

    // Возвращает до `limit` синонимов или nil, если нет.
    func synonyms(for word: String, limit: Int = 5) -> [String]? {
        loadIfNeeded()
        let clean = normalize(word)
        guard !clean.isEmpty else { return nil }
        if let list = dict[clean], !list.isEmpty {
            return Array(list.prefix(limit))
        }
        // если фраза — пробуем по первому слову
        let first = clean.split(separator: " ").first.map(String.init) ?? clean
        if first != clean, let list = dict[first], !list.isEmpty {
            return Array(list.prefix(limit))
        }
        return nil
    }

    // Готовая строка для показа: "bold, brave, gallant…" или nil
    func synonymsString(for word: String, limit: Int = 5) -> String? {
        guard let list = synonyms(for: word, limit: limit) else { return nil }
        return list.joined(separator: ", ")
    }

    private func normalize(_ s: String) -> String {
        var result = s.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let remove: [Character] = ["*", "_", "(", ")", "[", "]", "{", "}", ",", ".", "!", "?", "\"", "'"]
        result.removeAll { remove.contains($0) }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
