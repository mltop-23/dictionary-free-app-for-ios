import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            DeckListView()
                .tabItem { Label("Колоды", systemImage: "rectangle.stack") }

            NavigationStack { FavoritesView() }
                .tabItem { Label("Избранное", systemImage: "star.fill") }

            DictionaryView()
                .tabItem { Label("Словарь", systemImage: "character.book.closed") }


            NavigationStack { SearchView() }
                .tabItem { Label("Поиск", systemImage: "magnifyingglass") }

            ReferenceView()
                .tabItem { Label("Справочник", systemImage: "book") }

            StatsView()
                .tabItem { Label("Статистика", systemImage: "chart.bar.fill") }

            SettingsView()
                .tabItem { Label("Настройки", systemImage: "gearshape") }
        }
    }
}
