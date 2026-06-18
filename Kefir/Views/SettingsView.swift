import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var ctx
    @Query private var decks: [Deck]
    @State private var showResetConfirm = false
    @State private var showSampleConfirm = false
    @State private var resultMessage: String?
    @AppStorage("gemini_api_key") private var geminiKey: String = ""
    @State private var showKey: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Gemini AI") {
                    if showKey {
                        TextField("API ключ", text: $geminiKey)
                            .font(.system(.body, design: .monospaced))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    } else {
                        SecureField("API ключ", text: $geminiKey)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    Toggle("Показать ключ", isOn: $showKey)
                    Link(destination: URL(string: "https://aistudio.google.com/apikey")!) {
                        Label("Получить ключ (aistudio.google.com)", systemImage: "link")
                    }
                    Text("Ключ хранится локально. Используется для AI-генерации карточек и примеров. Бесплатный tier щедрый — хватит надолго.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Хранение") {
                    Label("Локально на устройстве", systemImage: "iphone")
                        .foregroundStyle(.blue)
                    Text("Все колоды и прогресс хранятся только на этом iPhone. Облачного синка нет — нужен платный Apple Developer ($99/год). Если удалишь приложение — данные пропадут.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Озвучка") {
                    Button {
                        SpeechService.shared.speak("Тест озвучки", language: "ru-RU")
                    } label: {
                        Label("Тест: русский", systemImage: "speaker.wave.2")
                    }
                    Button {
                        SpeechService.shared.speak("Hello, this is a test", language: "en-US")
                    } label: {
                        Label("Тест: английский", systemImage: "speaker.wave.2")
                    }
                    Button {
                        SpeechService.shared.speak("こんにちは、テストです", language: "ja-JP")
                    } label: {
                        Label("Тест: японский", systemImage: "speaker.wave.2")
                    }
                }

                Section("Данные") {
                    Button {
                        showSampleConfirm = true
                    } label: {
                        Label("Загрузить встроенные колоды", systemImage: "sparkles")
                    }
                    Text("Добавит японский (JLPT N5 + кана) и английский (1500 слов из B1-C1)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button {
                        FolderOrganizer.forceResync(context: ctx)
                        resultMessage = "✅ Проверены все папки и тематические колоды. Новое добавлено, существующее не тронуто."
                    } label: {
                        Label("Проверить / обновить папки", systemImage: "folder.badge.gearshape")
                    }
                    Text("Пересканирует структуру папок (🏠 Жизнь и быт, 🧳 Переезд, 🎨 Разное). Прогресс и созданные колоды сохраняются.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("Удалить все данные", systemImage: "trash")
                    }
                }

                Section("О приложении") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text(Self.appVersion).foregroundStyle(.secondary)
                    }
                    Text("Kefir — аналог Quizlet с SRS (алгоритм SM-2) и поддержкой японского.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Настройки")
            .confirmationDialog("Удалить всё?", isPresented: $showResetConfirm, titleVisibility: .visible) {
                Button("Удалить всё", role: .destructive) { resetAll() }
                Button("Отмена", role: .cancel) {}
            }
            .confirmationDialog("Добавить демо?", isPresented: $showSampleConfirm, titleVisibility: .visible) {
                Button("Добавить") { addSamples() }
                Button("Отмена", role: .cancel) {}
            }
            .alert("Результат", isPresented: Binding(
                get: { resultMessage != nil },
                set: { if !$0 { resultMessage = nil } }
            )) {
                Button("OK", role: .cancel) { resultMessage = nil }
            } message: {
                Text(resultMessage ?? "")
            }
        }
    }

    /// Версия и билд из бандла (источник — MARKETING_VERSION / CURRENT_PROJECT_VERSION).
    static var appVersion: String {
        let info = Bundle.main.infoDictionary
        let v = info?["CFBundleShortVersionString"] as? String ?? "—"
        let b = info?["CFBundleVersion"] as? String ?? "—"
        return "\(v) (\(b))"
    }

    private func resetAll() {
        for deck in decks { ctx.delete(deck) }
    }

    private func addSamples() {
        // Полная синхронизация встроенного контента (японский + английский словарь
        // + тематические колоды и папки). Идемпотентно: существующее не дублируется,
        // прогресс не трогается.
        resultMessage = SeedCoordinator.forceSync(context: ctx)
    }
}
