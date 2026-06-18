import Foundation
import SwiftData

// Встроенные колоды испанского.
// Classic-режим: front = испанский, back = русский, example = [транскрипция].
// Идемпотентно по имени колоды. Складывает колоды в папку «🇪🇸 Испанский».
struct SpanishSeedData {

    static func seedAll(context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Deck>())) ?? []
        var existingNames = Set(existing.map { $0.name })
        let folder = ensureFolder(context: context, name: "🇪🇸 Испанский", icon: "e.circle", sortOrder: 3, parent: nil)

        // Базовые колоды — в корне языковой папки.
        for (name, desc, entries) in decks {
            insertDeck(context: context, name: name, desc: desc, entries: entries, folder: folder, existingNames: &existingNames)
        }

        // Тематические колоды — по подпапкам.
        seedThemes(context: context, lang: folder, existingNames: &existingNames)
    }

    static func insertDeck(
        context: ModelContext,
        name: String,
        desc: String,
        entries: [(String, String, String)],
        folder: Folder,
        existingNames: inout Set<String>
    ) {
        if existingNames.contains(name) { return }
        existingNames.insert(name)
        let deck = Deck(name: name, description: desc, mode: .classic, frontLanguage: "es-ES", backLanguage: "ru-RU")
        deck.folder = folder
        context.insert(deck)
        for (front, back, tr) in entries {
            let card = Card(deck: deck, front: front, back: back, example: tr.isEmpty ? "" : "[\(tr)]")
            deck.cards.append(card)
            context.insert(card)
        }
    }

    static func ensureFolder(context: ModelContext, name: String, icon: String, sortOrder: Int, parent: Folder?) -> Folder {
        let all = (try? context.fetch(FetchDescriptor<Folder>())) ?? []
        if let found = all.first(where: { $0.name == name && $0.parent?.id == parent?.id }) { return found }
        let f = Folder(name: name, icon: icon, sortOrder: sortOrder, parent: parent)
        context.insert(f)
        return f
    }

    static let decks: [(String, String, [(String, String, String)])] = [
        ("ES — Алфавит и звуки", "Особые буквы и сочетания", alphabet),
        ("ES — Базовые фразы", "Приветствия, вежливость", phrases),
        ("ES — Числа", "0–1000", numbers),
        ("ES — Глаголы (база)", "Самые частые глаголы", verbs),
        ("ES — Существительные", "Базовые слова", nouns),
        ("ES — Прилагательные", "Базовые признаки", adjectives)
    ]

    static let alphabet: [(String, String, String)] = [
        ("ñ", "звук «нь»", "нь"),
        ("ll", "звук «й»", "й"),
        ("j", "резкое «х»", "х"),
        ("h", "не читается", "—"),
        ("z", "звук «с»", "с"),
        ("v", "звук «б»", "б"),
        ("rr", "раскатистое «р»", "р-р"),
        ("ch", "звук «ч»", "ч"),
        ("español", "испанский", "эспаньóль"),
        ("llamar", "звать", "ямáр"),
        ("jamón", "хамон (ветчина)", "хамóн"),
        ("hola", "привет", "óла"),
        ("zapato", "ботинок", "сапáто"),
        ("vino", "вино", "бúно"),
        ("perro", "собака", "пéрро")
    ]

    static let phrases: [(String, String, String)] = [
        ("Hola", "привет", "óла"),
        ("Buenos días", "доброе утро", "буэ́нос дúас"),
        ("Buenas tardes", "добрый день", "буэ́нас тáрдес"),
        ("Buenas noches", "добрый вечер / ночи", "буэ́нас нóчес"),
        ("Gracias", "спасибо", "грáсиас"),
        ("Muchas gracias", "большое спасибо", "мýчас грáсиас"),
        ("Por favor", "пожалуйста (просьба)", "пор фавóр"),
        ("De nada", "не за что", "дэ нáда"),
        ("Perdón", "извините", "пэрдóн"),
        ("Lo siento", "мне жаль / простите", "ло сьéнто"),
        ("¿Qué tal?", "как дела?", "кэ таль"),
        ("Muy bien", "очень хорошо", "муй бьен"),
        ("Sí", "да", "си"),
        ("No", "нет", "но"),
        ("No entiendo", "не понимаю", "но энтьéндо"),
        ("No sé", "не знаю", "но сэ"),
        ("¿Cuánto cuesta?", "сколько стоит?", "куáнто куэ́ста"),
        ("¿Dónde está?", "где находится?", "дóнде эстá"),
        ("¿Qué hora es?", "который час?", "кэ óра эс"),
        ("¿Habla inglés?", "вы говорите по-английски?", "áбла инглéс"),
        ("Me llamo...", "меня зовут...", "мэ йáмо"),
        ("Mucho gusto", "приятно познакомиться", "мýчо гýсто"),
        ("Adiós", "пока", "адьóс"),
        ("Hasta luego", "до встречи", "áста луэ́го"),
        ("Salud", "будь здоров / за здоровье", "салýд")
    ]

    static let numbers: [(String, String, String)] = [
        ("cero", "0", "сэ́ро"),
        ("uno", "1", "ýно"),
        ("dos", "2", "дос"),
        ("tres", "3", "трэс"),
        ("cuatro", "4", "куáтро"),
        ("cinco", "5", "сúнко"),
        ("seis", "6", "сэйс"),
        ("siete", "7", "сьéте"),
        ("ocho", "8", "óчо"),
        ("nueve", "9", "нуэ́бе"),
        ("diez", "10", "дьес"),
        ("once", "11", "óнсе"),
        ("doce", "12", "дóсе"),
        ("veinte", "20", "бэ́йнте"),
        ("treinta", "30", "трэ́йнта"),
        ("cincuenta", "50", "синкуэ́нта"),
        ("cien", "100", "сьен"),
        ("mil", "1000", "миль")
    ]

    static let verbs: [(String, String, String)] = [
        ("ser", "быть (постоянно)", "сэр"),
        ("estar", "быть (сейчас) / находиться", "эстáр"),
        ("tener", "иметь", "тэнэ́р"),
        ("ir", "идти / ехать", "ир"),
        ("hacer", "делать", "асэ́р"),
        ("hablar", "говорить", "аблáр"),
        ("comer", "есть (пищу)", "комэ́р"),
        ("beber", "пить", "бебэ́р"),
        ("querer", "хотеть / любить", "керэ́р"),
        ("poder", "мочь", "подэ́р"),
        ("ver", "видеть", "бэр"),
        ("saber", "знать", "сабэ́р"),
        ("decir", "сказать", "десúр"),
        ("dar", "давать", "дар"),
        ("gustar", "нравиться", "густáр"),
        ("vivir", "жить", "бибúр"),
        ("trabajar", "работать", "трабахáр"),
        ("comprar", "покупать", "компрáр"),
        ("entender", "понимать", "энтендэ́р"),
        ("aprender", "учить / учиться", "апрендэ́р"),
        ("abrir", "открывать", "абрúр"),
        ("llegar", "прибывать", "йегáр"),
        ("necesitar", "нуждаться", "несеситáр"),
        ("ayudar", "помогать", "айудáр")
    ]

    static let nouns: [(String, String, String)] = [
        ("el agua", "вода", "эль áгуа"),
        ("el café", "кофе", "эль кафэ́"),
        ("el pan", "хлеб", "эль пан"),
        ("la comida", "еда", "ла комúда"),
        ("la casa", "дом", "ла кáса"),
        ("el coche", "машина", "эль кóче"),
        ("la calle", "улица", "ла кáйе"),
        ("la ciudad", "город", "ла сьюдáд"),
        ("el trabajo", "работа", "эль трабáхо"),
        ("el dinero", "деньги", "эль динэ́ро"),
        ("la tienda", "магазин", "ла тьéнда"),
        ("el día", "день", "эль дúа"),
        ("la noche", "ночь / вечер", "ла нóче"),
        ("la hora", "час / время", "ла óра"),
        ("el amigo", "друг", "эль амúго"),
        ("la familia", "семья", "ла фамúлиа"),
        ("el nombre", "имя", "эль нóмбре"),
        ("el hombre", "мужчина", "эль óмбре"),
        ("la mujer", "женщина", "ла мухэ́р"),
        ("el niño", "ребёнок", "эль нúньо"),
        ("la habitación", "комната", "ла абитасьóн"),
        ("la llave", "ключ", "ла йáбе"),
        ("el teléfono", "телефон", "эль телэ́фоно"),
        ("el agua caliente", "горячая вода", "эль áгуа кальéнте")
    ]

    static let adjectives: [(String, String, String)] = [
        ("bueno", "хороший", "буэ́но"),
        ("malo", "плохой", "мáло"),
        ("grande", "большой", "грáнде"),
        ("pequeño", "маленький", "пекэ́ньо"),
        ("nuevo", "новый", "нуэ́бо"),
        ("viejo", "старый", "бьéхо"),
        ("caro", "дорогой", "кáро"),
        ("barato", "дешёвый", "барáто"),
        ("bonito", "красивый", "бонúто"),
        ("feo", "некрасивый", "фэ́о"),
        ("caliente", "горячий / тёплый", "кальéнте"),
        ("frío", "холодный", "фрúо"),
        ("fácil", "лёгкий", "фáсиль"),
        ("difícil", "трудный", "дифúсиль"),
        ("rápido", "быстрый", "хáпидо"),
        ("lento", "медленный", "лэ́нто"),
        ("feliz", "счастливый", "фелúс"),
        ("cansado", "усталый", "кансáдо"),
        ("correcto", "правильный", "коррэ́кто"),
        ("abierto", "открытый", "абьéрто")
    ]
}
