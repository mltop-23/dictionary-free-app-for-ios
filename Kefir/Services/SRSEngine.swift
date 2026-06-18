import Foundation

// SM-2 алгоритм (как в Anki, упрощённый)
enum SRSGrade: Int {
    case again = 0   // забыл совсем
    case heard = 2   // узнал, но не помню перевод (пассивное знание)
    case hard = 3    // вспомнил с трудом
    case good = 4    // вспомнил
    case easy = 5    // легко

    var title: String {
        switch self {
        case .again: return "Забыл"
        case .heard: return "Слышал"
        case .hard: return "Трудно"
        case .good: return "Норм"
        case .easy: return "Легко"
        }
    }
}

struct SRSEngine {

    static func apply(grade: SRSGrade, to card: Card) {
        let now = Date()
        card.lastReviewedAt = now
        card.totalReviews += 1
        if grade != .again { card.correctReviews += 1 }

        let q = Double(grade.rawValue)

        if grade == .again {
            // Сброс
            card.repetitions = 0
            card.intervalDays = 0
            card.stage = .learning
            card.dueAt = now.addingTimeInterval(60 * 10) // 10 мин
        } else if grade == .heard {
            // Узнал на слух — короткий интервал, без роста ease factor
            card.stage = .learning
            card.intervalDays = 0.25 // ~6 часов
            card.dueAt = now.addingTimeInterval(60 * 60 * 6)
        } else {
            // Обновляем ease factor (с нижним порогом 1.3)
            let newEF = card.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
            card.easeFactor = max(1.3, newEF)

            card.repetitions += 1

            let newInterval: Double
            switch card.repetitions {
            case 1:
                newInterval = 1
            case 2:
                newInterval = grade == .easy ? 6 : 3
            default:
                let base = card.intervalDays * card.easeFactor
                // hard — сокращаем, easy — расширяем
                switch grade {
                case .hard: newInterval = max(1, card.intervalDays * 1.2)
                case .easy: newInterval = base * 1.3
                default: newInterval = base
                }
            }
            card.intervalDays = newInterval
            card.dueAt = now.addingTimeInterval(newInterval * 86400)

            if newInterval >= 60 {
                card.stage = .mastered
            } else if newInterval >= 1 {
                card.stage = .review
            } else {
                card.stage = .learning
            }
        }
        card.updatedAt = now
    }

    // Следующие интервалы для отображения кнопок
    static func previewIntervals(for card: Card) -> [SRSGrade: String] {
        var result: [SRSGrade: String] = [:]
        for grade in [SRSGrade.again, .heard, .hard, .good, .easy] {
            result[grade] = previewInterval(grade: grade, card: card)
        }
        return result
    }

    private static func previewInterval(grade: SRSGrade, card: Card) -> String {
        if grade == .again { return "10 мин" }
        if grade == .heard { return "6 ч" }
        let reps = card.repetitions + 1
        let interval: Double
        switch reps {
        case 1: interval = 1
        case 2: interval = grade == .easy ? 6 : 3
        default:
            let base = card.intervalDays * card.easeFactor
            switch grade {
            case .hard: interval = max(1, card.intervalDays * 1.2)
            case .easy: interval = base * 1.3
            default: interval = base
            }
        }
        return formatInterval(days: interval)
    }

    static func formatInterval(days: Double) -> String {
        if days < 1 {
            let hours = Int(days * 24)
            return hours <= 0 ? "<1ч" : "\(hours)ч"
        }
        if days < 30 { return "\(Int(days.rounded()))д" }
        if days < 365 { return "\(Int((days / 30).rounded()))мес" }
        return String(format: "%.1fг", days / 365)
    }
}
