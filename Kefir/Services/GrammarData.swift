import Foundation

// Данные для справочника грамматики. Каждый язык — секция с топиками, каждый топик — заголовок + таблица.
struct GrammarData {

    struct Topic: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let intro: String  // краткое пояснение
        let columns: [String]
        let rows: [[String]]
    }

    struct LanguageSection: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let topics: [Topic]
    }

    // portuguese / spanish определены в GrammarPortuguese.swift / GrammarSpanish.swift
    static let all: [LanguageSection] = [english, japanese, portuguese, spanish]

    // MARK: - English

    static let english = LanguageSection(name: "English", icon: "a.book.closed", topics: [
        tenses, tensesUsage, pronouns, phrasalRules, articles, articlesExamples, prepositions, prepositionsDeep, conditionals, reportedSpeech, questionWords, comparatives, modalVerbs
    ])

    static let tenses = Topic(
        title: "12 английских времён",
        icon: "clock",
        intro: "Формула + пример + слова-маркеры. Запомни формулу — остальное подставляется.",
        columns: ["Время", "Формула", "Пример", "Маркеры"],
        rows: [
            ["Present Simple", "V / V-s", "I work every day", "always, usually, every, often"],
            ["Present Continuous", "am/is/are + V-ing", "I am working now", "now, right now, at the moment"],
            ["Present Perfect", "have/has + V3", "I have finished", "already, just, yet, ever, never"],
            ["Present Perfect Cont.", "have/has been + V-ing", "I have been working for 2h", "for, since, how long"],
            ["Past Simple", "V2 / V-ed", "I worked yesterday", "yesterday, ago, last, in 2020"],
            ["Past Continuous", "was/were + V-ing", "I was working at 5pm", "while, when, at that time"],
            ["Past Perfect", "had + V3", "I had finished before he came", "before, after, by the time"],
            ["Past Perfect Cont.", "had been + V-ing", "I had been working for 2h", "for, since, before"],
            ["Future Simple", "will + V", "I will work tomorrow", "tomorrow, next, soon, I think"],
            ["Future Continuous", "will be + V-ing", "I will be working at 5", "at this time tomorrow"],
            ["Future Perfect", "will have + V3", "I will have finished by 6", "by, before, by the time"],
            ["Future Perfect Cont.", "will have been + V-ing", "I will have been working for 3h", "by, for, since"]
        ]
    )

    static let tensesUsage = Topic(
        title: "Времена: когда какое использовать",
        icon: "questionmark.circle",
        intro: "Главный вопрос: КОГДА действие и СВЯЗАНО ЛИ с настоящим?",
        columns: ["Время", "Когда использовать", "Пример"],
        rows: [
            ["Present Simple", "Привычки, факты, расписание", "The train leaves at 9. / Water boils at 100°C."],
            ["Present Continuous", "Прямо сейчас / временная ситуация / планы", "I'm reading now. / I'm living in Tokyo this year."],
            ["Present Perfect", "Результат в настоящем / опыт / с since/for", "I've lost my keys (→ сейчас нет). / Have you ever been to Japan?"],
            ["Present Perfect Cont.", "Долгое действие до сейчас (акцент на длительности)", "I've been studying for 3 hours (и устал)."],
            ["Past Simple", "Завершённое в прошлом, конкретное время", "I visited Tokyo last year. / She called me yesterday."],
            ["Past Continuous", "Фон / в процессе в прошлом / два действия", "I was sleeping when the phone rang."],
            ["Past Perfect", "ДО другого прошлого события", "I had already eaten when she arrived."],
            ["Past Perfect Cont.", "Длительное ДО момента в прошлом", "I had been waiting for 2 hours before the bus came."],
            ["Future Simple", "Спонтанное решение / обещание / предсказание", "I'll help you. / It will rain tomorrow."],
            ["Future Continuous", "В процессе в конкретный момент будущего", "At 8 PM I will be working."],
            ["Future Perfect", "Завершится ДО момента в будущем", "I will have finished by 5 PM."],
            ["Future Perfect Cont.", "Длиться до момента в будущем (акцент на длительности)", "By June I will have been working here for 5 years."],
            ["", "", ""],
            ["СОВЕТ", "Не знаешь какое — спроси себя:", ""],
            ["1.", "Когда? (сейчас / прошлое / будущее)", "→ выбери группу"],
            ["2.", "Закончилось или в процессе?", "→ Simple vs Continuous"],
            ["3.", "Связано с настоящим?", "→ Perfect vs Simple"]
        ]
    )

    static let pronouns = Topic(
        title: "Местоимения",
        icon: "person.2",
        intro: "5 форм: подлежащее, дополнение, притяж. определение, притяж. самостоят., возвратное.",
        columns: ["Subject", "Object", "Possessive Adj", "Possessive Pron", "Reflexive"],
        rows: [
            ["I", "me", "my", "mine", "myself"],
            ["you", "you", "your", "yours", "yourself"],
            ["he", "him", "his", "his", "himself"],
            ["she", "her", "her", "hers", "herself"],
            ["it", "it", "its", "its", "itself"],
            ["we", "us", "our", "ours", "ourselves"],
            ["they", "them", "their", "theirs", "themselves"]
        ]
    )

    static let phrasalRules = Topic(
        title: "Phrasal Verbs: как образуются",
        icon: "arrow.triangle.branch",
        intro: "Глагол + частица = новое значение. Частица меняет смысл глагола. Основные частицы и их «суперсилы»:",
        columns: ["Частица", "Значение", "Примеры"],
        rows: [
            ["up", "завершение / улучшение / увеличение", "clean up (убрать), cheer up (подбодрить), speed up (ускорить)"],
            ["down", "уменьшение / ухудшение / запись", "slow down (замедлить), break down (сломаться), write down (записать)"],
            ["out", "наружу / до конца / исчезновение", "find out (узнать), run out (закончиться), work out (разобраться)"],
            ["in", "внутрь / включение", "come in (войти), fill in (заполнить), check in (зарегистрироваться)"],
            ["on", "продолжение / включение / надевание", "carry on (продолжать), turn on (включить), put on (надеть)"],
            ["off", "отключение / удаление / отмена", "turn off (выключить), take off (снять), call off (отменить)"],
            ["back", "возврат / назад", "come back (вернуться), give back (отдать), call back (перезвонить)"],
            ["over", "повторение / сверху / через", "go over (просмотреть), take over (перенять), get over (пережить)"],
            ["away", "удаление / прочь", "throw away (выбросить), give away (отдать), run away (убежать)"],
            ["through", "через / до конца", "go through (пройти через), get through (дозвониться)"],
            ["around", "вокруг / без цели", "look around (осмотреться), hang around (слоняться)"],
            ["along", "вместе / вперёд", "get along (ладить), come along (присоединиться)"],
            ["into", "превращение / столкновение", "turn into (превратиться), run into (встретить случайно)"],
            ["for", "цель / поиск", "look for (искать), ask for (просить), care for (заботиться)"],
            ["up with", "терпение", "put up with (мириться с), come up with (придумать), keep up with (не отставать)"]
        ]
    )

    static let articles = Topic(
        title: "Артикли a / an / the",
        icon: "textformat",
        intro: "a/an — неопределённый (один из многих). the — определённый (конкретный). Ноль — общее понятие.",
        columns: ["Правило", "Пример"],
        rows: [
            ["a + согласный звук", "a dog, a university (юн!)"],
            ["an + гласный звук", "an apple, an hour (час!)"],
            ["the — конкретный, известный", "the sun, the book (which we talked about)"],
            ["the — уникальный", "the president, the internet, the moon"],
            ["без артикля — общее понятие", "I like music. Cats are cute."],
            ["без артикля — неисчисляемые (общее)", "Water is important. Love is blind."],
            ["без артикля — имена, страны", "Russia, John, London (но: the USA, the UK)"],
            ["a + профессия", "She is a doctor."],
            ["the + порядковый", "the first, the second, the last"],
            ["the + превосходная степень", "the best, the most beautiful"]
        ]
    )

    static let articlesExamples = Topic(
        title: "Артикли: примеры по ситуациям",
        icon: "text.book.closed",
        intro: "Конкретные ситуации — какой артикль и почему.",
        columns: ["Ситуация", "Пример", "Почему"],
        rows: [
            ["Первый раз упоминаем", "I saw a dog.", "Любая собака, слушатель не знает какая"],
            ["Упоминаем второй раз", "The dog was big.", "Уже знаем какая — та, что я видел"],
            ["Единственный в мире", "The moon is bright.", "Луна одна"],
            ["С инструментом", "I play the guitar.", "Инструменты — the"],
            ["Спорт", "I play tennis.", "Спорт — без артикля"],
            ["Завтрак/обед/ужин", "I had lunch.", "Приёмы пищи — без артикля"],
            ["Болезнь", "I have a headache.", "Конкретный случай — a"],
            ["Болезнь (общая)", "She has flu.", "Общее состояние — без артикля (BR) или the flu (US)"],
            ["Место (функция)", "He's in prison.", "Как заключённый (функция) — без артикля"],
            ["Место (здание)", "She went to the prison.", "Навестить — the (конкретное здание)"],
            ["Школа (учёба)", "She goes to school.", "Как ученица — без артикля"],
            ["Школа (здание)", "We went to the school.", "Как посетитель — the"],
            ["Работа", "I go to work.", "Без артикля всегда"],
            ["Дом", "I went home.", "Без артикля и предлога!"],
            ["Больница (BR)", "He's in hospital.", "Как пациент — без артикля"],
            ["Больница (US)", "He's in the hospital.", "В US всегда the"],
            ["Море/горы/пустыня", "the sea, the Alps, the Sahara", "Географические объекты — обычно the"],
            ["Озёра", "Lake Baikal", "Озёра — без the"],
            ["Улицы", "Oxford Street", "Улицы — без the"],
            ["Газеты", "The Times, The Guardian", "Газеты — the"],
            ["Языки", "I speak English.", "Без артикля"],
            ["Нации (люди)", "The French love wine.", "Обобщение нации — the + прилагательное"]
        ]
    )

    static let prepositions = Topic(
        title: "Предлоги: at / in / on",
        icon: "mappin",
        intro: "Три самых частых предлога. Правила зависят от контекста: время или место.",
        columns: ["Предлог", "Время", "Место"],
        rows: [
            ["at", "at 5 o'clock, at noon, at night, at the weekend", "at home, at work, at school, at the bus stop"],
            ["in", "in January, in 2024, in the morning, in summer", "in Russia, in Moscow, in a room, in a car"],
            ["on", "on Monday, on May 5th, on my birthday, on weekdays", "on the table, on the wall, on the 2nd floor, on a bus"],
            ["at", "at Christmas, at Easter, at the moment", "at the door, at the top, at the end"],
            ["in", "in an hour, in 5 minutes, in time", "in the corner, in the middle, in a line"],
            ["on", "on time (вовремя), on holiday, on the phone", "on the left/right, on the way, on foot"]
        ]
    )

    static let prepositionsDeep = Topic(
        title: "Предлоги: глаголы + предлоги",
        icon: "arrow.right",
        intro: "Многие глаголы требуют конкретный предлог. Выучи как связку.",
        columns: ["Глагол + предлог", "Значение", "Пример"],
        rows: [
            ["listen to", "слушать (что-то)", "Listen to the music."],
            ["look at", "смотреть на", "Look at me."],
            ["look for", "искать", "I'm looking for my phone."],
            ["wait for", "ждать", "Wait for me!"],
            ["depend on", "зависеть от", "It depends on the weather."],
            ["belong to", "принадлежать", "This belongs to me."],
            ["think about/of", "думать о", "I'm thinking about you."],
            ["dream about/of", "мечтать о", "I dream of traveling."],
            ["apologize for", "извиняться за", "She apologized for being late."],
            ["arrive at/in", "прибыть в (at — точка, in — город)", "Arrive at the station / in London."],
            ["agree with", "согласиться с (человеком)", "I agree with you."],
            ["agree on", "согласиться о (теме)", "We agreed on the price."],
            ["interested in", "интересоваться чем-то", "I'm interested in art."],
            ["good at", "хорош в", "She's good at math."],
            ["afraid of", "бояться чего-то", "I'm afraid of spiders."],
            ["tired of", "устал от", "I'm tired of waiting."],
            ["married to", "женат/замужем за", "She's married to John."],
            ["different from", "отличаться от", "This is different from that."],
            ["famous for", "знаменит чем-то", "Paris is famous for the Eiffel Tower."],
            ["responsible for", "ответственный за", "Who's responsible for this?"],
            ["proud of", "гордиться чем-то", "I'm proud of you."],
            ["keen on", "увлекаться", "He's keen on football."],
            ["worried about", "беспокоиться о", "Don't be worried about the exam."],
            ["angry with (person)", "злиться на (человека)", "She's angry with me."],
            ["angry about (thing)", "злиться из-за (вещи)", "He's angry about the delay."]
        ]
    )

    static let conditionals = Topic(
        title: "Условные предложения (If...)",
        icon: "arrow.triangle.swap",
        intro: "4 типа условных: от факта до нереальности.",
        columns: ["Тип", "If...", "Main clause", "Пример", "Когда"],
        rows: [
            ["Zero", "If + Present Simple", "Present Simple", "If you heat water, it boils.", "Факт, всегда правда"],
            ["First", "If + Present Simple", "will + V", "If it rains, I will stay home.", "Реальное будущее"],
            ["Second", "If + Past Simple", "would + V", "If I had money, I would travel.", "Нереальное настоящее"],
            ["Third", "If + Past Perfect", "would have + V3", "If I had studied, I would have passed.", "Нереальное прошлое"]
        ]
    )

    static let reportedSpeech = Topic(
        title: "Косвенная речь (Reported Speech)",
        icon: "quote.bubble",
        intro: "Прямая → косвенная: сдвигаем время на один шаг назад. that можно опустить.",
        columns: ["Прямая речь", "Косвенная речь", "Правило"],
        rows: [
            ["\"I am tired.\"", "He said (that) he was tired.", "am/is → was"],
            ["\"I like pizza.\"", "She said she liked pizza.", "Present Simple → Past Simple"],
            ["\"I am working.\"", "He said he was working.", "Present Cont. → Past Cont."],
            ["\"I have finished.\"", "She said she had finished.", "Present Perfect → Past Perfect"],
            ["\"I will help.\"", "He said he would help.", "will → would"],
            ["\"I can swim.\"", "She said she could swim.", "can → could"],
            ["\"I may go.\"", "He said he might go.", "may → might"],
            ["\"I must leave.\"", "She said she had to leave.", "must → had to"],
            ["", "", ""],
            ["Вопросы:", "", ""],
            ["\"Do you like tea?\"", "She asked if I liked tea.", "Do/Does → if/whether + Past"],
            ["\"Where do you live?\"", "He asked where I lived.", "Wh-word + утвердительный порядок"],
            ["\"Are you coming?\"", "She asked if I was coming.", "Are → if + Past Cont."],
            ["", "", ""],
            ["Команды:", "", ""],
            ["\"Open the door.\"", "He told me to open the door.", "told + to + V"],
            ["\"Don't touch it.\"", "She told me not to touch it.", "told + not to + V"],
            ["", "", ""],
            ["Слова-сдвиги:", "", ""],
            ["today → that day", "now → then", "here → there"],
            ["yesterday → the day before", "tomorrow → the next day", "ago → before"]
        ]
    )

    static let questionWords = Topic(
        title: "Вопросительные слова",
        icon: "questionmark.diamond",
        intro: "Wh-questions: вопросительное слово + вспомогательный глагол + подлежащее + сказуемое.",
        columns: ["Слово", "Про что", "Пример", "Перевод"],
        rows: [
            ["What", "вещь / действие", "What is your name?", "Как тебя зовут?"],
            ["What (+ noun)", "какой / что за", "What time is it?", "Который час?"],
            ["Which", "какой (из ограниченного)", "Which color: red or blue?", "Какой цвет: красный или синий?"],
            ["Who", "кто (подлежащее)", "Who called you?", "Кто тебе звонил?"],
            ["Whom", "кого (формальн.)", "Whom did you meet?", "Кого ты встретил?"],
            ["Whose", "чей", "Whose bag is this?", "Чья это сумка?"],
            ["Where", "где / куда", "Where do you live?", "Где ты живёшь?"],
            ["When", "когда", "When does the train leave?", "Когда уходит поезд?"],
            ["Why", "почему", "Why are you late?", "Почему ты опоздал?"],
            ["How", "как", "How are you?", "Как дела?"],
            ["How much", "сколько (неисчисл.)", "How much water?", "Сколько воды?"],
            ["How many", "сколько (исчисл.)", "How many cats?", "Сколько кошек?"],
            ["How long", "как долго", "How long does it take?", "Сколько времени занимает?"],
            ["How often", "как часто", "How often do you run?", "Как часто ты бегаешь?"],
            ["How far", "как далеко", "How far is the station?", "Как далеко станция?"],
            ["How old", "сколько лет", "How old are you?", "Сколько тебе лет?"],
            ["How come", "как так (почему, неформ.)", "How come you're here?", "Как так ты здесь?"],
            ["What if", "а что если", "What if it rains?", "А что если дождь?"],
            ["What about", "как насчёт", "What about pizza?", "Как насчёт пиццы?"],
            ["What for", "зачем", "What did you do that for?", "Зачем ты это сделал?"]
        ]
    )

    static let comparatives = Topic(
        title: "Сравнительная и превосходная степень",
        icon: "chart.bar",
        intro: "Short words: -er / -est. Long words: more / most.",
        columns: ["Правило", "Adjective", "Comparative", "Superlative"],
        rows: [
            ["1 слог", "tall", "taller", "the tallest"],
            ["1 слог на -e", "nice", "nicer", "the nicest"],
            ["1 слог CVC", "big", "bigger", "the biggest"],
            ["2 слога на -y", "happy", "happier", "the happiest"],
            ["2+ слога", "beautiful", "more beautiful", "the most beautiful"],
            ["исключение", "good", "better", "the best"],
            ["исключение", "bad", "worse", "the worst"],
            ["исключение", "far", "farther / further", "the farthest / furthest"],
            ["исключение", "much/many", "more", "the most"],
            ["исключение", "little", "less", "the least"]
        ]
    )

    static let modalVerbs = Topic(
        title: "Модальные глаголы",
        icon: "exclamationmark.triangle",
        intro: "Выражают возможность, долг, совет. Не изменяются по лицам, после них — V без to.",
        columns: ["Modal", "Значение", "Пример"],
        rows: [
            ["can", "умею / могу", "I can swim."],
            ["could", "мог / вежливая просьба", "Could you help me?"],
            ["may", "может быть / разрешение (формальн.)", "May I come in?"],
            ["might", "может быть (менее вероятно)", "It might rain."],
            ["must", "должен (обязательно)", "You must wear a seatbelt."],
            ["have to", "должен (внешнее)", "I have to work today."],
            ["should", "следует (совет)", "You should see a doctor."],
            ["shall", "предложение (формальн.)", "Shall I open the window?"],
            ["will", "буду / обещание", "I will call you."],
            ["would", "бы / вежл. просьба", "Would you like tea?"],
            ["need to", "нужно", "I need to finish this."],
            ["don't have to", "не обязательно", "You don't have to come."],
            ["mustn't", "запрещено", "You mustn't smoke here."]
        ]
    )

    // MARK: - Japanese

    static let japanese = LanguageSection(name: "日本語", icon: "character.book.closed.ja", topics: [
        hiraganaChart, katakanaChart, jaParticles, jaVerbGroups, jaTeForm, jaCounters
    ])

    static let hiraganaChart = Topic(
        title: "Хирагана — таблица",
        icon: "character.textbox.ja",
        intro: "46 основных знаков. Сверху — кана, снизу — ромадзи (произношение).",
        columns: ["", "a", "i", "u", "e", "o"],
        rows: [
            ["∅", "あ\na", "い\ni", "う\nu", "え\ne", "お\no"],
            ["k", "か\nka", "き\nki", "く\nku", "け\nke", "こ\nko"],
            ["s", "さ\nsa", "し\nshi", "す\nsu", "せ\nse", "そ\nso"],
            ["t", "た\nta", "ち\nchi", "つ\ntsu", "て\nte", "と\nto"],
            ["n", "な\nna", "に\nni", "ぬ\nnu", "ね\nne", "の\nno"],
            ["h", "は\nha", "ひ\nhi", "ふ\nfu", "へ\nhe", "ほ\nho"],
            ["m", "ま\nma", "み\nmi", "む\nmu", "め\nme", "も\nmo"],
            ["y", "や\nya", "", "ゆ\nyu", "", "よ\nyo"],
            ["r", "ら\nra", "り\nri", "る\nru", "れ\nre", "ろ\nro"],
            ["w", "わ\nwa", "", "", "", "を\nwo"],
            ["n", "ん\nn", "", "", "", ""]
        ]
    )

    static let katakanaChart = Topic(
        title: "Катакана — таблица",
        icon: "character.textbox.ja",
        intro: "Те же звуки, другие символы. Используется для иностранных слов, звукоподражаний.",
        columns: ["", "a", "i", "u", "e", "o"],
        rows: [
            ["∅", "ア\na", "イ\ni", "ウ\nu", "エ\ne", "オ\no"],
            ["k", "カ\nka", "キ\nki", "ク\nku", "ケ\nke", "コ\nko"],
            ["s", "サ\nsa", "シ\nshi", "ス\nsu", "セ\nse", "ソ\nso"],
            ["t", "タ\nta", "チ\nchi", "ツ\ntsu", "テ\nte", "ト\nto"],
            ["n", "ナ\nna", "ニ\nni", "ヌ\nnu", "ネ\nne", "ノ\nno"],
            ["h", "ハ\nha", "ヒ\nhi", "フ\nfu", "ヘ\nhe", "ホ\nho"],
            ["m", "マ\nma", "ミ\nmi", "ム\nmu", "メ\nme", "モ\nmo"],
            ["y", "ヤ\nya", "", "ユ\nyu", "", "ヨ\nyo"],
            ["r", "ラ\nra", "リ\nri", "ル\nru", "レ\nre", "ロ\nro"],
            ["w", "ワ\nwa", "", "", "", "ヲ\nwo"],
            ["n", "ン\nn", "", "", "", ""]
        ]
    )

    static let jaParticles = Topic(
        title: "Частицы (助詞)",
        icon: "bubble.left.and.text.bubble.right",
        intro: "Частицы — клей японского предложения. Ставятся ПОСЛЕ слова, к которому относятся.",
        columns: ["Частица", "Функция", "Пример", "Перевод"],
        rows: [
            ["は (wa)", "тема предложения", "私は学生です", "Я — студент"],
            ["が (ga)", "подлежащее / новое", "猫がいる", "Есть кошка (вот она!)"],
            ["を (wo)", "прямое дополнение", "水を飲む", "Пью воду"],
            ["に (ni)", "направление / время / место", "学校に行く", "Иду в школу"],
            ["で (de)", "место действия / средство", "カフェで食べる", "Ем в кафе"],
            ["へ (e)", "направление", "東京へ行く", "Еду в Токио"],
            ["と (to)", "и / с кем-то / цитата", "友達と行く", "Иду с другом"],
            ["から (kara)", "из / с (начало)", "9時から", "С 9 часов"],
            ["まで (made)", "до (конец)", "5時まで", "До 5 часов"],
            ["も (mo)", "тоже", "私も行く", "Я тоже пойду"],
            ["の (no)", "притяжание / описание", "私の本", "Моя книга"],
            ["か (ka)", "вопрос", "日本人ですか", "Вы японец?"],
            ["よ (yo)", "утверждение (послушай!)", "行くよ", "Я иду! (знай!)"],
            ["ね (ne)", "подтверждение (правда?)", "いいね", "Хорошо, правда?"]
        ]
    )

    static let jaVerbGroups = Topic(
        title: "Группы глаголов",
        icon: "list.bullet",
        intro: "3 группы. Определи группу → применяй правила спряжения.",
        columns: ["Группа", "Правило", "Примеры", "ます-форма"],
        rows: [
            ["Group 1 (u-verbs)", "Окончание на -u (не -iru/-eru)", "飲む、書く、話す、行く", "飲みます、書きます"],
            ["Group 2 (ru-verbs)", "Окончание на -iru / -eru", "食べる、見る、起きる", "食べます、見ます"],
            ["Group 3 (irregular)", "Только два глагола", "する、来る（くる）", "します、きます"],
            ["Исключения Gr.1!", "Выглядят как Gr.2, но Gr.1", "帰る、知る、入る、走る", "帰ります、知ります"],
            ["Negative (Gr.1)", "-u → -anai", "飲む → 飲まない", "не пью"],
            ["Negative (Gr.2)", "-ru → -nai", "食べる → 食べない", "не ем"],
            ["Past (Gr.1)", "て-form based", "飲む → 飲んだ", "пил"],
            ["Past (Gr.2)", "-ru → -ta", "食べる → 食べた", "ел"]
        ]
    )

    static let jaTeForm = Topic(
        title: "て-форма (te-form)",
        icon: "arrow.right.arrow.left",
        intro: "Самая важная форма! Используется для: просьб, продолжения, разрешения, соединения предложений.",
        columns: ["Окончание", "Замена", "Пример"],
        rows: [
            ["う、つ、る", "→ って", "買う→買って、持つ→持って、帰る→帰って"],
            ["む、ぶ、ぬ", "→ んで", "飲む→飲んで、遊ぶ→遊んで"],
            ["く", "→ いて", "書く→書いて (исключение: 行く→行って)"],
            ["ぐ", "→ いで", "泳ぐ→泳いで"],
            ["す", "→ して", "話す→話して"],
            ["Gr.2: -る", "→ -て", "食べる→食べて、見る→見て"],
            ["する", "→ して", "する→して"],
            ["来る", "→ 来て (きて)", "来る→来て"],
            ["Использование", "Описание", ""],
            ["~てください", "Пожалуйста, сделайте", "見てください (посмотрите)"],
            ["~ている", "Прогрессив (делаю сейчас)", "食べている (ем)"],
            ["~てもいい", "Можно ли?", "入ってもいいですか (можно войти?)"],
            ["~てはいけない", "Нельзя", "触ってはいけない (нельзя трогать)"]
        ]
    )

    static let jaCounters = Topic(
        title: "Счётные суффиксы",
        icon: "number",
        intro: "В японском вещи считают по-разному в зависимости от формы/типа предмета.",
        columns: ["Суффикс", "Для чего", "1", "2", "3"],
        rows: [
            ["つ (tsu)", "Универсальный (до 10)", "ひとつ", "ふたつ", "みっつ"],
            ["人 (nin)", "Люди", "ひとり", "ふたり", "さんにん"],
            ["本 (hon)", "Длинное/тонкое (ручки, бутылки)", "いっぽん", "にほん", "さんぼん"],
            ["枚 (mai)", "Плоское (бумага, тарелки)", "いちまい", "にまい", "さんまい"],
            ["匹 (hiki)", "Животные (мелкие)", "いっぴき", "にひき", "さんびき"],
            ["冊 (satsu)", "Книги, тетради", "いっさつ", "にさつ", "さんさつ"],
            ["台 (dai)", "Машины, техника", "いちだい", "にだい", "さんだい"],
            ["杯 (hai)", "Стаканы, чашки", "いっぱい", "にはい", "さんばい"],
            ["歳 (sai)", "Возраст", "いっさい", "にさい", "さんさい"],
            ["階 (kai)", "Этажи", "いっかい", "にかい", "さんがい"]
        ]
    )
}