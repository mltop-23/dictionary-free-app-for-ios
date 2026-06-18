import SwiftUI

// Вспомогательные вьюхи для учёбы из произвольного массива карточек
// (используются в FavoritesView и SearchResults).
// Для избранного карточки могут быть из разных колод → режим определяется по card.deck?.mode

// MARK: - Flashcards Core

struct FlashcardsCoreView: View {
    let cards: [Card]
    var forceReversed: Bool? = nil   // если задано — переопределяет направление колоды
    @Environment(\.dismiss) private var dismiss
    @State private var index: Int = 0
    @State private var showAnswer: Bool = false
    @State private var shuffled: [Card] = []
    @State private var isShuffled: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var finished: Bool = false
    @State private var masteredThisSession: Int = 0

    var body: some View {
        VStack(spacing: 16) {
            if shuffled.isEmpty {
                ContentUnavailableView("Нет карточек", systemImage: "tray")
            } else if finished {
                finishedView
            } else {
                let card = shuffled[index]

                HStack {
                    Text("\(index + 1) / \(shuffled.count)")
                        .font(.subheadline.monospacedDigit())
                    Spacer()
                    Button {
                        card.isFavorite.toggle()
                    } label: {
                        Image(systemName: card.isFavorite ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                    }
                    Button {
                        isShuffled.toggle()
                        shuffled = isShuffled ? cards.shuffled() : cards
                        index = 0; showAnswer = false
                    } label: {
                        Image(systemName: isShuffled ? "shuffle.circle.fill" : "shuffle")
                    }
                }
                .padding(.horizontal)

                let mode = card.deck?.mode ?? .classic
                let rev = forceReversed ?? (card.deck?.isReversed ?? false)
                CardFlipView(
                    card: card,
                    mode: mode,
                    showAnswer: $showAnswer,
                    frontLang: card.deck?.frontLanguage ?? "en-US",
                    backLang: card.deck?.backLanguage ?? "ru-RU",
                    reversed: rev
                )
                .overlay(
                    // Оверлей «ГОТОВО» при свайпе ВВЕРХ (когда ответ открыт)
                    Group {
                        if showAnswer && dragOffset.height < -40 {
                            let alpha = min(0.5, Double(-dragOffset.height / 200))
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.green.opacity(alpha))
                                .overlay(
                                    VStack {
                                        Image(systemName: "checkmark.seal.fill").font(.system(size: 60))
                                        Text("ГОТОВО").font(.title2.bold())
                                    }
                                    .foregroundStyle(.white)
                                    .opacity(min(1.0, Double((-dragOffset.height - 40) / 80)))
                                )
                        }
                    }
                )
                .offset(x: dragOffset.width, y: dragOffset.height)
                .rotationEffect(.degrees(Double(dragOffset.width / 30)))
                .gesture(
                    DragGesture()
                        .onChanged { v in dragOffset = v.translation }
                        .onEnded { v in
                            let hThreshold: CGFloat = 80
                            let vThreshold: CGFloat = 100
                            let absH = abs(v.translation.width)
                            let absV = abs(v.translation.height)

                            // Доминирующая ось определяет жест
                            if absV > absH && v.translation.height < -vThreshold && showAnswer {
                                // Свайп вверх → Готово + следующая
                                animateUp {
                                    markMastered(card)
                                    next()
                                }
                            } else if absH > absV && v.translation.width < -hThreshold {
                                animateH(direction: -1) { next() }
                            } else if absH > absV && v.translation.width > hThreshold {
                                animateH(direction: 1) { prev() }
                            } else {
                                withAnimation(.spring) { dragOffset = .zero }
                            }
                        }
                )
                .padding(.horizontal)

                HStack(spacing: 24) {
                    Button { prev() } label: {
                        Image(systemName: "chevron.left.circle.fill").font(.largeTitle)
                    }
                    .disabled(index == 0)
                    Button {
                        withAnimation(.spring) { showAnswer.toggle() }
                    } label: {
                        Text(showAnswer ? "Скрыть" : "Показать")
                            .frame(minWidth: 120).padding(.vertical, 10)
                            .background(.blue).foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    Button { next() } label: {
                        Image(systemName: "chevron.right.circle.fill").font(.largeTitle)
                    }
                    .disabled(index >= shuffled.count - 1)
                }
                .padding()

                Text("← следующая   ⇧ Готово   → предыдущая")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .navigationTitle("Карточки")
        .onAppear {
            guard shuffled.isEmpty else { return }
            shuffled = cards
        }
    }

    private func animateH(direction: CGFloat, after: @escaping () -> Void) {
        withAnimation(.easeOut(duration: 0.2)) {
            dragOffset = CGSize(width: direction * 500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            after()
            dragOffset = .zero
        }
    }

    private func animateUp(after: @escaping () -> Void) {
        withAnimation(.easeOut(duration: 0.2)) {
            dragOffset = CGSize(width: 0, height: -700)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            after()
            dragOffset = .zero
        }
    }

    private func markMastered(_ card: Card) {
        card.stage = .mastered
        card.intervalDays = 90
        card.repetitions = max(card.repetitions, 5)
        card.dueAt = Date().addingTimeInterval(90 * 86400)
        card.lastReviewedAt = Date()
        card.totalReviews += 1
        card.correctReviews += 1
        masteredThisSession += 1
    }

    private func next() {
        if index < shuffled.count - 1 {
            index += 1
            showAnswer = false
        } else {
            finished = true
        }
    }
    private func prev() {
        guard index > 0 else { return }
        index -= 1; showAnswer = false
    }

    private var finishedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 100))
                .foregroundStyle(.green)
            Text("Готово!")
                .font(.largeTitle.bold())
            Text("Прошёл \(shuffled.count) карточек")
                .font(.title3)
                .foregroundStyle(.secondary)
            if masteredThisSession > 0 {
                Label("\(masteredThisSession) отмечено как выученные", systemImage: "star.fill")
                    .foregroundStyle(.yellow)
            }

            VStack(spacing: 10) {
                Button {
                    restart()
                } label: {
                    Label("Начать заново", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity).padding()
                        .background(.blue).foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button {
                    isShuffled = true
                    shuffled = cards.shuffled()
                    restart()
                } label: {
                    Label("Перемешать и начать", systemImage: "shuffle")
                        .frame(maxWidth: .infinity).padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button {
                    dismiss()
                } label: {
                    Text("На главную")
                        .frame(maxWidth: .infinity).padding()
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    private func restart() {
        index = 0
        showAnswer = false
        finished = false
        masteredThisSession = 0
        dragOffset = .zero
    }
}

// MARK: - Test Core

struct TestCoreView: View {
    let cards: [Card]
    var forceReversed: Bool? = nil

    struct Q {
        let card: Card
        let options: [String]
        let correct: Int
    }

    @State private var questions: [Q] = []
    @State private var currentIndex: Int = 0
    @State private var selectedAnswer: Int?
    @State private var correctAnswers: Int = 0
    @State private var finished: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            if finished {
                let pct = Int(Double(correctAnswers) / Double(max(questions.count, 1)) * 100)
                VStack(spacing: 16) {
                    Image(systemName: pct >= 80 ? "star.fill" : "hand.thumbsup.fill")
                        .font(.system(size: 80)).foregroundStyle(.yellow)
                    Text("\(correctAnswers) / \(questions.count)").font(.largeTitle.bold())
                    Text("\(pct)%").font(.title2).foregroundStyle(.secondary)
                    Button("Ещё раз") { start() }.buttonStyle(.borderedProminent)
                }
            } else if let q = questions[safe: currentIndex] {
                let mode = q.card.deck?.mode ?? .classic
                let reversed = forceReversed ?? (q.card.deck?.isReversed ?? false)
                VStack {
                    ProgressView(value: Double(currentIndex + 1), total: Double(questions.count))
                    HStack {
                        Text("\(currentIndex + 1) / \(questions.count)")
                        Spacer()
                        Text("✓ \(correctAnswers)")
                    }
                    .font(.caption.monospacedDigit())
                }
                .padding(.horizontal)

                Text(q.card.questionText(for: mode, showBack: reversed))
                    .font(.title.bold()).multilineTextAlignment(.center)
                    .padding().frame(maxWidth: .infinity, minHeight: 140)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                VStack(spacing: 10) {
                    ForEach(q.options.indices, id: \.self) { i in
                        Button {
                            selectedAnswer = i
                            if i == q.correct {
                                correctAnswers += 1
                                q.card.correctReviews += 1
                            }
                            q.card.totalReviews += 1
                        } label: {
                            HStack {
                                Text(q.options[i]).multilineTextAlignment(.leading)
                                Spacer()
                                if let s = selectedAnswer {
                                    if i == q.correct {
                                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.white)
                                    } else if i == s {
                                        Image(systemName: "xmark.circle.fill").foregroundStyle(.white)
                                    }
                                }
                            }
                            .padding().frame(maxWidth: .infinity, alignment: .leading)
                            .background(bg(for: i, q: q))
                            .foregroundStyle(fg(for: i, q: q))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(selectedAnswer != nil)
                    }
                }.padding(.horizontal)

                if selectedAnswer != nil {
                    Button {
                        if currentIndex == questions.count - 1 { finished = true }
                        else { currentIndex += 1; selectedAnswer = nil }
                    } label: {
                        Text(currentIndex == questions.count - 1 ? "Завершить" : "Дальше")
                            .frame(maxWidth: .infinity).padding()
                            .background(.blue).foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
            }
        }
        .transaction { $0.animation = nil }
        .navigationTitle("Test")
        .onAppear { start() }
    }

    private func bg(for i: Int, q: Q) -> Color {
        guard let s = selectedAnswer else { return Color(.secondarySystemBackground) }
        if i == q.correct { return .green }
        if i == s { return .red }
        return Color(.secondarySystemBackground)
    }
    private func fg(for i: Int, q: Q) -> Color {
        guard let s = selectedAnswer else { return .primary }
        return (i == q.correct || i == s) ? .white : .primary
    }

    private func start() {
        guard cards.count >= 4 else { return }
        let count = min(10, cards.count)
        let chosen = cards.shuffled().prefix(count)
        var qs: [Q] = []
        for card in chosen {
            let mode = card.deck?.mode ?? .classic
            let reversed = forceReversed ?? (card.deck?.isReversed ?? false)
            let correctAnswer = card.answerText(for: mode, showBack: reversed)
            let distractors = cards.filter { $0.id != card.id }
                .shuffled().prefix(3)
                .map { $0.answerText(for: $0.deck?.mode ?? .classic, showBack: forceReversed ?? ($0.deck?.isReversed ?? false)) }
            var opts = [correctAnswer] + distractors
            opts.shuffle()
            let correctIdx = opts.firstIndex(of: correctAnswer) ?? 0
            qs.append(Q(card: card, options: opts, correct: correctIdx))
        }
        questions = qs
        currentIndex = 0; selectedAnswer = nil; correctAnswers = 0; finished = false
    }
}

// MARK: - Match Core

struct MatchCoreView: View {
    let cards: [Card]
    var forceReversed: Bool? = nil

    struct Tile: Identifiable, Equatable {
        let id = UUID()
        let cardID: UUID
        let text: String
        let isQuestion: Bool
    }

    @State private var tiles: [Tile] = []
    @State private var selected: Tile?
    @State private var matched: Set<UUID> = []
    @State private var wrongPair: (Tile, Tile)?
    @State private var startTime: Date = Date()
    @State private var elapsed: TimeInterval = 0
    @State private var finished: Bool = false
    @State private var timer: Timer?
    @AppStorage("match_columnar") private var columnarMode: Bool = false
    private let poolSize = 6

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(timeString).font(.title3.monospacedDigit().bold())
                Spacer()
                Text("\(matched.count / 2) / \(poolSize)").font(.subheadline)
                Button { restart() } label: { Image(systemName: "arrow.clockwise") }
            }
            .padding(.horizontal)

            Toggle(isOn: Binding(
                get: { columnarMode },
                set: { columnarMode = $0; restart() }
            )) {
                Label("Слова слева, переводы справа", systemImage: "rectangle.split.2x1")
                    .font(.caption)
            }
            .padding(.horizontal)

            if finished {
                VStack(spacing: 16) {
                    Image(systemName: "trophy.fill").font(.system(size: 80)).foregroundStyle(.yellow)
                    Text("Готово!").font(.largeTitle.bold())
                    Text("Время: \(timeString)").font(.title3)
                    Button("Ещё раз") { restart() }.buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(tiles) { tile in
                        TileView(
                            tile: .init(cardID: tile.cardID, text: tile.text, isQuestion: tile.isQuestion),
                            isSelected: selected?.id == tile.id,
                            isMatched: matched.contains(tile.id),
                            isWrong: wrongPair?.0.id == tile.id || wrongPair?.1.id == tile.id
                        )
                        .onTapGesture { tap(tile) }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Match")
        .onAppear { restart() }
        .onDisappear { timer?.invalidate() }
    }

    private var timeString: String {
        let t = Int(elapsed)
        return String(format: "%02d:%02d", t / 60, t % 60)
    }

    private func restart() {
        let pool = Array(cards.shuffled().prefix(poolSize))
        var questions: [Tile] = []
        var answers: [Tile] = []
        for card in pool {
            let mode = card.deck?.mode ?? .classic
            let reversed = forceReversed ?? (card.deck?.isReversed ?? false)
            let q = card.matchQuestion(for: mode, showBack: reversed)
            let a = card.matchAnswer(for: mode, showBack: reversed)
            questions.append(Tile(cardID: card.id, text: q, isQuestion: true))
            answers.append(Tile(cardID: card.id, text: a, isQuestion: false))
        }
        if columnarMode {
            questions.shuffle()
            answers.shuffle()
            tiles = zip(questions, answers).flatMap { [$0.0, $0.1] }
        } else {
            tiles = (questions + answers).shuffled()
        }
        matched = []; selected = nil; wrongPair = nil; finished = false
        startTime = Date(); elapsed = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsed = Date().timeIntervalSince(startTime)
        }
    }

    private func tap(_ tile: Tile) {
        if matched.contains(tile.id) || wrongPair != nil { return }
        guard let current = selected else {
            selected = tile; return
        }
        if current.id == tile.id { return }
        if current.cardID == tile.cardID && current.isQuestion != tile.isQuestion {
            matched.insert(current.id); matched.insert(tile.id); selected = nil
            if matched.count == tiles.count { finished = true; timer?.invalidate() }
        } else {
            wrongPair = (current, tile)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongPair = nil; selected = nil
            }
        }
    }
}
