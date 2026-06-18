import Foundation
import SwiftData

// Тематические колоды португальского, разложенные по подпапкам.
// Все карточки: front = португальский, back = русский, example = [транскрипция].
extension PortugueseSeedData {

    static func seedThemes(context: ModelContext, lang: Folder, existingNames: inout Set<String>) {
        let travel  = ensureFolder(context: context, name: "Путешествия", icon: "suitcase", sortOrder: 0, parent: lang)
        let money   = ensureFolder(context: context, name: "Покупки и деньги", icon: "creditcard", sortOrder: 1, parent: lang)
        let health  = ensureFolder(context: context, name: "Здоровье", icon: "cross.case", sortOrder: 2, parent: lang)
        let home    = ensureFolder(context: context, name: "Жильё и быт", icon: "house", sortOrder: 3, parent: lang)

        insertDeck(context: context, name: "PT — Аэропорт и транспорт", desc: "Перелёт, транспорт", entries: airport, folder: travel, existingNames: &existingNames)
        insertDeck(context: context, name: "PT — Отель", desc: "Заселение, номер", entries: hotel, folder: travel, existingNames: &existingNames)
        insertDeck(context: context, name: "PT — Ресторан и еда", desc: "Заказ, блюда", entries: restaurant, folder: travel, existingNames: &existingNames)
        insertDeck(context: context, name: "PT — Город и направления", desc: "Как пройти", entries: directions, folder: travel, existingNames: &existingNames)

        insertDeck(context: context, name: "PT — Магазин и покупки", desc: "Цены, касса", entries: shopping, folder: money, existingNames: &existingNames)
        insertDeck(context: context, name: "PT — Деньги и банк", desc: "Оплата, банк", entries: banking, folder: money, existingNames: &existingNames)

        insertDeck(context: context, name: "PT — У врача и тело", desc: "Симптомы, части тела", entries: doctor, folder: health, existingNames: &existingNames)
        insertDeck(context: context, name: "PT — Аптека", desc: "Лекарства", entries: pharmacy, folder: health, existingNames: &existingNames)

        insertDeck(context: context, name: "PT — Дом и аренда", desc: "Жильё, комнаты", entries: housing, folder: home, existingNames: &existingNames)
        insertDeck(context: context, name: "PT — Погода и время", desc: "Дни, погода", entries: weatherTime, folder: home, existingNames: &existingNames)
    }

    static let airport: [(String, String, String)] = [
        ("o aeroporto", "аэропорт", "у аэропóрту"),
        ("o voo", "рейс", "у вóу"),
        ("a passagem", "билет", "а пасáжен"),
        ("o passaporte", "паспорт", "у пасапóрчи"),
        ("a bagagem", "багаж", "а багáжен"),
        ("o embarque", "посадка", "у эмбáрки"),
        ("o portão", "выход на посадку", "у портáу"),
        ("a alfândega", "таможня", "а алфáндега"),
        ("o táxi", "такси", "у тáкси"),
        ("o ônibus", "автобус", "у óнибус"),
        ("o metrô", "метро", "у метрó"),
        ("o trem", "поезд", "у трэн"),
        ("a estação", "станция", "а эстасáу"),
        ("atrasado", "задержан / опоздавший", "атразáду"),
        ("a saída", "выход", "а саúда"),
        ("Onde fica o banheiro?", "где туалет?", "óнджи фúка у баньéйру")
    ]

    static let hotel: [(String, String, String)] = [
        ("o hotel", "отель", "у отэ́л"),
        ("a reserva", "бронь", "а хезéрва"),
        ("o quarto", "номер / комната", "у куáрту"),
        ("a chave", "ключ", "а шáви"),
        ("a cama", "кровать", "а кáма"),
        ("o chuveiro", "душ", "у шувéйру"),
        ("a toalha", "полотенце", "а тоáлья"),
        ("o café da manhã", "завтрак", "у кафэ́ да маньáн"),
        ("a diária", "цена за ночь", "а джиáриа"),
        ("Tem wi-fi?", "есть ли вайфай?", "тэн уáйфай"),
        ("limpo", "чистый", "лúмпу"),
        ("sujo", "грязный", "сýжу"),
        ("a recepção", "ресепшен", "а хесепсáу"),
        ("Tenho uma reserva", "у меня бронь", "тэ́нью ýма хезéрва")
    ]

    static let restaurant: [(String, String, String)] = [
        ("o restaurante", "ресторан", "у хестаурáнчи"),
        ("o cardápio", "меню", "у кардáпиу"),
        ("a conta", "счёт", "а кóнта"),
        ("a água", "вода", "а áгуа"),
        ("a cerveja", "пиво", "а сервéжа"),
        ("o vinho", "вино", "у вúнью"),
        ("o prato", "блюдо / тарелка", "у прáту"),
        ("a carne", "мясо", "а кáрни"),
        ("o frango", "курица", "у фрáнгу"),
        ("o peixe", "рыба", "у пéйши"),
        ("a salada", "салат", "а салáда"),
        ("a sobremesa", "десерт", "а собремéза"),
        ("gostoso", "вкусный", "гостóзу"),
        ("a gorjeta", "чаевые", "а горжéта"),
        ("Eu queria...", "я бы хотел...", "эу керúа"),
        ("A conta, por favor", "счёт, пожалуйста", "а кóнта пур фавóр")
    ]

    static let directions: [(String, String, String)] = [
        ("a rua", "улица", "а хýа"),
        ("a praça", "площадь", "а прáса"),
        ("à direita", "направо", "а джирéйта"),
        ("à esquerda", "налево", "а искéрда"),
        ("em frente", "прямо", "эн фрэ́нчи"),
        ("perto", "близко", "пéрту"),
        ("longe", "далеко", "лóнжи"),
        ("aqui", "здесь", "акú"),
        ("ali", "там", "алú"),
        ("o mapa", "карта", "у мáпа"),
        ("a esquina", "угол (улицы)", "а искúна"),
        ("o centro", "центр", "у сэ́нтру"),
        ("a ponte", "мост", "а пóнчи"),
        ("Como chego a...?", "как добраться до...?", "кóму шéгу а")
    ]

