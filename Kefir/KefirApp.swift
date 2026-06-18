import SwiftUI
import SwiftData

@main
struct KefirApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Deck.self, Card.self, StudyLog.self, Folder.self])
        // Хранение полностью локальное — Personal Team не поддерживает CloudKit.
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    @State private var ready = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if ready {
                    ContentView()
                        .transition(.opacity)
                }
                if !ready {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .task {
                let start = Date()
                // Начальная подготовка: до-засеиваем встроенный контент, если он
                // обновился или это первый запуск. Аддитивно и без удаления данных —
                // см. SeedCoordinator. Так новые встроенные колоды доезжают и до уже
                // установленного приложения, не затирая прогресс.
                let ctx = sharedModelContainer.mainContext
                SeedCoordinator.syncIfNeeded(context: ctx)
                // Минимум 0.9 с для красоты (если уже готово — не ждём)
                let elapsed = Date().timeIntervalSince(start)
                if elapsed < 0.9 {
                    try? await Task.sleep(nanoseconds: UInt64((0.9 - elapsed) * 1_000_000_000))
                }
                withAnimation(.easeOut(duration: 0.4)) { ready = true }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
