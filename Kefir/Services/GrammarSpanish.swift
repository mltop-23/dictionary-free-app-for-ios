import Foundation

// Справочник по испанскому. Подключается в GrammarData.all.
// Везде — транскрипция на русском. Произношение почти как пишется (испанский фонетичен).
extension GrammarData {

    static let spanish = LanguageSection(name: "Español", icon: "e.circle", topics: [
        esAlphabet, esPronunciation, esArticles, esSerEstar, esVerbsPresent,
        esPronouns, esNumbers, esQuestions, esPhrases
    ])

    static let esAlphabet = Topic(
        title: "Алфавит и особые звуки",
        icon: "textformat.abc",
        intro: "Испанский читается почти как пишется. Запомни горстку особых букв — и читаешь всё.",
        columns: ["Буква / сочет.", "Звук (рус.)", "Пример", "Транскрипция"],
        rows: [
            ["ñ", "нь", "español", "эспаньóль"],
            ["ll", "й (часто)", "llamar", "ямáр"],
            ["j", "х (резкое)", "jamón", "хамóн"],
            ["ge, gi", "х", "gente", "хéнте"],
            ["h", "не читается", "hola", "óла"],
            ["c (перед e, i)", "с", "cinco", "сúнко"],
            ["c (перед a,o,u)", "к", "casa", "кáса"],
            ["qu", "к", "queso", "кéсо"],
            ["z", "с", "zapato", "сапáто"],
            ["v", "б", "vino", "бúно"],
            ["rr", "р (раскатистое)", "perro", "пéрро"],
            ["y", "й", "yo", "йо"],
            ["ch", "ч", "mucho", "мýчо"]
        ]
    )

    static let esPronunciation = Topic(
        title: "Гласные и ударение",
        icon: "waveform",
        intro: "5 чистых гласных (как в русском). Ударение по правилу или по знаку ´.",
        columns: ["Правило", "Пояснение", "Пример", "Транскрипция"],
        rows: [
            ["a e i o u", "всегда чёткие, без редукции", "casa", "кáса"],
            ["Знак ´", "ставит ударение явно", "café", "кафэ́"],
            ["Слово на гласную / -n / -s", "ударение на предпоследний слог", "carmen", "кáрмен"],
            ["Слово на согласную (кроме n,s)", "ударение на последний слог", "hotel", "отэ́ль"],
            ["Есть знак ´", "ударение туда, правило не работает", "lápiz", "лáпис"],
            ["ai, ei, oi", "дифтонг (один слог)", "aire, seis", "áйре, сэйс"],
            ["ue, ie", "дифтонг", "bueno, bien", "буэ́но, бьен"]
        ]
    )

    static let esArticles = Topic(
        title: "Артикли и род",
        icon: "textformat",
        intro: "Рода два. Артикль согласуется по роду и числу. -o обычно муж., -a обычно жен.",
        columns: ["", "Муж. ед.", "Жен. ед.", "Муж. мн.", "Жен. мн."],
        rows: [
            ["Определённый", "el", "la", "los", "las"],
            ["Неопределённый", "un", "una", "unos", "unas"],
            ["Пример", "el libro", "la casa", "los libros", "las casas"],
            ["Транскрипция", "эль лúбро", "ла кáса", "лос лúброс", "лас кáсас"],
            ["", "", "", "", ""],
            ["-o → муж.", "el carro (машина)", "", "", ""],
            ["-a → жен.", "la mesa (стол)", "", "", ""],
            ["-ción / -dad → жен.", "la nación, la ciudad", "", "", ""],
            ["Исключения", "el día, el problema, la mano", "", "", ""],
            ["a + el = al", "Voy al cine.", "(иду в кино)", "", ""],
            ["de + el = del", "la casa del amigo", "(дом друга)", "", ""]
        ]
    )

    static let esSerEstar = Topic(
        title: "ser vs estar (два «быть»)",
        icon: "arrow.triangle.swap",
        intro: "ser — постоянное (кто/какой ты). estar — временное (где/как ты сейчас).",
        columns: ["Лицо", "ser (постоянное)", "estar (сейчас)", "Транскрипция"],
        rows: [
            ["yo (я)", "soy", "estoy", "сой / эстóй"],
            ["tú (ты)", "eres", "estás", "э́рес / эстáс"],
            ["él/ella (он/она)", "es", "está", "эс / эстá"],
            ["nosotros (мы)", "somos", "estamos", "сóмос / эстáмос"],
            ["vosotros (вы, Исп.)", "sois", "estáis", "сóйс / эстáйс"],
            ["ellos (они)", "son", "están", "сон / эстáн"],
            ["", "", "", ""],
            ["ser — пример", "Soy ruso.", "(я русский — всегда)", "сой рýсо"],
            ["estar — пример", "Estoy cansado.", "(я устал — сейчас)", "эстóй кансáдо"],
            ["ser — для чего", "имя, нация, профессия, характер", "", ""],
            ["estar — для чего", "местоположение, настроение, состояние", "", ""]
        ]
    )

