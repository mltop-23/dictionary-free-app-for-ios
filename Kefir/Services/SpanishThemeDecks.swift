import Foundation
import SwiftData

// Тематические колоды испанского, разложенные по подпапкам.
// Все карточки: front = испанский, back = русский, example = [транскрипция].
extension SpanishSeedData {

    static func seedThemes(context: ModelContext, lang: Folder, existingNames: inout Set<String>) {
        let travel = ensureFolder(context: context, name: "Путешествия", icon: "suitcase", sortOrder: 0, parent: lang)
        let money  = ensureFolder(context: context, name: "Покупки и деньги", icon: "creditcard", sortOrder: 1, parent: lang)
        let health = ensureFolder(context: context, name: "Здоровье", icon: "cross.case", sortOrder: 2, parent: lang)
        let home   = ensureFolder(context: context, name: "Жильё и быт", icon: "house", sortOrder: 3, parent: lang)

        insertDeck(context: context, name: "ES — Аэропорт и транспорт", desc: "Перелёт, транспорт", entries: airport, folder: travel, existingNames: &existingNames)
        insertDeck(context: context, name: "ES — Отель", desc: "Заселение, номер", entries: hotel, folder: travel, existingNames: &existingNames)
        insertDeck(context: context, name: "ES — Ресторан и еда", desc: "Заказ, блюда", entries: restaurant, folder: travel, existingNames: &existingNames)
        insertDeck(context: context, name: "ES — Город и направления", desc: "Как пройти", entries: directions, folder: travel, existingNames: &existingNames)

        insertDeck(context: context, name: "ES — Магазин и покупки", desc: "Цены, касса", entries: shopping, folder: money, existingNames: &existingNames)
        insertDeck(context: context, name: "ES — Деньги и банк", desc: "Оплата, банк", entries: banking, folder: money, existingNames: &existingNames)

        insertDeck(context: context, name: "ES — У врача и тело", desc: "Симптомы, части тела", entries: doctor, folder: health, existingNames: &existingNames)
        insertDeck(context: context, name: "ES — Аптека", desc: "Лекарства", entries: pharmacy, folder: health, existingNames: &existingNames)

        insertDeck(context: context, name: "ES — Дом и аренда", desc: "Жильё, комнаты", entries: housing, folder: home, existingNames: &existingNames)
        insertDeck(context: context, name: "ES — Погода и время", desc: "Дни, погода", entries: weatherTime, folder: home, existingNames: &existingNames)
    }

    static let airport: [(String, String, String)] = [
        ("el aeropuerto", "аэропорт", "эль аэропуэ́рто"),
        ("el vuelo", "рейс", "эль буэ́ло"),
        ("el billete", "билет", "эль бийéте"),
        ("el pasaporte", "паспорт", "эль пасапóрте"),
        ("el equipaje", "багаж", "эль экипáхе"),
        ("la puerta", "выход на посадку", "ла пуэ́рта"),
        ("la aduana", "таможня", "ла адуáна"),
        ("el taxi", "такси", "эль тáкси"),
        ("el autobús", "автобус", "эль аутобýс"),
        ("el metro", "метро", "эль мэ́тро"),
        ("el tren", "поезд", "эль трэн"),
        ("la estación", "станция", "ла эстасьóн"),
        ("retrasado", "задержан", "рэтрасáдо"),
        ("la salida", "выход", "ла салúда"),
        ("la entrada", "вход", "ла энтрáда"),
        ("¿Dónde está el baño?", "где туалет?", "дóнде эстá эль бáньо")
    ]

