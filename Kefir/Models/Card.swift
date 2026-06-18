import Foundation
import SwiftData

enum CardStage: String, Codable {
    case new        // ещё не видел
    case learning   // в процессе (короткие интервалы)
    case review     // в повторении (SM-2)
    case mastered   // освоено (интервал > 60 дней)
}

@Model
final class Card {
    @Attribute(.unique) var id: UUID

    // Универсальные поля (classic mode)
    var front: String
    var back: String
    var example: String

    // Японские поля (japanese mode)
    var kanji: String
    var kana: String
    var romaji: String
    var meaning: String

    // SRS (SM-2)
    var stageRaw: String
    var easeFactor: Double      // 2.5 default
    var intervalDays: Double    // последний интервал
    var repetitions: Int        // подряд успешных
    var dueAt: Date
    var lastReviewedAt: Date?

    // Статистика
    var totalReviews: Int
    var correctReviews: Int

    // Избранное
    var isFavorite: Bool = false

    var createdAt: Date
    var updatedAt: Date

    var deck: Deck?

    var stage: CardStage {
        get { CardStage(rawValue: stageRaw) ?? .new }
        set { stageRaw = newValue.rawValue }
    }

    init(
        deck: Deck? = nil,
        front: String = "",
        back: String = "",
        example: String = "",
        kanji: String = "",
        kana: String = "",
        romaji: String = "",
        meaning: String = ""
    ) {
        self.id = UUID()
        self.deck = deck
        self.front = front
        self.back = back
        self.example = example
        self.kanji = kanji
        self.kana = kana
        self.romaji = romaji
        self.meaning = meaning
        self.stageRaw = CardStage.new.rawValue
        self.easeFactor = 2.5
        self.intervalDays = 0
        self.repetitions = 0
        self.dueAt = Date()
        self.lastReviewedAt = nil
        self.totalReviews = 0
        self.correctReviews = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Вопрос и ответ — зависят от режима колоды
    func questionText(for mode: DeckMode, showBack: Bool = false) -> String {
        switch mode {
        case .classic:
            return showBack ? back : front
        case .japanese:
            return showBack ? meaning : (kanji.isEmpty ? kana : kanji)
        }
    }

    func answerText(for mode: DeckMode, showBack: Bool = false) -> String {
        switch mode {
        case .classic:
            return showBack ? front : back
        case .japanese:
            if showBack {
                return kanji.isEmpty ? kana : kanji
            } else {
                var parts: [String] = []
                // Кану показываем в ответе только если есть кандзи (тогда кана — это чтение кандзи).
                // Если кандзи пустое — кана уже была вопросом, не дублируем.
                if !kanji.isEmpty && !kana.isEmpty { parts.append(kana) }
                if !romaji.isEmpty { parts.append("[\(romaji)]") }
                if !meaning.isEmpty { parts.append(meaning) }
                return parts.joined(separator: "\n")
            }
        }
    }

    var isEmpty: Bool {
        switch deck?.mode ?? .classic {
        case .classic: return front.isEmpty && back.isEmpty
        case .japanese: return kanji.isEmpty && kana.isEmpty && meaning.isEmpty
        }
    }

    var accuracy: Double {
        totalReviews == 0 ? 0 : Double(correctReviews) / Double(totalReviews)
    }

    // Для Match: вопрос и ответ без дубликатов — чтобы нельзя было сопоставить визуально
    func matchQuestion(for mode: DeckMode, showBack: Bool = false) -> String {
        switch mode {
        case .classic:
            return showBack ? back : front
        case .japanese:
            if showBack { return meaning }
            return kanji.isEmpty ? kana : kanji
        }
    }

    func matchAnswer(for mode: DeckMode, showBack: Bool = false) -> String {
        switch mode {
        case .classic:
            return showBack ? front : back
        case .japanese:
            if showBack {
                return kanji.isEmpty ? kana : kanji
            }
            // Перевод + ромадзи (без каны — чтобы не дублировать вопрос)
            var parts: [String] = []
            if !romaji.isEmpty { parts.append("[\(romaji)]") }
            if !meaning.isEmpty { parts.append(meaning) }
            return parts.joined(separator: "\n")
        }
    }
}