    static let esVerbsPresent = Topic(
        title: "Глаголы: настоящее время",
        icon: "list.bullet",
        intro: "Три спряжения по окончанию: -ar, -er, -ir. Форма vosotros — только в Испании.",
        columns: ["Лицо", "-ar (hablar)", "-er (comer)", "-ir (vivir)"],
        rows: [
            ["yo", "hablo", "como", "vivo"],
            ["tú", "hablas", "comes", "vives"],
            ["él / ella", "habla", "come", "vive"],
            ["nosotros", "hablamos", "comemos", "vivimos"],
            ["vosotros", "habláis", "coméis", "vivís"],
            ["ellos / ellas", "hablan", "comen", "viven"],
            ["", "", "", ""],
            ["перевод", "говорить", "есть", "жить"],
            ["транскрипция (yo)", "áбло", "кóмо", "бúбо"],
            ["", "", "", ""],
            ["tener (иметь) — непр.", "tengo / tienes / tiene / tenemos / tienen", "", ""],
            ["ir (идти) — непр.", "voy / vas / va / vamos / van", "", ""],
            ["hacer (делать) — непр.", "hago / haces / hace / hacemos / hacen", "", ""]
        ]
    )

    static let esPronouns = Topic(
        title: "Местоимения",
        icon: "person.2",
        intro: "Подлежащее обычно опускают (его видно по глаголу). Притяжательные согласуются по числу.",
        columns: ["Подлеж.", "Перевод", "Притяж.", "Транскрипция"],
        rows: [
            ["yo", "я", "mi / mis", "йо · ми"],
            ["tú", "ты", "tu / tus", "ту · ту"],
            ["él", "он", "su / sus", "эль · су"],
            ["ella", "она", "su / sus", "э́йа · су"],
            ["nosotros", "мы", "nuestro / -a", "носóтрос · нуэ́стро"],
            ["vosotros", "вы (Исп.)", "vuestro / -a", "босóтрос"],
            ["ellos", "они (м.)", "su / sus", "э́йос"],
            ["ellas", "они (ж.)", "su / sus", "э́йас"]
        ]
    )

    static let esNumbers = Topic(
        title: "Числа",
        icon: "number",
        intro: "1–10 наизусть. uno → un перед сущ. муж. рода (un libro), una — перед жен. (una casa).",
        columns: ["Число", "Слово", "Транскрипция"],
        rows: [
            ["0", "cero", "сэ́ро"],
            ["1", "uno / una", "ýно / ýна"],
            ["2", "dos", "дос"],
            ["3", "tres", "трэс"],
            ["4", "cuatro", "куáтро"],
            ["5", "cinco", "сúнко"],
            ["6", "seis", "сэйс"],
            ["7", "siete", "сьéте"],
            ["8", "ocho", "óчо"],
            ["9", "nueve", "нуэ́бе"],
            ["10", "diez", "дьес"],
            ["20", "veinte", "бэ́йнте"],
            ["100", "cien", "сьен"],
            ["1000", "mil", "миль"]
        ]
    )

    static let esQuestions = Topic(
        title: "Вопросительные слова",
        icon: "questionmark.diamond",
        intro: "В вопросе вопросительное слово всегда с ударным знаком ´ и в начале: ¿Qué? ¿Dónde?",
        columns: ["Слово", "Перевод", "Пример", "Транскрипция"],
        rows: [
            ["qué", "что", "¿Qué es esto?", "кэ эс э́сто"],
            ["quién", "кто", "¿Quién eres?", "кьен э́рес"],
            ["dónde", "где", "¿Dónde está?", "дóнде эстá"],
            ["cuándo", "когда", "¿Cuándo llega?", "куáндо йéга"],
            ["por qué", "почему", "¿Por qué no?", "пор кэ но"],
            ["cómo", "как", "¿Cómo estás?", "кóмо эстáс"],
            ["cuál", "какой", "¿Cuál es tu nombre?", "куáль эс ту нóмбре"],
            ["cuánto", "сколько", "¿Cuánto cuesta?", "куáнто куэ́ста"],
            ["qué hora", "который час", "¿Qué hora es?", "кэ óра эс"]
        ]
    )

    static let esPhrases = Topic(
        title: "Полезные фразы",
        icon: "bubble.left.and.text.bubble.right",
        intro: "Дежурный набор на каждый день: поздороваться, поблагодарить, спросить.",
        columns: ["Фраза", "Перевод", "Транскрипция"],
        rows: [
            ["Hola", "привет", "óла"],
            ["Buenos días", "доброе утро", "буэ́нос дúас"],
            ["Buenas tardes", "добрый день", "буэ́нас тáрдес"],
            ["Buenas noches", "добрый вечер", "буэ́нас нóчес"],
            ["Gracias", "спасибо", "грáсиас"],
            ["Por favor", "пожалуйста (просьба)", "пор фавóр"],
            ["De nada", "не за что", "дэ нáда"],
            ["Perdón / Lo siento", "извините / простите", "пэрдóн / ло сьéнто"],
            ["¿Qué tal?", "как дела?", "кэ таль"],
            ["Sí / No", "да / нет", "си / но"],
            ["No entiendo", "не понимаю", "но энтьéндо"],
            ["¿Cuánto cuesta?", "сколько стоит?", "куáнто куэ́ста"],
            ["Adiós / Hasta luego", "пока / до встречи", "адьóс / áста луэ́го"],
            ["Mucho gusto", "приятно познакомиться", "мýчо гýсто"]
        ]
    )
}
