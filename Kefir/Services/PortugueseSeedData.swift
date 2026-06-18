import Foundation
import SwiftData

// Встроенные колоды португальского (бразильский вариант).
// Classic-режим: front = португальский, back = русский, example = [транскрипция].
// Идемпотентно по имени колоды. Складывает колоды в папку «🇧🇷 Португальский».
struct PortugueseSeedData {

    static func seedAll(context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Deck>())) ?? []
        var existingNames = Set(existing.map { $0.name })
        let folder = ensureFolder(context: context, name: "🇧🇷 Португальский", icon: "p.circle", sortOrder: 2, parent: nil)

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
        let deck = Deck(name: name, description: desc, mode: .classic, frontLanguage: "pt-BR", backLanguage: "ru-RU")
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

    // (имя колоды, описание, [(front, back, транскрипция)])
    static let decks: [(String, String, [(String, String, String)])] = [
        ("PT — Алфавит", "Все буквы: название, звук, пример", alphabetFull),
        ("PT — Алфавит и звуки", "Правила чтения: особые буквы и сочетания", alphabet),
        ("PT — Фразы с нуля", "Самые простые фразы для начинающих", survival),
        ("PT — Базовые фразы", "Приветствия, вежливость", phrases),
        ("PT — Повседневные фразы", "Частые фразы на каждый день", everyday),
        ("PT — Числа", "0–1000", numbers),
        ("PT — Глаголы (база)", "Самые частые глаголы", verbs),
        ("PT — Существительные", "Базовые слова", nouns),
        ("PT — Прилагательные", "Базовые признаки", adjectives)
    ]

    // Полный алфавит: front = буква, back = название и звук, example = слово-пример.
    static let alphabetFull: [(String, String, String)] = [
        ("A a", "название «á», звук [а]", "amor — любовь"),
        ("B b", "название «bê», звук [б]", "bola — мяч"),
        ("C c", "название «cê», звук [с] / [к]", "casa — дом"),
        ("D d", "название «dê», звук [д] / [дж]", "dia — день"),
        ("E e", "название «é», звук [э] / [и]", "ela — она"),
        ("F f", "название «efe», звук [ф]", "faca — нож"),
        ("G g", "название «gê», звук [г] / [ж]", "gato — кот"),
        ("H h", "название «agá», не читается", "hoje — сегодня"),
        ("I i", "название «i», звук [и]", "ilha — остров"),
        ("J j", "название «jota», звук [ж]", "janela — окно"),
        ("K k", "название «cá», звук [к] (в заимств.)", "kiwi — киви"),
        ("L l", "название «ele», звук [л] / [у]", "lua — луна"),
        ("M m", "название «eme», звук [м]", "mãe — мама"),
        ("N n", "название «ene», звук [н]", "nome — имя"),
        ("O o", "название «ó», звук [о] / [у]", "ovo — яйцо"),
        ("P p", "название «pê», звук [п]", "pão — хлеб"),
        ("Q q", "название «quê», звук [к]", "queijo — сыр"),
        ("R r", "название «erre», звук [р] / [х]", "rua — улица"),
        ("S s", "название «esse», звук [с] / [з]", "sol — солнце"),
        ("T t", "название «tê», звук [т] / [ч]", "tudo — всё"),
        ("U u", "название «u», звук [у]", "uva — виноград"),
        ("V v", "название «vê», звук [в]", "vida — жизнь"),
        ("W w", "название «dáblio», звук [в]/[у] (заимств.)", "windsurf"),
        ("X x", "название «xis», звук [ш]/[з]/[кс]", "xícara — чашка"),
        ("Y y", "название «ípsilon», звук [и]/[й] (заимств.)", "yoga — йога"),
        ("Z z", "название «zê», звук [з]", "zero — ноль")
    ]

    static let everyday: [(String, String, String)] = [
        ("Como você está?", "как ты / как дела?", "кóму восэ эстá"),
        ("Estou bem, e você?", "хорошо, а ты?", "эстó бэн и восэ"),
        ("Tudo certo", "всё в порядке", "тýду сéрту"),
        ("O que é isso?", "что это?", "у ки э úсу"),
        ("Claro", "конечно", "клáру"),
        ("Acho que sim", "думаю, да", "áшу ки син"),
        ("Acho que não", "думаю, нет", "áшу ки нáу"),
        ("Vamos!", "пойдём!", "вáмус"),
        ("Espera", "подожди", "эспéра"),
        ("Estou com fome", "я голоден", "эстó кон фóми"),
        ("Estou com sede", "хочу пить", "эстó кон сéджи"),
        ("Estou cansado", "я устал", "эстó кансáду"),
        ("Que horas são?", "который час?", "ки óрас сáу"),
        ("Hoje", "сегодня", "óжи"),
        ("Amanhã", "завтра", "аманьáн"),
        ("Gosto muito", "мне очень нравится", "гóсту мýйту"),
        ("Não faz mal", "ничего страшного", "нáу фас мал"),
        ("Não tem problema", "нет проблем", "нáу тэн проблéма"),
        ("Com certeza", "точно / конечно", "кон сертéза"),
        ("Mais ou menos", "так себе", "майс о мéнус"),
        ("Boa sorte", "удачи", "боа сóрчи"),
        ("Parabéns", "поздравляю", "парабэ́нс"),
        ("Estou de acordo", "я согласен", "эстó джи акóрду"),
        ("Pode ser", "может быть", "пóджи сэр")
    ]

    static let alphabet: [(String, String, String)] = [
        ("ão", "носовое «ау»", "ау-в-нос"),
        ("ç", "звук «с»", "с"),
        ("ch", "звук «ш»", "ш"),
        ("lh", "мягкое «ль»", "ль"),
        ("nh", "звук «нь»", "нь"),
        ("rr", "хрипящее «х»", "х"),
        ("coração", "сердце", "корасáу"),
        ("praça", "площадь", "прáса"),
        ("chave", "ключ", "шáви"),
        ("filho", "сын", "фúлью"),
        ("vinho", "вино", "вúнью"),
        ("carro", "машина", "кáху"),
        ("casa", "дом", "кáза"),
        ("dia", "день", "джúа"),
        ("leite", "молоко", "лéйчи")
    ]

    static let survival: [(String, String, String)] = [
        ("Eu não falo português", "я не говорю по-португальски", "эу нáу фáлу португэ́с"),
        ("Você fala inglês?", "вы говорите по-английски?", "восэ фáла инглéс"),
        ("Fala russo?", "говорите по-русски?", "фáла хýсу"),
        ("Eu não entendo", "я не понимаю", "эу нáу энтéнду"),
        ("Pode repetir?", "можете повторить?", "пóджи хепетúр"),
        ("Mais devagar, por favor", "медленнее, пожалуйста", "майс девагáр пур фавóр"),
        ("Como se diz...?", "как сказать...?", "кóму си джис"),
        ("O que significa?", "что это значит?", "у ки сигнифúка"),
        ("Eu quero isto", "я хочу это", "эу кéру úсту"),
        ("Eu preciso de ajuda", "мне нужна помощь", "эу пресúзу джи ажýда"),
        ("Você pode me ajudar?", "можете мне помочь?", "восэ пóджи ми ажудáр"),
        ("Onde fica o banheiro?", "где туалет?", "óнджи фúка у баньéйру"),
        ("Quanto custa?", "сколько стоит?", "куáнту кýста"),
        ("Estou perdido", "я заблудился", "эстó пердúду"),
        ("Eu não sei", "я не знаю", "эу нáу сэй"),
        ("Um momento", "одну минуту", "ун момэ́нту"),
        ("Com licença", "извините (разрешите пройти)", "кон лисéнса"),
        ("Sim, por favor", "да, пожалуйста", "син пур фавóр"),
        ("Não, obrigado", "нет, спасибо", "нáу обригáду"),
        ("Qual é o seu nome?", "как вас зовут?", "куáл э у сéу нóми"),
        ("Muito prazer", "очень приятно", "мýйту празéр"),
        ("Eu sou da Rússia", "я из России", "эу со да хýсиа"),
        ("Água, por favor", "воду, пожалуйста", "áгуа пур фавóр"),
        ("A conta, por favor", "счёт, пожалуйста", "а кóнта пур фавóр"),
        ("Está bom", "хорошо / ладно", "эстá бон")
    ]

    static let phrases: [(String, String, String)] = [
        ("Olá", "привет", "олá"),
        ("Oi", "привет (неформ.)", "ой"),
        ("Bom dia", "доброе утро", "бон джúа"),
        ("Boa tarde", "добрый день", "боа тáрджи"),
        ("Boa noite", "добрый вечер / ночи", "боа нóйчи"),
        ("Obrigado", "спасибо (муж.)", "обригáду"),
        ("Obrigada", "спасибо (жен.)", "обригáда"),
        ("Por favor", "пожалуйста (просьба)", "пур фавóр"),
        ("De nada", "не за что", "джи нáда"),
        ("Desculpe", "извините", "дискýлпи"),
        ("Com licença", "разрешите (пройти)", "кон лисéнса"),
        ("Tudo bem?", "как дела?", "тýду бэн"),
        ("Tudo bem", "всё хорошо", "тýду бэн"),
        ("Sim", "да", "син"),
        ("Não", "нет", "нáу"),
        ("Não entendo", "не понимаю", "нáу энтéнду"),
        ("Não sei", "не знаю", "нáу сэй"),
        ("Quanto custa?", "сколько стоит?", "куáнту кýста"),
        ("Onde fica?", "где находится?", "óнджи фúка"),
        ("Que horas são?", "который час?", "ки óрас сáу"),
        ("Fala inglês?", "вы говорите по-английски?", "фáла инглéс"),
        ("Meu nome é...", "меня зовут...", "мéу нóми э"),
        ("Prazer", "приятно познакомиться", "празéр"),
        ("Tchau", "пока", "тшáу"),
        ("Até logo", "до встречи", "атэ лóгу")
    ]

    static let numbers: [(String, String, String)] = [
        ("zero", "0", "зéру"),
        ("um", "1 (муж.)", "ун"),
        ("uma", "1 (жен.)", "ýма"),
        ("dois", "2 (муж.)", "дóйс"),
        ("duas", "2 (жен.)", "дýас"),
        ("três", "3", "трэйс"),
        ("quatro", "4", "куáтру"),
        ("cinco", "5", "сúнку"),
        ("seis", "6", "сэйс"),
        ("sete", "7", "сéчи"),
        ("oito", "8", "óйту"),
        ("nove", "9", "нóви"),
        ("dez", "10", "дэйс"),
        ("onze", "11", "óнзи"),
        ("doze", "12", "дóзи"),
        ("vinte", "20", "вúнчи"),
        ("trinta", "30", "трúнта"),
        ("cinquenta", "50", "синкуéнта"),
        ("cem", "100", "сэн"),
        ("mil", "1000", "мил")
    ]

    static let verbs: [(String, String, String)] = [
        ("ser", "быть (постоянно)", "сэр"),
        ("estar", "быть (сейчас) / находиться", "эстáр"),
        ("ter", "иметь", "тэр"),
        ("ir", "идти / ехать", "ир"),
        ("fazer", "делать", "фазéр"),
        ("falar", "говорить", "фалáр"),
        ("comer", "есть (пищу)", "комéр"),
        ("beber", "пить", "бебéр"),
        ("querer", "хотеть", "керéр"),
        ("poder", "мочь", "подéр"),
        ("ver", "видеть", "вэр"),
        ("saber", "знать", "сабéр"),
        ("dizer", "сказать", "дизéр"),
        ("dar", "давать", "дар"),
        ("gostar", "нравиться", "гостáр"),
        ("morar", "жить (проживать)", "морáр"),
        ("trabalhar", "работать", "трабалльáр"),
        ("comprar", "покупать", "компрáр"),
        ("entender", "понимать", "энтендéр"),
        ("aprender", "учить / учиться", "апрендéр"),
        ("abrir", "открывать", "абрúр"),
        ("chegar", "прибывать", "шегáр"),
        ("precisar", "нуждаться", "пресизáр"),
        ("ajudar", "помогать", "ажудáр")
    ]

    static let nouns: [(String, String, String)] = [
        ("a água", "вода", "а áгуа"),
        ("o café", "кофе", "у кафэ́"),
        ("o pão", "хлеб", "у пáу"),
        ("a comida", "еда", "а комúда"),
        ("a casa", "дом", "а кáза"),
        ("o carro", "машина", "у кáху"),
        ("a rua", "улица", "а хýа"),
        ("a cidade", "город", "а сидáджи"),
        ("o trabalho", "работа", "у трабáлью"),
        ("o dinheiro", "деньги", "у диньéйру"),
        ("a loja", "магазин", "а лóжа"),
        ("o dia", "день", "у джúа"),
        ("a noite", "ночь / вечер", "а нóйчи"),
        ("a hora", "час / время", "а óра"),
        ("a água quente", "горячая вода", "а áгуа кэ́нчи"),
        ("o amigo", "друг", "у амúгу"),
        ("a família", "семья", "а фамúлиа"),
        ("o nome", "имя", "у нóми"),
        ("o homem", "мужчина", "у óмэн"),
        ("a mulher", "женщина", "а мульéр"),
        ("a criança", "ребёнок", "а криáнса"),
        ("o quarto", "комната", "у куáрту"),
        ("a chave", "ключ", "а шáви"),
        ("o telefone", "телефон", "у телефóни")
    ]

    static let adjectives: [(String, String, String)] = [
        ("bom / boa", "хороший / -ая", "бон / бóа"),
        ("mau / má", "плохой / -ая", "мáу / ма"),
        ("grande", "большой", "грáнджи"),
        ("pequeno", "маленький", "пекéну"),
        ("novo", "новый", "нóву"),
        ("velho", "старый", "вéлью"),
        ("caro", "дорогой", "кáру"),
        ("barato", "дешёвый", "барáту"),
        ("bonito", "красивый", "бонúту"),
        ("feio", "некрасивый", "фéйу"),
        ("quente", "горячий / тёплый", "кэ́нчи"),
        ("frio", "холодный", "фрúу"),
        ("fácil", "лёгкий", "фáсиль"),
        ("difícil", "трудный", "джифúсиль"),
        ("rápido", "быстрый", "хáпиду"),
        ("devagar", "медленный", "девагáр"),
        ("feliz", "счастливый", "фелúс"),
        ("cansado", "усталый", "кансáду"),
        ("certo", "правильный", "сéрту"),
        ("errado", "неправильный", "эхáду")
    ]
}
