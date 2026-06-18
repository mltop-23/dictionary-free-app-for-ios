import Foundation
import SwiftData

// Загружает английский словарь из bundled JSON (english_vocab.json)
// Источник: Obsidian/❤️english/Словарь/ — 36 колод, ~1500 карточек
struct EnglishSeedData {

    struct JSONDeck: Decodable {
        let name: String
        let category: String
        let cards: [JSONCard]
    }
    struct JSONCard: Decodable {
        let front: String
        let back: String
        let example: String
    }
    struct JSONFile: Decodable {
        let decks: [JSONDeck]
    }

    @discardableResult
    static func seed(context: ModelContext) -> String {
        guard let url = Bundle.main.url(forResource: "english_vocab", withExtension: "json") else {
            let msg = "❌ english_vocab.json не найден в Bundle — нужна пересборка (Cmd+Shift+K → Cmd+R)"
            print("[EnglishSeedData] \(msg)")
            return msg
        }
        // Собрать существующие имена колод, чтобы не плодить дубли
        let existingDesc = FetchDescriptor<Deck>()
        let existing = (try? context.fetch(existingDesc)) ?? []
        let existingNames = Set(existing.map { $0.name })

        do {
            let data = try Data(contentsOf: url)
            let parsed = try JSONDecoder().decode(JSONFile.self, from: data)
            var added = 0
            for jd in parsed.decks {
                if existingNames.contains(jd.name) { continue }
                let deck = Deck(
                    name: jd.name,
                    description: jd.category,
                    mode: .classic,
                    frontLanguage: "en-US",
                    backLanguage: "ru-RU"
                )
                context.insert(deck)
                for jc in jd.cards {
                    let card = Card(
                        deck: deck,
                        front: jc.front,
                        back: jc.back,
                        example: jc.example
                    )
                    deck.cards.append(card)
                    context.insert(card)
                }
                added += 1
            }
            let msg = "✅ Английский: добавлено колод \(added) из \(parsed.decks.count)"
            print("[EnglishSeedData] \(msg)")
            return msg
        } catch {
            let msg = "❌ Ошибка парсинга JSON: \(error.localizedDescription)"
            print("[EnglishSeedData] \(msg)")
            return msg
        }
    }
}
