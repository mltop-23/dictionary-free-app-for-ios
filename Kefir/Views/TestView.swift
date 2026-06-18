import SwiftUI

struct TestView: View {
    let deck: Deck

    struct Question {
        let card: Card
        let options: [String]   // 4 варианта
        let correct: Int        // индекс правильного
    }

    @State private var questions: [Question] = []
    @State private var currentIndex: Int = 0
    @State private var selectedAnswer: Int?
    @State private var correctAnswers: Int = 0
    @State private var finished: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            if finished {
                resultScreen
                    .transaction { $0.animation = nil }
            } else if let q = questions[safe: currentIndex] {
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

                VStack(spacing: 20) {
                    // Вопрос
                    Text(q.card.questionText(for: deck.mode, showBack: deck.isReversed))
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 140)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)

                    // Варианты
                    VStack(spacing: 10) {
                        ForEach(q.options.indices, id: \.self) { i in
                            Button {
                                selectAnswer(i)
                            } label: {
                                HStack {
                                    Text(q.options[i])
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    if let selected = selectedAnswer {
                                        if i == q.correct {
                                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.white)
                                        } else if i == selected {
                                            Image(systemName: "xmark.circle.fill").foregroundStyle(.white)
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(background(for: i, q: q))
                                .foregroundStyle(foreground(for: i, q: q))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(selectedAnswer != nil)
                        }
                    }
                    .padding(.horizontal)

                    if selectedAnswer != nil {
                        Button {
                            next()
                        } label: {
                            Text(currentIndex == questions.count - 1 ? "Завершить" : "Дальше")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    }
                }
                .animation(nil, value: selectedAnswer)
                .animation(nil, value: currentIndex)
            }
        }
        .transaction { $0.animation = nil }
        .navigationTitle("Test")
        .onAppear { start() }
    }

    private var resultScreen: some View {
        VStack(spacing: 16) {
            let pct = Int(Double(correctAnswers) / Double(max(questions.count, 1)) * 100)
            Image(systemName: pct >= 80 ? "star.fill" : (pct >= 50 ? "hand.thumbsup.fill" : "arrow.clockwise.circle.fill"))
                .font(.system(size: 80))
                .foregroundStyle(pct >= 80 ? .yellow : .blue)
            Text("\(correctAnswers) / \(questions.count)")
                .font(.largeTitle.bold())
            Text("\(pct)%").font(.title2).foregroundStyle(.secondary)
            Button("Ещё раз") { start() }
                .buttonStyle(.borderedProminent)
        }
    }

    private func background(for index: Int, q: Question) -> Color {
        guard let selected = selectedAnswer else {
            return Color(.secondarySystemBackground)
        }
        if index == q.correct { return .green }
        if index == selected { return .red }
        return Color(.secondarySystemBackground)
    }

    private func foreground(for index: Int, q: Question) -> Color {
        guard let selected = selectedAnswer else { return .primary }
        if index == q.correct || index == selected { return .white }
        return .primary
    }

    private func start() {
        let all = deck.cards
        guard all.count >= 4 else { return }
        let count = min(10, all.count)
        let chosen = all.shuffled().prefix(count)
        var qs: [Question] = []
        for card in chosen {
            let correctAnswer = card.answerText(for: deck.mode, showBack: deck.isReversed)
            let distractors = all.filter { $0.id != card.id }
                .shuffled()
                .prefix(3)
                .map { $0.answerText(for: deck.mode, showBack: deck.isReversed) }
            var opts = [correctAnswer] + distractors
            opts.shuffle()
            let correctIdx = opts.firstIndex(of: correctAnswer) ?? 0
            qs.append(Question(card: card, options: opts, correct: correctIdx))
        }
        questions = qs
        currentIndex = 0
        selectedAnswer = nil
        correctAnswers = 0
        finished = false
    }

    private func selectAnswer(_ i: Int) {
        selectedAnswer = i
        let q = questions[currentIndex]
        if i == q.correct {
            correctAnswers += 1
            q.card.correctReviews += 1
        }
        q.card.totalReviews += 1
    }

    private func next() {
        if currentIndex == questions.count - 1 {
            finished = true
        } else {
            currentIndex += 1
            selectedAnswer = nil
        }
    }
}

extension Array {
    subscript(safe idx: Int) -> Element? {
        indices.contains(idx) ? self[idx] : nil
    }
}
