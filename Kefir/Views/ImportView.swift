import SwiftUI
import SwiftData

struct ImportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx

    let deck: Deck
    @State private var text: String = ""
    @State private var preview: [Card] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(hint)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        TextEditor(text: $text)
                            .font(.system(.body, design: .monospaced))
                            .frame(minHeight: 200)
                            .padding(.horizontal)
                            .onChange(of: text) { _, new in
                                preview = ImportService.parse(new, mode: deck.mode)
                            }

                        if !preview.isEmpty {
                            Text("Превью (\(preview.count)):")
                                .font(.headline)
                                .padding(.horizontal)
                            ForEach(preview.prefix(10), id: \.id) { card in
                                HStack {
                                    Text(card.questionText(for: deck.mode))
                                        .font(.callout)
                                    Spacer()
                                    Text("→")
                                    Spacer()
                                    Text(card.answerText(for: deck.mode))
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal)
                            }
                            if preview.count > 10 {
                                Text("+ ещё \(preview.count - 10)…")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Импорт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Импорт (\(preview.count))") { doImport() }
                        .disabled(preview.isEmpty)
                }
            }
        }
    }

    private var hint: String {
        switch deck.mode {
        case .classic:
            return """
            Формат: front<разделитель>back
            Разделители: Tab, |, ; (автоопределение)

            Примеры:
            hello|привет
            world|мир
            good morning | доброе утро
            """
        case .japanese:
            return """
            Форматы (разделитель: |, Tab, ;):

            kanji | meaning
            kana | meaning
            kanji | kana | meaning
            kanji | kana | romaji | meaning

            Пример:
            食べる | たべる | taberu | есть
            猫 | ねこ | кошка
            """
        }
    }

    private func doImport() {
        for card in preview {
            card.deck = deck
            deck.cards.append(card)
            ctx.insert(card)
        }
        deck.updatedAt = Date()
        dismiss()
    }
}
