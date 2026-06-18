import Foundation

struct ImportService {
    // Разделители — таб, |, ;  (первый найденный в строке — используется для всех)
    // Формат: front<sep>back[<sep>example]
    // Для японского: kanji<sep>kana<sep>romaji<sep>meaning
    static func parse(_ text: String, mode: DeckMode) -> [Card] {
        let lines = text
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }

        var result: [Card] = []
        for line in lines {
            let sep = detectSeparator(line)
            let parts = line.split(separator: sep, omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespaces) }

            let card = Card()
            switch mode {
            case .classic:
                guard parts.count >= 2 else { continue }
                card.front = String(parts[0])
                card.back = String(parts[1])
                if parts.count >= 3 { card.example = String(parts[2]) }
            case .japanese:
                guard parts.count >= 2 else { continue }
                // min: kanji|meaning или kana|meaning
                if parts.count == 2 {
                    let first = String(parts[0])
                    if containsKanji(first) {
                        card.kanji = first
                    } else {
                        card.kana = first
                    }
                    card.meaning = String(parts[1])
                } else if parts.count == 3 {
                    card.kanji = String(parts[0])
                    card.kana = String(parts[1])
                    card.meaning = String(parts[2])
                } else {
                    card.kanji = String(parts[0])
                    card.kana = String(parts[1])
                    card.romaji = String(parts[2])
                    card.meaning = String(parts[3])
                }
            }
            result.append(card)
        }
        return result
    }

    private static func detectSeparator(_ line: String) -> Character {
        if line.contains("\t") { return "\t" }
        if line.contains("|") { return "|" }
        if line.contains(";") { return ";" }
        return ","
    }

    private static func containsKanji(_ s: String) -> Bool {
        for scalar in s.unicodeScalars {
            // CJK Unified Ideographs
            if (0x4E00...0x9FFF).contains(scalar.value) { return true }
        }
        return false
    }
}
