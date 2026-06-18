import Foundation
import SwiftData

@Model
final class Folder {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String       // SF Symbol
    var sortOrder: Int
    var createdAt: Date

    var parent: Folder?

    @Relationship(deleteRule: .cascade, inverse: \Folder.parent)
    var subfolders: [Folder] = []

    @Relationship(inverse: \Deck.folder)
    var decks: [Deck] = []

    init(name: String, icon: String = "folder.fill", sortOrder: Int = 0, parent: Folder? = nil) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
        self.parent = parent
        self.createdAt = Date()
    }

    var allCards: [Card] {
        decks.flatMap { $0.cards } + subfolders.flatMap { $0.allCards }
    }
    var totalDecksCount: Int {
        decks.count + subfolders.reduce(0) { $0 + $1.totalDecksCount }
    }
}