    static let hotel: [(String, String, String)] = [
        ("el hotel", "отель", "эль отэ́ль"),
        ("la reserva", "бронь", "ла рэсэ́рба"),
        ("la habitación", "номер / комната", "ла абитасьóн"),
        ("la llave", "ключ", "ла йáбе"),
        ("la cama", "кровать", "ла кáма"),
        ("la ducha", "душ", "ла дýча"),
        ("la toalla", "полотенце", "ла тоáйя"),
        ("el desayuno", "завтрак", "эль десайýно"),
        ("¿Hay wifi?", "есть ли вайфай?", "ай уúфи"),
        ("limpio", "чистый", "лúмпио"),
        ("sucio", "грязный", "сýсио"),
        ("la recepción", "ресепшен", "ла рэсэпсьóн"),
        ("Tengo una reserva", "у меня бронь", "тэ́нго ýна рэсэ́рба")
    ]

    static let restaurant: [(String, String, String)] = [
        ("el restaurante", "ресторан", "эль рэстаурáнте"),
        ("el menú", "меню", "эль менý"),
        ("la cuenta", "счёт", "ла куэ́нта"),
        ("el agua", "вода", "эль áгуа"),
        ("la cerveza", "пиво", "ла сэрбэ́са"),
        ("el vino", "вино", "эль бúно"),
        ("el plato", "блюдо / тарелка", "эль плáто"),
        ("la carne", "мясо", "ла кáрне"),
        ("el pollo", "курица", "эль пóйо"),
        ("el pescado", "рыба", "эль пэскáдо"),
        ("la ensalada", "салат", "ла энсалáда"),
        ("el postre", "десерт", "эль пóстре"),
        ("rico", "вкусный", "рúко"),
        ("la propina", "чаевые", "ла пропúна"),
        ("Quería...", "я бы хотел...", "керúа"),
        ("La cuenta, por favor", "счёт, пожалуйста", "ла куэ́нта пор фавóр")
    ]

    static let directions: [(String, String, String)] = [
        ("la calle", "улица", "ла кáйе"),
        ("la plaza", "площадь", "ла плáса"),
        ("a la derecha", "направо", "а ла дэрэ́ча"),
        ("a la izquierda", "налево", "а ла искьéрда"),
        ("todo recto", "прямо", "тóдо рэ́кто"),
        ("cerca", "близко", "сэ́рка"),
        ("lejos", "далеко", "лэ́хос"),
        ("aquí", "здесь", "акú"),
        ("allí", "там", "айú"),
        ("el mapa", "карта", "эль мáпа"),
        ("la esquina", "угол (улицы)", "ла эскúна"),
        ("el centro", "центр", "эль сэ́нтро"),
        ("el puente", "мост", "эль пуэ́нте"),
        ("¿Cómo llego a...?", "как добраться до...?", "кóмо йéго а")
    ]

    static let shopping: [(String, String, String)] = [
        ("la tienda", "магазин", "ла тьéнда"),
        ("el mercado", "рынок / супермаркет", "эль мэркáдо"),
        ("el precio", "цена", "эль прэ́сио"),
        ("caro", "дорогой", "кáро"),
        ("barato", "дешёвый", "барáто"),
        ("el cambio", "сдача", "эль кáмбио"),
        ("la oferta", "скидка / акция", "ла офэ́рта"),
        ("la talla", "размер", "ла тáйя"),
        ("probar", "примерить", "пробáр"),
        ("la caja", "касса", "ла кáха"),
        ("la bolsa", "пакет", "ла бóлса"),
        ("¿Cuánto vale?", "сколько стоит?", "куáнто бáле"),
        ("¿Aceptan tarjeta?", "карты принимаете?", "асэ́птан тархэ́та"),
        ("Solo estoy mirando", "я просто смотрю", "сóло эстóй мирáндо")
    ]

    static let banking: [(String, String, String)] = [
        ("el dinero", "деньги", "эль динэ́ро"),
        ("la tarjeta", "карта", "ла тархэ́та"),
        ("el banco", "банк", "эль бáнко"),
        ("la cuenta", "счёт", "ла куэ́нта"),
        ("el cajero", "банкомат", "эль кахэ́ро"),
        ("la transferencia", "перевод", "ла трансфэрэ́нсиа"),
        ("el efectivo", "наличные", "эль эфэктúбо"),
        ("la comisión", "комиссия", "ла комисьóн"),
        ("pagar", "платить", "пагáр"),
        ("el recibo", "чек / квитанция", "эль рэсúбо"),
        ("el euro", "евро", "эль эýро"),
        ("¿Puedo pagar con tarjeta?", "можно картой?", "пуэ́до пагáр кон тархэ́та")
    ]

