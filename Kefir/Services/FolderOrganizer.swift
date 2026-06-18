import Foundation
import SwiftData

// Создаёт папки «Английский» / «Японский» + подпапки, раскидывает колоды.
// Также сеет новые колоды (IT/SRE, Business, Immigration, Travel, Idioms, Phrasal Advanced).
// Идемпотентно: не создаёт дубликатов.

struct FolderOrganizer {
    // Текущая версия набора встроенных колод. Увеличивать при добавлении новых.
    static let seedVersion = 3
    private static let versionKey = "folders_seed_version"

    // Запускается только если версия ещё не сохранена (или старше). Мгновенно пропускается на повторных запусках.
    static func ensureFoldersAndSeedIfNeeded(context: ModelContext) {
        let saved = UserDefaults.standard.integer(forKey: versionKey)
        guard saved < seedVersion else { return }
        ensureFoldersAndSeed(context: context)
        UserDefaults.standard.set(seedVersion, forKey: versionKey)
    }

    // Принудительный запуск (по кнопке в Настройках)
    static func forceResync(context: ModelContext) {
        ensureFoldersAndSeed(context: context)
        UserDefaults.standard.set(seedVersion, forKey: versionKey)
    }

    static func ensureFoldersAndSeed(context: ModelContext) {
        let english = ensureFolder(context: context, name: "🇬🇧 Английский", icon: "a.book.closed", sortOrder: 0, parent: nil)
        let japanese = ensureFolder(context: context, name: "🇯🇵 Японский", icon: "character.book.closed.ja", sortOrder: 1, parent: nil)

        // English subfolders
        let enWords = ensureFolder(context: context, name: "Словарь", icon: "textformat.abc", sortOrder: 0, parent: english)
        let enIT = ensureFolder(context: context, name: "IT / SRE / DevOps", icon: "server.rack", sortOrder: 1, parent: english)
        let enBiz = ensureFolder(context: context, name: "Business English", icon: "briefcase", sortOrder: 2, parent: english)
        let enImmig = ensureFolder(context: context, name: "Иммиграция / Визы", icon: "airplane.departure", sortOrder: 3, parent: english)
        let enTravel = ensureFolder(context: context, name: "Путешествия", icon: "suitcase", sortOrder: 4, parent: english)
        let enIdioms = ensureFolder(context: context, name: "Идиомы и фразы", icon: "quote.bubble", sortOrder: 5, parent: english)
        let enPhrasal = ensureFolder(context: context, name: "Phrasal Verbs Advanced", icon: "arrow.triangle.branch", sortOrder: 6, parent: english)

        // Japanese subfolders
        let jaKana = ensureFolder(context: context, name: "Кана", icon: "character.textbox.ja", sortOrder: 0, parent: japanese)
        let jaN5 = ensureFolder(context: context, name: "JLPT N5", icon: "5.square", sortOrder: 1, parent: japanese)

        // Раскидать существующие колоды по именам
        let allDecks = (try? context.fetch(FetchDescriptor<Deck>())) ?? []
        for deck in allDecks where deck.folder == nil {
            deck.folder = classify(deck: deck,
                                    enWords: enWords,
                                    jaKana: jaKana, jaN5: jaN5,
                                    englishFallback: english, japaneseFallback: japanese)
        }

        // Сеять новые английские колоды (если ещё нет)
        seedExtra(context: context, name: "IT / SRE / DevOps (80)", folder: enIT, entries: EnglishExtraDecks.itSre)
        seedExtra(context: context, name: "Business English (70)", folder: enBiz, entries: EnglishExtraDecks.business)
        seedExtra(context: context, name: "Иммиграция / Визы (55)", folder: enImmig, entries: EnglishExtraDecks.immigration)
        seedExtra(context: context, name: "Travel: Аэропорт", folder: enTravel, entries: EnglishExtraDecks.travelAirport)
        seedExtra(context: context, name: "Travel: Отель и еда", folder: enTravel, entries: EnglishExtraDecks.travelHotelFood)
        seedExtra(context: context, name: "Travel: Дорога и город", folder: enTravel, entries: EnglishExtraDecks.travelDirections)
        seedExtra(context: context, name: "Идиомы (70)", folder: enIdioms, entries: EnglishExtraDecks.idioms)
        seedExtra(context: context, name: "Phrasal Verbs Basic A2-B1", folder: enPhrasal, entries: EnglishExtraDecks.phrasalBasic)
        seedExtra(context: context, name: "Phrasal Verbs Intermediate B1-B2", folder: enPhrasal, entries: EnglishExtraDecks.phrasalIntermediate)
        seedExtra(context: context, name: "Phrasal Verbs Advanced C1", folder: enPhrasal, entries: EnglishExtraDecks.phrasalAdvanced)

        // Миграция: если предыдущая версия создала эти папки на верхнем уровне — переносим внутрь English
        migrateRootFolderUnderEnglish(context: context, folderName: "🏠 Жизнь и быт", english: english)
        migrateRootFolderUnderEnglish(context: context, folderName: "🧳 Переезд", english: english)
        migrateRootFolderUnderEnglish(context: context, folderName: "🎨 Разное", english: english)

        // === Жизнь и быт (внутри English) ===
        let lifeRoot = ensureFolder(context: context, name: "🏠 Жизнь и быт", icon: "house.fill", sortOrder: 7, parent: english)
        let fBody = ensureFolder(context: context, name: "Тело и спортзал", icon: "figure.strengthtraining.traditional", sortOrder: 0, parent: lifeRoot)
        let fFood = ensureFolder(context: context, name: "Еда и готовка", icon: "fork.knife", sortOrder: 1, parent: lifeRoot)
        let fEmotions = ensureFolder(context: context, name: "Эмоции", icon: "heart.circle", sortOrder: 2, parent: lifeRoot)
        let fWeather = ensureFolder(context: context, name: "Погода и природа", icon: "cloud.sun", sortOrder: 3, parent: lifeRoot)
        let fHome = ensureFolder(context: context, name: "Дом", icon: "bed.double", sortOrder: 4, parent: lifeRoot)

        seedExtra(context: context, name: "Тело: Мышцы", folder: fBody, entries: EnglishLifeDecks.bodyMuscles)
        seedExtra(context: context, name: "Тело: Кости и органы", folder: fBody, entries: EnglishLifeDecks.bodyOrgans)
        seedExtra(context: context, name: "Спортзал", folder: fBody, entries: EnglishLifeDecks.bodyGym)

        seedExtra(context: context, name: "Еда: Продукты", folder: fFood, entries: EnglishLifeDecks.foodGroceries)
        seedExtra(context: context, name: "Еда: Готовка (глаголы)", folder: fFood, entries: EnglishLifeDecks.foodCooking)
        seedExtra(context: context, name: "Еда: Кухня (утварь)", folder: fFood, entries: EnglishLifeDecks.foodKitchen)

        seedExtra(context: context, name: "Эмоции и состояния", folder: fEmotions, entries: EnglishLifeDecks.emotions)
        seedExtra(context: context, name: "Погода и ландшафт", folder: fWeather, entries: EnglishLifeDecks.weather)
        seedExtra(context: context, name: "Дом: мебель, техника, быт", folder: fHome, entries: EnglishLifeDecks.home)

        // === Переезд (внутри English) ===
        let moveRoot = ensureFolder(context: context, name: "🧳 Переезд", icon: "airplane.departure", sortOrder: 8, parent: english)
        let fRental = ensureFolder(context: context, name: "Аренда жилья", icon: "key", sortOrder: 0, parent: moveRoot)
        let fBanking = ensureFolder(context: context, name: "Банк и финансы", icon: "creditcard", sortOrder: 1, parent: moveRoot)
        let fMedical = ensureFolder(context: context, name: "У врача", icon: "cross.case", sortOrder: 2, parent: moveRoot)

        seedExtra(context: context, name: "Аренда: термины", folder: fRental, entries: EnglishLifeDecks.rental)
        seedExtra(context: context, name: "Банк: счета, переводы, кредиты", folder: fBanking, entries: EnglishLifeDecks.banking)
        seedExtra(context: context, name: "Медицина: визит, симптомы", folder: fMedical, entries: EnglishLifeDecks.medical)

        // === Разное (внутри English) ===
        let miscRoot = ensureFolder(context: context, name: "🎨 Разное", icon: "sparkles", sortOrder: 9, parent: english)
        let fAnimals = ensureFolder(context: context, name: "Животные", icon: "pawprint", sortOrder: 0, parent: miscRoot)
        let fClothing = ensureFolder(context: context, name: "Одежда", icon: "tshirt", sortOrder: 1, parent: miscRoot)
        let fAppearance = ensureFolder(context: context, name: "Внешность и характер", icon: "person.crop.circle", sortOrder: 2, parent: miscRoot)
        let fTools = ensureFolder(context: context, name: "Инструменты / DIY", icon: "wrench.and.screwdriver", sortOrder: 3, parent: miscRoot)
        let fColors = ensureFolder(context: context, name: "Цвета (оттенки)", icon: "paintpalette", sortOrder: 4, parent: miscRoot)
        let fCars = ensureFolder(context: context, name: "Авто", icon: "car", sortOrder: 5, parent: miscRoot)
        let fSports = ensureFolder(context: context, name: "Спорт и фитнес", icon: "figure.run", sortOrder: 6, parent: miscRoot)

        seedExtra(context: context, name: "Животные (advanced)", folder: fAnimals, entries: EnglishLifeDecks.animals)
        seedExtra(context: context, name: "Одежда и ткани", folder: fClothing, entries: EnglishLifeDecks.clothing)
        seedExtra(context: context, name: "Внешность и характер", folder: fAppearance, entries: EnglishLifeDecks.appearance)
        seedExtra(context: context, name: "Инструменты и DIY", folder: fTools, entries: EnglishLifeDecks.tools)
        seedExtra(context: context, name: "Цвета — оттенки", folder: fColors, entries: EnglishLifeDecks.colors)
        seedExtra(context: context, name: "Авто: детали и вождение", folder: fCars, entries: EnglishLifeDecks.cars)
        seedExtra(context: context, name: "Спорт и фитнес", folder: fSports, entries: EnglishLifeDecks.sports)

        try? context.save()
    }

