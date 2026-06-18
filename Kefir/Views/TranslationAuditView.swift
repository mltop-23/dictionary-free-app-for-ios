import SwiftUI
import SwiftData

// Проверяет переводы всех карточек колоды через Gemini и показывает найденные проблемы.
// Пользователь может принять исправление или отклонить.
struct TranslationAuditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx

    let deck: Deck

    @State private var issues: [GeminiService.TranslationIssue] = []
    @State private var isLoading = false
    @State private var progressText: String = ""
    @State private var errorMsg: String?
    @State private var handled = Set<UUID>()  // card id → уже обработано

    private var remaining: [GeminiService.TranslationIssue] {
        issues.filter { !handled.contains($0.cardID) }
    }

    var body: some View {
        NavigationStack {
            List {
                if deck.mode != .classic {
                    Section {
                        Text("AI-аудит работает только для классических англо-русских колод. Для японских пока не поддерживается.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Section("Колода") {
                        HStack {
                            Text(deck.name).font(.headline)
                            Spacer()
                            Text("\(deck.cards.count) карт")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section {
                        Button {
                            Task { await runAudit() }
                        } label: {
                            if isLoading {
                                HStack {
                                    ProgressView()
                                    Text(progressText.isEmpty ? "Gemini думает…" : progressText)
                                }
                            } else if issues.isEmpty {
                                Label("Запустить проверку", systemImage: "sparkles")
                            } else {
                                Label("Запустить повторно", systemImage: "arrow.clockwise")
                            }
                        }
                        .disabled(isLoading)
                        Text("Gemini проверит все \(deck.cards.count) карточек (батчами по 30). Займёт ~\((deck.cards.count / 30 + 1) * 5) секунд. Использует твой API ключ.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let err = errorMsg {
                        Section { Text(err).foregroundStyle(.red).font(.callout) }
                    }

                    if !issues.isEmpty {
                        Section("Найдено проблем: \(issues.count), осталось \(remaining.count)") {
                            if remaining.isEmpty {
                                Label("Все проблемы обработаны!", systemImage: "checkmark.seal.fill")
                                    .foregroundStyle(.green)
                            } else {
                                ForEach(remaining, id: \.id) { issue in
                                    IssueRow(issue: issue) { decision in
                                        apply(decision: decision, issue: issue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("AI-аудит")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }

    private func runAudit() async {
        isLoading = true
        errorMsg = nil
        issues = []
        handled = []
        progressText = "Gemini думает..."
        defer { isLoading = false; progressText = "" }
        do {
            issues = try await GeminiService.shared.auditTranslations(cards: deck.cards)
            if issues.isEmpty {
                errorMsg = "✅ Gemini не нашёл очевидных проблем"
            }
        } catch {
            errorMsg = "Ошибка: \(error.localizedDescription)"
        }
    }

    enum Decision { case accept, reject }

    private func apply(decision: Decision, issue: GeminiService.TranslationIssue) {
        if decision == .accept {
            if let card = deck.cards.first(where: { $0.id == issue.cardID }) {
                card.back = issue.suggestedBack
                card.updatedAt = Date()
            }
        }
        handled.insert(issue.cardID)
    }
}

struct IssueRow: View {
    let issue: GeminiService.TranslationIssue
    let onDecision: (TranslationAuditView.Decision) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(issue.front)
                .font(.headline)

            Text(issue.issue)
                .font(.caption)
                .foregroundStyle(.orange)

            HStack {
                VStack(alignment: .leading) {
                    Text("Сейчас:").font(.caption2).foregroundStyle(.secondary)
                    Text(issue.currentBack)
                        .strikethrough()
                        .foregroundStyle(.red)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)
                Spacer()
                VStack(alignment: .leading) {
                    Text("Предложено:").font(.caption2).foregroundStyle(.secondary)
                    Text(issue.suggestedBack)
                        .foregroundStyle(.green)
                        .bold()
                }
            }
            .font(.callout)

            HStack(spacing: 10) {
                Button {
                    onDecision(.reject)
                } label: {
                    Label("Оставить как есть", systemImage: "xmark")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
                Button {
                    onDecision(.accept)
                } label: {
                    Label("Принять", systemImage: "checkmark")
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(.green)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
