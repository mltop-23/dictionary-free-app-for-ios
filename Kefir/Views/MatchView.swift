import SwiftUI

struct MatchView: View {
    let deck: Deck

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

    private let poolSize = 6  // 6 пар = 12 плиток

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
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.yellow)
                    Text("Готово!").font(.largeTitle.bold())
                    Text("Время: \(timeString)").font(.title3)
                    Button("Ещё раз") { restart() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(tiles) { tile in
                        TileView(
                            tile: tile,
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
        let pool = Array(deck.cards.shuffled().prefix(poolSize))
        var questions: [Tile] = []
        var answers: [Tile] = []
        for card in pool {
            let q = card.matchQuestion(for: deck.mode, showBack: deck.isReversed)
            let a = card.matchAnswer(for: deck.mode, showBack: deck.isReversed)
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
        matched = []
        selected = nil
        wrongPair = nil
        finished = false
        startTime = Date()
        elapsed = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsed = Date().timeIntervalSince(startTime)
        }
    }

    private func tap(_ tile: Tile) {
        if matched.contains(tile.id) { return }
        if wrongPair != nil { return }
        guard let current = selected else {
            selected = tile
            return
        }
        if current.id == tile.id { return }

        if current.cardID == tile.cardID && current.isQuestion != tile.isQuestion {
            matched.insert(current.id)
            matched.insert(tile.id)
            selected = nil
            if matched.count == tiles.count {
                finished = true
                timer?.invalidate()
            }
        } else {
            wrongPair = (current, tile)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongPair = nil
                selected = nil
            }
        }
    }
}

struct TileView: View {
    let tile: MatchView.Tile
    let isSelected: Bool
    let isMatched: Bool
    let isWrong: Bool

    var body: some View {
        Text(tile.text)
            .font(.callout)
            .multilineTextAlignment(.center)
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .blue : .clear, lineWidth: 2)
            )
            .opacity(isMatched ? 0.3 : 1)
            .scaleEffect(isSelected ? 1.03 : 1)
            .animation(.spring, value: isSelected)
    }

    private var background: Color {
        if isWrong { return .red.opacity(0.3) }
        if isMatched { return .green.opacity(0.3) }
        return Color(.secondarySystemBackground)
    }

    private var foreground: Color {
        .primary
    }
}
