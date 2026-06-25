import SwiftUI

struct PopoverView: View {
    @ObservedObject var store: UsageStore
    @State private var selectedGenre: String?

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    summaryCards
                    genreSection
                    repoSection
                }
                .padding(16)
            }
        }
        .frame(width: 420, height: 520)
    }

    private var header: some View {
        HStack {
            Image(systemName: "chart.bar.fill")
                .foregroundStyle(.secondary)
            Text("Claude Code Usage")
                .font(.headline)
            Spacer()
            if let date = store.lastUpdated {
                Text(date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Button {
                store.reload()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "xmark.circle")
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var summaryCards: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            MetricCard(label: "Skills", value: store.totalSkills, color: .purple)
            MetricCard(label: "MCP", value: store.totalMCP, color: .green)
            MetricCard(label: "Agents", value: store.totalSubagents, color: .orange)
            MetricCard(label: "Prompts", value: store.totalPrompts, color: .blue)
        }
    }

    private var genreSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("By genre")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(store.genres) { genre in
                GenreRow(genre: genre, isSelected: selectedGenre == genre.genre)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedGenre = selectedGenre == genre.genre ? nil : genre.genre
                        }
                    }
            }
        }
    }

    private var filteredRepos: [RepoUsage] {
        if let g = selectedGenre {
            return store.repos.filter { $0.genre == g }
        }
        return store.repos
    }

    private var repoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(selectedGenre.map { "Repos (\($0))" } ?? "All repos")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(filteredRepos) { repo in
                RepoRow(repo: repo)
            }
        }
    }
}

struct MetricCard: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(formatNumber(value))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }

    private func formatNumber(_ n: Int) -> String {
        if n >= 1000 {
            return String(format: "%.1fk", Double(n) / 1000.0)
        }
        return "\(n)"
    }
}

struct GenreRow: View {
    let genre: GenreSummary
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: genreIcon)
                .frame(width: 16)
                .foregroundStyle(genreColor)
            Text(genre.genre)
                .font(.callout)
                .fontWeight(.medium)
            Spacer()
            HStack(spacing: 12) {
                StatPill(icon: "wand.and.stars", value: genre.skills, color: .purple)
                StatPill(icon: "link", value: genre.mcp, color: .green)
                StatPill(icon: "text.bubble", value: genre.prompts, color: .blue)
            }
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .rotationEffect(.degrees(isSelected ? 90 : 0))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            isSelected ? AnyShapeStyle(genreColor.opacity(0.08)) : AnyShapeStyle(.clear),
            in: RoundedRectangle(cornerRadius: 6)
        )
        .contentShape(Rectangle())
    }

    private var genreIcon: String {
        switch genre.genre {
        case "work": return "building.2"
        case "personal": return "person"
        case "side-project": return "hammer"
        default: return "folder"
        }
    }

    private var genreColor: Color {
        switch genre.genre {
        case "work": return .blue
        case "personal": return .purple
        case "side-project": return .orange
        default: return .gray
        }
    }
}

struct StatPill: View {
    let icon: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text("\(value)")
                .font(.system(size: 11, design: .rounded))
        }
        .foregroundStyle(color)
    }
}

struct RepoRow: View {
    let repo: RepoUsage
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "shippingbox")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(repo.repo)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .lineLimit(1)
                Spacer()
                Text("\(repo.totalToolCalls)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isExpanded.toggle()
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 16) {
                        MiniStat(label: "Skills", value: repo.skillCalls, color: .purple)
                        MiniStat(label: "MCP", value: repo.mcpCalls, color: .green)
                        MiniStat(label: "Agents", value: repo.subagentCalls, color: .orange)
                        MiniStat(label: "Prompts", value: repo.promptCount, color: .blue)
                    }

                    if !repo.topSkills.isEmpty {
                        Text("Top skills")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        FlowLayout(spacing: 4) {
                            ForEach(repo.topSkills.prefix(5), id: \.name) { skill in
                                Text("\(skill.name) (\(skill.count))")
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.purple.opacity(0.1), in: Capsule())
                            }
                        }
                    }

                    if !repo.topMCP.isEmpty {
                        Text("Top MCP")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        FlowLayout(spacing: 4) {
                            ForEach(repo.topMCP.prefix(5), id: \.name) { tool in
                                Text("\(tool.name) (\(tool.count))")
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.green.opacity(0.1), in: Capsule())
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .padding(.leading, 24)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.quaternary.opacity(0.5))
        )
    }
}

struct MiniStat: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 1) {
            Text("\(value)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
