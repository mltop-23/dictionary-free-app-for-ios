import SwiftUI
import SwiftData

struct LearnView: View {
    let deck: Deck
    @Environment(\.modelContext) private var ctx

    @State private var queue: [Card] = []
    @State private var showAnswer: Bool = false
    @State private var sessionReviewed: Int = 0
    @State private var sessionCorrect: Int = 0
    @State private var sessionStart: Date = Date()
    @State private var dragOffset: CGSize = .zero
    @State private var dragAction: DragAction? = nil

    enum DragAction { case mastered, forgot }
    private let swipeThreshold: CGFloat = 100

    var body: some View {
        VStack(spacing: 16) {
            if let card = queue.first {
                // Прогресс сессии
                HStack {
                    Text("Осталось: \(queue.count)")
                    Spacer()
                    Button {
                        card.isFavorite.toggle()
                    } label: {
                        Image(systemName: card.isFavorite ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                    }
                    Text("✓ \(sessionCorrect)/\(sessionReviewed)")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline.monospacedDigit())
                .padding(.horizontal)

                // Карточка со свайпами
                ZStack {
                    CardFlipView(
                        card: card,
                        mode: deck.mode,
                        showAnswer: $showAnswer,
                        frontLang: deck.frontLanguage,
                        backLang: deck.backLanguage,
                        reversed: deck.isReversed
                    )
                    // Оверлей подсветки при свайпе
                    if let action = dragAction {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(action == .mastered ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                            .overlay(
                                VStack {
                                    Image(systemName: action == .mastered ? "checkmark.seal.fill" : "xmark.octagon.fill")
                                        .font(.system(size: 80))
                                        .foregroundStyle(.white)
                                    Text(action == .mastered ? "ГОТОВО" : "ЗАБЫЛ")
                                        .font(.title.bold())
                                        .foregroundStyle(.white)
                                }
                            )
                    }
                }
                .offset(x: dragOffset.width, y: 0)
                .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard showAnswer else { return }
                            dragOffset = value.translation
                            if value.translation.width > swipeThreshold {
                                dragAction = .mastered
                            } else if value.translation.width < -swipeThreshold {
                                dragAction = .forgot
                            } else {
                                dragAction = nil
                            }
                        }
                        .onEnded { value in
                            guard showAnswer else {
                                dragOffset = .zero
                                return
                            }
                            if value.translation.width > swipeThreshold {
                                completeSwipe(mastered: true, card: card)
                            } else if value.translation.width < -swipeThreshold {
                                completeSwipe(mastered: false, card: card)
                            } else {
                                withAnimation(.spring) { dragOffset = .zero; dragAction = nil }
                            }
                        }
                )
                .padding(.horizontal)

                // Кнопки оценки
                if showAnswer {
                    gradeButtons(for: card)
                } else {
                    Button {
                        withAnimation(.spring) { showAnswer = true }
                    } label: {
                        Text("Показать ответ")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
            } else {
                ContentUnavailableView {
                    Label("Всё на сегодня!", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                } description: {
                    if sessionReviewed > 0 {
                        Text("Повторено: \(sessionReviewed), правильно: \(sessionCorrect)")
                    } else {
                        Text("Нет карточек к повтору. Добавь новые или подожди.")
                    }
                }
            }
        }
        .navigationTitle("Learn")
        .onAppear { loadQueueOnce() }
        .onDisappear { saveSession() }
    }

    private func gradeButtons(for card: Card) -> some View {
        let previews = SRSEngine.previewIntervals(for: card)
        return HStack(spacing: 6) {
            ForEach([SRSGrade.again, .heard, .hard, .good, .easy], id: \.rawValue) { grade in
                Button {
                    apply(grade: grade, to: card)
                } label: {
                    VStack(spacing: 2) {
                        Text(grade.title).font(.caption.bold())
                        Text(previews[grade] ?? "").font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(color(for: grade))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(.horizontal)
    }

    private func color(for grade: SRSGrade) -> Color {
        switch grade {
        case .again: return .red
        case .heard: return Color(red: 0.8, green: 0.4, blue: 0.2)
        case .hard: return .orange
        case .good: return .blue
        case .easy: return .green
        }
    }

    private func loadQueueOnce() {
        guard queue.isEmpty && sessionReviewed == 0 else { return }
        let due = deck.cards.filter { $0.dueAt <= Date() }
        let learning = due.filter { $0.stage == .learning || $0.stage == .review }
        let new = due.filter { $0.stage == .new }.prefix(20)
        queue = (learning + Array(new)).shuffled()
    }

    private func apply(grade: SRSGrade, to card: Card) {
        SRSEngine.apply(grade: grade, to: card)
        sessionReviewed += 1
        if grade == .good || grade == .easy { sessionCorrect += 1 }
        queue.removeFirst()
        // Если "Забыл" или "Слышал" — вернуть в конец очереди
        if grade == .again || grade == .heard {
            queue.append(card)
        }
        showAnswer = false
    }

    private func completeSwipe(mastered: Bool, card: Card) {
        // Анимация вылета карточки за экран
        let direction: CGFloat = mastered ? 1 : -1
        withAnimation(.easeOut(duration: 0.25)) {
            dragOffset = CGSize(width: direction * 500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if mastered {
                // Прямой маркер «Готово»
                card.stage = .mastered
                card.intervalDays = 90
                card.repetitions = max(card.repetitions, 5)
                card.dueAt = Date().addingTimeInterval(90 * 86400)
                card.lastReviewedAt = Date()
                card.totalReviews += 1
                card.correctReviews += 1
                sessionReviewed += 1
                sessionCorrect += 1
                queue.removeFirst()
            } else {
                apply(grade: .again, to: card)
            }
            dragOffset = .zero
            dragAction = nil
            showAnswer = false
        }
    }

    private func saveSession() {
        guard sessionReviewed > 0 else { return }
        let today = Calendar.current.startOfDay(for: Date())
        let desc = FetchDescriptor<StudyLog>(
            predicate: #Predicate { $0.date == today }
        )
        let log: StudyLog
        if let existing = try? ctx.fetch(desc).first {
            log = existing
        } else {
            log = StudyLog(date: today)
            ctx.insert(log)
        }
        log.cardsReviewed += sessionReviewed
        log.cardsCorrect += sessionCorrect
        log.secondsSpent += Int(Date().timeIntervalSince(sessionStart))
    }
}