    static let doctor: [(String, String, String)] = [
        ("el médico", "врач", "эль мэ́дико"),
        ("el dolor", "боль", "эль долóр"),
        ("la cabeza", "голова", "ла кабэ́са"),
        ("el estómago", "живот / желудок", "эль эстóмаго"),
        ("la garganta", "горло", "ла гаргáнта"),
        ("la fiebre", "жар / температура", "ла фьéбре"),
        ("enfermo", "больной", "энфэ́рмо"),
        ("la mano", "кисть руки", "ла мáно"),
        ("el brazo", "рука", "эль брáсо"),
        ("la pierna", "нога", "ла пьéрна"),
        ("el pie", "стопа", "эль пьэ"),
        ("la espalda", "спина", "ла эспáлда"),
        ("el corazón", "сердце", "эль корасóн"),
        ("el hospital", "больница", "эль оспитáль"),
        ("Estoy enfermo", "я болен", "эстóй энфэ́рмо"),
        ("Me duele aquí", "у меня болит здесь", "мэ дуэ́ле акú")
    ]

    static let pharmacy: [(String, String, String)] = [
        ("la farmacia", "аптека", "ла фармáсиа"),
        ("el medicamento", "лекарство", "эль медикамэ́нто"),
        ("la receta", "рецепт", "ла рэсэ́та"),
        ("el dolor de cabeza", "головная боль", "долóр дэ кабэ́са"),
        ("la tos", "кашель", "ла тос"),
        ("el resfriado", "простуда", "эль рэсфриáдо"),
        ("la tirita", "пластырь", "ла тирúта"),
        ("la vitamina", "витамин", "ла битамúна"),
        ("el analgésico", "обезболивающее", "эль аналхэ́сико"),
        ("la alergia", "аллергия", "ла алэ́рхиа"),
        ("Necesito...", "мне нужно...", "несесúто"),
        ("¿Tiene algo para el dolor?", "есть что-то от боли?", "тьéне áлго пара эль долóр")
    ]

    static let housing: [(String, String, String)] = [
        ("la casa", "дом", "ла кáса"),
        ("el piso", "квартира", "эль пúсо"),
        ("el alquiler", "аренда", "эль алкилэ́р"),
        ("el contrato", "договор", "эль контрáто"),
        ("la cocina", "кухня", "ла косúна"),
        ("el baño", "ванная / туалет", "эль бáньо"),
        ("el salón", "гостиная", "эль салóн"),
        ("la habitación", "комната", "ла абитасьóн"),
        ("la ventana", "окно", "ла бэнтáна"),
        ("la puerta", "дверь", "ла пуэ́рта"),
        ("la luz", "свет / электричество", "ла лус"),
        ("la basura", "мусор", "ла басýра"),
        ("amueblado", "меблированный", "амуэблáдо"),
        ("el vecino", "сосед", "эль бэсúно")
    ]

    static let weatherTime: [(String, String, String)] = [
        ("el tiempo", "погода / время", "эль тьéмпо"),
        ("el sol", "солнце", "эль соль"),
        ("la lluvia", "дождь", "ла йýбиа"),
        ("el viento", "ветер", "эль бьéнто"),
        ("calor", "жарко", "калóр"),
        ("frío", "холодно", "фрúо"),
        ("hoy", "сегодня", "ой"),
        ("mañana", "завтра", "маньяна"),
        ("ayer", "вчера", "айéр"),
        ("ahora", "сейчас", "аóра"),
        ("la semana", "неделя", "ла семáна"),
        ("el mes", "месяц", "эль мэс"),
        ("el año", "год", "эль áньо"),
        ("temprano", "рано", "темпрáно"),
        ("tarde", "поздно", "тáрде")
    ]
}