    static let shopping: [(String, String, String)] = [
        ("a loja", "магазин", "а лóжа"),
        ("o mercado", "рынок / супермаркет", "у меркáду"),
        ("o preço", "цена", "у прéсу"),
        ("caro", "дорогой", "кáру"),
        ("barato", "дешёвый", "барáту"),
        ("o troco", "сдача", "у трóку"),
        ("a promoção", "скидка / акция", "а промосáу"),
        ("o tamanho", "размер", "у таманью"),
        ("provar", "примерить", "провáр"),
        ("o caixa", "касса", "у кáйша"),
        ("a sacola", "пакет", "а сакóла"),
        ("Quanto é?", "сколько стоит?", "куáнту э"),
        ("Aceita cartão?", "карты принимаете?", "асéйта картáу"),
        ("Só estou olhando", "я просто смотрю", "со эстó олльáнду")
    ]

    static let banking: [(String, String, String)] = [
        ("o dinheiro", "деньги", "у диньéйру"),
        ("o cartão", "карта", "у картáу"),
        ("o banco", "банк", "у бáнку"),
        ("a conta", "счёт", "а кóнта"),
        ("o caixa eletrônico", "банкомат", "у кáйша элетрóнику"),
        ("o saque", "снятие наличных", "у сáки"),
        ("a transferência", "перевод", "а трансферэ́нсиа"),
        ("o boleto", "квитанция на оплату", "у болéту"),
        ("o pix", "мгновенный перевод (Бразилия)", "пикс"),
        ("a taxa", "комиссия / сбор", "а тáша"),
        ("pagar", "платить", "пагáр"),
        ("o recibo", "чек / квитанция", "у хесúбу"),
        ("o real", "реал (валюта)", "у хеáл"),
        ("Posso pagar com cartão?", "можно картой?", "пóсу пагáр кон картáу")
    ]

    static let doctor: [(String, String, String)] = [
        ("o médico", "врач", "у мэ́джику"),
        ("a dor", "боль", "а дор"),
        ("a cabeça", "голова", "а кабéса"),
        ("o estômago", "живот / желудок", "у эстóмагу"),
        ("a garganta", "горло", "а гаргáнта"),
        ("a febre", "жар / температура", "а фéбри"),
        ("doente", "больной", "доэ́нчи"),
        ("a mão", "кисть руки", "а мáу"),
        ("o braço", "рука", "у брáсу"),
        ("a perna", "нога", "а пéрна"),
        ("o pé", "стопа", "у пэ"),
        ("as costas", "спина", "ас кóстас"),
        ("o coração", "сердце", "у корасáу"),
        ("o hospital", "больница", "у оспитáл"),
        ("Estou doente", "я болен", "эстó доэ́нчи"),
        ("Estou com dor aqui", "у меня болит здесь", "эстó кон дор акú")
    ]

    static let pharmacy: [(String, String, String)] = [
        ("a farmácia", "аптека", "а фармáсиа"),
        ("o remédio", "лекарство", "у хемэ́джиу"),
        ("a receita", "рецепт", "а хесéйта"),
        ("a dor de cabeça", "головная боль", "а дор джи кабéса"),
        ("a tosse", "кашель", "а тóси"),
        ("a gripe", "простуда / грипп", "а грúпи"),
        ("o curativo", "пластырь", "у куратúву"),
        ("a vitamina", "витамин", "а витамúна"),
        ("o analgésico", "обезболивающее", "у аналжэ́зику"),
        ("a alergia", "аллергия", "а алержúа"),
        ("Preciso de...", "мне нужно...", "пресúзу джи"),
        ("Tem algo para dor?", "есть что-то от боли?", "тэн áлгу пара дор")
    ]

    static let housing: [(String, String, String)] = [
        ("a casa", "дом", "а кáза"),
        ("o apartamento", "квартира", "у апартамэ́нту"),
        ("o aluguel", "аренда", "у алугэ́л"),
        ("o contrato", "договор", "у контрáту"),
        ("a cozinha", "кухня", "а козúнья"),
        ("o banheiro", "ванная / туалет", "у баньéйру"),
        ("a sala", "гостиная", "а сáла"),
        ("o quarto", "спальня / комната", "у куáрту"),
        ("a janela", "окно", "а жанéла"),
        ("a porta", "дверь", "а пóрта"),
        ("a luz", "свет / электричество", "а луз"),
        ("o lixo", "мусор", "у лúшу"),
        ("mobiliado", "меблированный", "мобилиáду"),
        ("o vizinho", "сосед", "у визúнью")
    ]

    static let weatherTime: [(String, String, String)] = [
        ("o tempo", "погода / время", "у тэ́мпу"),
        ("o sol", "солнце", "у сол"),
        ("a chuva", "дождь", "а шýва"),
        ("o vento", "ветер", "у вэ́нту"),
        ("quente", "жарко", "кэ́нчи"),
        ("frio", "холодно", "фрúу"),
        ("hoje", "сегодня", "óжи"),
        ("amanhã", "завтра", "аманьáн"),
        ("ontem", "вчера", "óнтэн"),
        ("agora", "сейчас", "агóра"),
        ("a semana", "неделя", "а семáна"),
        ("o mês", "месяц", "у мэс"),
        ("o ano", "год", "у áну"),
        ("cedo", "рано", "сéду"),
        ("tarde", "поздно", "тáрджи")
    ]
}