    // MARK: - Helpers

    // Переносит папку с верхнего уровня внутрь English (одноразовая миграция)
    private static func migrateRootFolderUnderEnglish(context: ModelContext, folderName: String, english: Folder) {
        let all = (try? context.fetch(FetchDescriptor<Folder>())) ?? []
        if let rootFolder = all.first(where: { $0.name == folderName && $0.parent == nil }) {
            rootFolder.parent = english
        }
    }

    private static func ensureFolder(
        context: ModelContext,
        name: String,
        icon: String,
        sortOrder: Int,
        parent: Folder?
    ) -> Folder {
        let existing = (try? context.fetch(FetchDescriptor<Folder>())) ?? []
        if let found = existing.first(where: { $0.name == name && $0.parent?.id == parent?.id }) {
            return found
        }
        let f = Folder(name: name, icon: icon, sortOrder: sortOrder, parent: parent)
        context.insert(f)
        return f
    }

    private static func classify(
        deck: Deck,
        enWords: Folder,
        jaKana: Folder, jaN5: Folder,
        englishFallback: Folder, japaneseFallback: Folder
    ) -> Folder {
        let name = deck.name
        // Японские
        if deck.mode == .japanese || deck.frontLanguage.hasPrefix("ja") {
            if name.lowercased().contains("хираган") || name.lowercased().contains("катакан") {
                return jaKana
            }
            return jaN5
        }
        // Английские
        if name.lowercased().contains("it / sre") || name.lowercased().contains("it/sre") {
            return englishFallback  // уже отдельная папка создана
        }
        // Дефолтные из Obsidian
        return enWords
    }

    private static func seedExtra(
        context: ModelContext,
        name: String,
        folder: Folder,
        entries: [(front: String, back: String, example: String)]
    ) {
        let existing = (try? context.fetch(FetchDescriptor<Deck>())) ?? []
        if existing.contains(where: { $0.name == name }) { return }

        let deck = Deck(
            name: name,
            description: "",
            mode: .classic,
            frontLanguage: "en-US",
            backLanguage: "ru-RU"
        )
        deck.folder = folder
        context.insert(deck)
        for e in entries {
            let card = Card(deck: deck, front: e.front, back: e.back, example: e.example)
            deck.cards.append(card)
            context.insert(card)
        }
    }
}
