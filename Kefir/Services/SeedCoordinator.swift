import Foundation
import SwiftData

/// Единая точка синхронизации ВСТРОЕННОГО контента (колоды-сиды).
///
/// Проблема, которую решает:
/// раньше японские/английские базовые колоды добавлялись только когда база
/// ПУСТАЯ (`JapaneseSeedData.seedIfEmpty`), а тематические — по отдельному
/// счётчику папок. Поэтому на уже установленном приложении новые встроенные
/// колоды сами не появлялись — их можно было добрать только вручную из Настроек.
///
/// Теперь при каждом запуске, если версия встроенного контента выросла, мы
/// до-засеиваем недостающее. Все функции-сиды идемпотентны по ИМЕНИ колоды и
/// только ДОБАВЛЯЮТ — пользовательские колоды, карточки, избранное и прогресс
/// SRS не трогаются и не удаляются.
struct SeedCoordinator {
    /// Версия встроенного набора колод.
    ///
    /// ВАЖНО: увеличивать на +1 каждый раз, когда добавляешь новые встроенные
    /// колоды/карточки (в JapaneseSeedData, EnglishSeedData/JSON, EnglishExtraDecks,
    /// EnglishLifeDecks). Тогда они доедут до уже установленных приложений при
    /// следующем запуске — без переустановки и без потери прогресса.
    ///
    /// История версий — см. CHANGELOG.md.
    static let contentVersion = 6
    private static let versionKey = "content_seed_version"

    /// Запускается на старте приложения. До-засеивает встроенный контент, если он
    /// обновился (или это первый запуск). Безопасно для существующих данных —
    /// только вставка недостающего по имени, удалений нет.
    static func syncIfNeeded(context: ModelContext) {
        let saved = UserDefaults.standard.integer(forKey: versionKey)
        guard saved < contentVersion else { return }
        applyAll(context: context)
    }

    /// Принудительная полная синхронизация (кнопка «Загрузить встроенные колоды»
    /// в Настройках). Возвращает текст-итог для алерта.
    @discardableResult
    static func forceSync(context: ModelContext) -> String {
        applyAll(context: context)
    }

    /// Прогоняет все сиды по очереди. Каждый из них сам пропускает уже
    /// существующие колоды (по имени), поэтому повторный вызов безопасен.
    @discardableResult
    private static func applyAll(context: ModelContext) -> String {
        let before = deckCount(context: context)

        // 1. Японский: база JLPT N5 + кана.
        JapaneseSeedData.seedAll(context: context)
        // 2. Английский словарь из bundled JSON (~1500 карточек).
        let enMsg = EnglishSeedData.seed(context: context)
        // 3. Португальский и испанский: базовые колоды с русской транскрипцией.
        //    (folder проставляется внутри — FolderOrganizer их не трогает.)
        PortugueseSeedData.seedAll(context: context)
        SpanishSeedData.seedAll(context: context)
        // 4. Папки + тематические английские колоды (IT/SRE, Travel, Жизнь и быт…).
        FolderOrganizer.ensureFoldersAndSeed(context: context)

        try? context.save()

        // Помечаем обе версии как актуальные, чтобы повторно не гонять на каждом старте.
        UserDefaults.standard.set(contentVersion, forKey: versionKey)
        UserDefaults.standard.set(FolderOrganizer.seedVersion, forKey: "folders_seed_version")

        let added = deckCount(context: context) - before
        return added > 0
            ? "✅ Встроенные колоды синхронизированы. Добавлено новых: \(added). Прогресс и ваши колоды не тронуты."
            : "✅ Всё уже на месте — новых встроенных колод нет. Прогресс не тронут. \(enMsg)"
    }

    private static func deckCount(context: ModelContext) -> Int {
        (try? context.fetchCount(FetchDescriptor<Deck>())) ?? 0
    }
}
