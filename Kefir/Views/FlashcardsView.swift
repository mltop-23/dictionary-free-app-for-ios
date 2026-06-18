import SwiftUI

struct FlashcardsView: View {
    let deck: Deck
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
                // Прогресс
                HStack {
                    Text("\(index + 1) / \(shuffled.count)")
                        .font(.subheadline.monospacedDigit())
                    Spacer()
                    Button {
                        shuffled[index].isFavorite.toggle()
                    } label: {
                        Image(systemName: shuffled[index].isFavorite ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                    }
                    Button {
                        toggleShuffle()
                    } label: {
                        Image(systemName: isShuffled ? "shuffle.circle.fill" : "shuffle")
                    }
                }
                .padding(.horizontal)

                // Карточка со свайпами
                CardFlipView(
                    card: shuffled[index],
                    mode: deck.mode,
                    showAnswer: $showAnswer,
                    frontLang: deck.frontLanguage,
                    backLang: deck.backLanguage,
                    reversed: deck.isReversed
                )
                .overlay(
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
                            let card = shuffled[index]

                            if absV > absH && v.translation.height < -vThreshold && showAnswer {
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

                // Кнопки навигации
                HStack(spacing: 24) {
                    Button { prev() } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.largeTitle)
                    }
                    .disabled(index == 0)

                    Button {
                        withAnimation(.spring) { showAnswer.toggle() }
                    } label: {
                        Text(showAnswer ? "Скрыть" : "Показать")
                            .frame(minWidth: 120)
                            .padding(.vertical, 10)
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }

                    Button { next() } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.largeTitle)
                    }
                    .disabled(index >= shuffled.count - 1)
                }
                .padding()
            }
        }
        .navigationTitle("Карточки")
        .onAppear { loadOnce() }
    }

    private func loadOnce() {
        guard shuffled.isEmpty else { return }
        shuffled = deck.cards
    }

    private func toggleShuffle() {
        isShuffled.toggle()
        shuffled = isShuffled ? deck.cards.shuffled() : deck.cards
        index = 0
        showAnswer = false
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
        index -= 1
        showAnswer = false
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
                Button { restart() } label: {
                    Label("Начать заново", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity).padding()
                        .background(.blue).foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button {
                    isShuffled = true
                    shuffled = deck.cards.shuffled()
                    restart()
                } label: {
                    Label("Перемешать и начать", systemImage: "shuffle")
                        .frame(maxWidth: .infinity).padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button { dismiss() } label: {
                    Text("На главную").frame(maxWidth: .infinity).padding()
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
}

struct CardFlipView: View {
    let card: Card
    let mode: DeckMode
    @Binding var showAnswer: Bool
    let frontLang: String
    let backLang: String
    var reversed: Bool = false

    private var questionText: String { card.questionText(for: mode, showBack: reversed) }
    private var answerText: String { card.answerText(for: mode, showBack: reversed) }
    private var questionLang: String {
        switch mode {
        case .classic: return reversed ? backLang : frontLang
        case .japanese: return reversed ? "ru-RU" : "ja-JP"
        }
    }
    private var answerLang: String {
        switch mode {
        case .classic: return reversed ? frontLang : backLang
        case .japanese: return reversed ? "ja-JP" : "ru-RU"
        }
    }

    // IPA берётся для английского слова (front при classic)
    private var transcription: String? {
        guard mode == .classic else { return nil }
        let word = reversed ? card.back : card.front
        // IPA есть только для английских слов; проверим, что язык стороны — английский
        let lang = reversed ? backLang : frontLang
        guard lang.hasPrefix("en") else { return nil }
        return TranscriptionService.shared.ipa(for: word)
    }

    // Синонимы из тезауруса — только если в example их ещё нет
    private var bundledSynonyms: String? {
        guard mode == .classic else { return nil }
        let lang = reversed ? backLang : frontLang
        guard lang.hasPrefix("en") else { return nil }
        // Если в example уже «Синонимы: ...» — не дублируем
        if card.example.lowercased().contains("синоним") { return nil }
        let word = reversed ? card.back : card.front
        return SynonymsService.shared.synonymsString(for: word, limit: 5)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10)

            VStack(spacing: 16) {
                if showAnswer {
                    Text(answerText)
                        .font(mode == .japanese ? .title2 : .title)
                        .multilineTextAlignment(.center)
                        .padding()
                    // IPA транскрипция для английского
                    if mode == .classic, let ipa = transcription {
                        Text(ipa)
                            .font(.title3.monospaced())
                            .foregroundStyle(.blue)
                    }
                    if !card.example.isEmpty {
                        Divider()
                        Text(card.example)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .italic()
                            .padding(.horizontal)
                    }
                    // Синонимы из тезауруса (если нет уже в example)
                    if mode == .classic, let syns = bundledSynonyms {
                        Divider()
                        VStack(spacing: 2) {
                            Text("Синонимы")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            Text(syns)
                                .font(.callout)
                                .foregroundStyle(.purple)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Text(questionText)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Button {
                    let lang = showAnswer ? answerLang : questionLang
                    let text = showAnswer ? answerText : questionText
                    SpeechService.shared.speak(text, language: lang)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title3)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 320)
        .onTapGesture {
            withAnimation(.spring) { showAnswer.toggle() }
        }
    }
}
