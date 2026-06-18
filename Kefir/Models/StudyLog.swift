import Foundation
import SwiftData

@Model
final class StudyLog {
    @Attribute(.unique) var id: UUID
    var date: Date          // день (truncated)
    var cardsReviewed: Int
    var cardsCorrect: Int
    var secondsSpent: Int

    init(date: Date = Calendar.current.startOfDay(for: Date())) {
        self.id = UUID()
        self.date = date
        self.cardsReviewed = 0
        self.cardsCorrect = 0
        self.secondsSpent = 0
    }
}
