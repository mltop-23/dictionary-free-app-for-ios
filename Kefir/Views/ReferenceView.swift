import SwiftUI

// Справочник: таблицы грамматики по языкам
struct ReferenceView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(GrammarData.all) { section in
                    Section {
                        ForEach(section.topics) { topic in
                            NavigationLink {
                                TopicDetailView(topic: topic)
                            } label: {
                                Label {
                                    Text(topic.title).font(.body)
                                } icon: {
                                    Image(systemName: topic.icon)
                                }
                            }
                        }
                    } header: {
                        Label(section.name, systemImage: section.icon)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("📖 Справочник")
        }
    }
}

struct TopicDetailView: View {
    let topic: GrammarData.Topic

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(topic.intro)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Заголовок
                        headerRow
                        // Данные
                        ForEach(topic.rows.indices, id: \.self) { row in
                            dataRow(row)
                        }
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            ForEach(topic.columns.indices, id: \.self) { col in
                Text(topic.columns[col])
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
                    .frame(width: colWidth(col), alignment: .center)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.2))
                    .border(Color(.separator).opacity(0.3), width: 0.5)
            }
        }
    }

    private func dataRow(_ row: Int) -> some View {
        HStack(spacing: 0) {
            ForEach(safeRow(row).indices, id: \.self) { col in
                cellView(text: safeRow(row)[col], row: row, col: col)
                    .frame(width: colWidth(col))
                    .padding(.vertical, 6)
                    .background(row % 2 == 0 ? Color(.secondarySystemBackground) : Color(.systemBackground))
                    .border(Color(.separator).opacity(0.15), width: 0.5)
            }
        }
    }

    private func safeRow(_ row: Int) -> [String] {
        let r = topic.rows[row]
        // Дополняем пустыми если строка короче заголовка
        if r.count >= topic.columns.count { return r }
        return r + Array(repeating: "", count: topic.columns.count - r.count)
    }

    @ViewBuilder
    private func cellView(text: String, row: Int, col: Int) -> some View {
        if text.contains("\n") {
            // Двухстрочная ячейка (кана + ромадзи)
            let parts = text.split(separator: "\n", maxSplits: 1)
            VStack(spacing: 2) {
                Text(parts.first ?? "")
                    .font(.title3)
                if parts.count > 1 {
                    Text(parts[1])
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        } else if col == 0 {
            Text(text)
                .font(.caption.bold())
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 4)
        } else {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 4)
                .multilineTextAlignment(.leading)
        }
    }

    private func colWidth(_ col: Int) -> CGFloat {
        let total = topic.columns.count
        if total <= 3 { return 130 }
        if total == 4 { return 100 }
        if total == 5 && col == 0 { return 60 }
        if total == 5 { return 95 }
        if total == 6 && col == 0 { return 40 }
        if total == 6 { return 65 }
        if col == 0 { return 60 }
        return 85
    }
}