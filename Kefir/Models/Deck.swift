import Foundation
import SwiftData

enum DeckMode: String, Codable, CaseIterable {
    case classic   // front/back
    case japanese  // kanji/kana/romaji/meaning

    var title: String {
        switch self {
        case .classic: return "Обычный"
        case .japanese: return "Японский"
        }
    }
}

@Model
final class Deck {
    @Attribute(.unique) var id: UUID
    var name: String
    var deckDescription: String
    var modeRaw: String
    var frontLanguage: String   // BCP-47, e.g. "en-US", "ru-RU", "ja-JP"
    var backLanguage: String
    var createdAt: Date
    var updatedAt: Date
    var isReversed: Bool = false   // если true — учим back→front (для en→ru инвертит в ru→en)

    var folder: Folder?

    @Relationship(deleteRule: .cascade, inverse: \Card.deck)
    var cards: [Card] = []

    var mode: DeckMode {
        get { DeckMode(rawValue: modeRaw) ?? .classic }
        set { modeRaw = newValue.rawValue }
    }

    init(
        name: String,
        description: String = "",
        mode: DeckMode = .classic,
        frontLanguage: String = "en-US",
        backLanguage: String = "ru-RU"
    ) {
        self.id = UUID()
        self.name = name
        self.deckDescription = description
        self.modeRaw = mode.rawValue
        self.frontLanguage = frontLanguage
        self.backLanguage = backLanguage
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Stats helpers
    var newCount: Int { cards.filter { $0.stageRaw == CardStage.new.rawValue }.count }
    var learningCount: Int { cards.filter { $0.stageRaw == CardStage.learning.rawValue }.count }
    var reviewCount: Int { cards.filter { $0.stageRaw == CardStage.review.rawValue }.count }
    var masteredCount: Int { cards.filter { $0.stageRaw == CardStage.mastered.rawValue }.count }

    var dueCards: [Card] {
        let now = Date()
        return cards.filter { $0.dueAt <= now }
    }
}
