import Foundation
import Combine

struct RepoUsage: Identifiable, Codable {
    var id: String { repo }
    let repo: String
    let org: String
    let genre: String
    let tools: [String: Int]
    let session: SessionMetrics
    let edits: [String: EditMetrics]

    var totalToolCalls: Int { tools.values.reduce(0, +) }
    var skillCalls: Int { tools.filter { $0.key.hasPrefix("Skill:") }.values.reduce(0, +) }
    var mcpCalls: Int { tools.filter { $0.key.hasPrefix("MCP:") }.values.reduce(0, +) }
    var subagentCalls: Int { tools.filter { $0.key.hasPrefix("Subagent:") }.values.reduce(0, +) }
    var promptCount: Int { session.prompt }
    var sessionCount: Int { session.instructionLoad }

    var topSkills: [(name: String, count: Int)] {
        tools.filter { $0.key.hasPrefix("Skill:") }
            .map { (String($0.key.dropFirst(6)), $0.value) }
            .sorted { $0.count > $1.count }
    }

    var topMCP: [(name: String, count: Int)] {
        tools.filter { $0.key.hasPrefix("MCP:") }
            .map { (shortMCPName(String($0.key.dropFirst(4))), $0.value) }
            .sorted { $0.count > $1.count }
    }

    private func shortMCPName(_ raw: String) -> String {
        let parts = raw.split(separator: "_", maxSplits: 4, omittingEmptySubsequences: false)
            .filter { !$0.isEmpty }
        guard parts.count >= 3 else { return raw }
        return "\(parts[1])/\(parts[2])"
    }

    enum CodingKeys: String, CodingKey {
        case repo = "_repo"
        case org = "_org"
        case genre = "_genre"
        case tools, session, edits
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        repo = try c.decodeIfPresent(String.self, forKey: .repo) ?? "unknown"
        org = try c.decodeIfPresent(String.self, forKey: .org) ?? "unknown"
        genre = try c.decodeIfPresent(String.self, forKey: .genre) ?? "other"
        tools = try c.decodeIfPresent([String: Int].self, forKey: .tools) ?? [:]
        session = try c.decodeIfPresent(SessionMetrics.self, forKey: .session) ?? SessionMetrics()
        edits = try c.decodeIfPresent([String: EditMetrics].self, forKey: .edits) ?? [:]
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(repo, forKey: .repo)
        try c.encode(org, forKey: .org)
        try c.encode(genre, forKey: .genre)
        try c.encode(tools, forKey: .tools)
        try c.encode(session, forKey: .session)
        try c.encode(edits, forKey: .edits)
    }
}

struct SessionMetrics: Codable {
    var prompt: Int = 0
    var instructionLoad: Int = 0

    enum CodingKeys: String, CodingKey {
        case prompt = "Prompt"
        case instructionLoad = "InstructionLoad"
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        prompt = try c.decodeIfPresent(Int.self, forKey: .prompt) ?? 0
        instructionLoad = try c.decodeIfPresent(Int.self, forKey: .instructionLoad) ?? 0
    }
}

struct EditMetrics: Codable {
    var added: Int = 0
    var deleted: Int = 0
}

struct GenreSummary: Identifiable {
    let genre: String
    var id: String { genre }
    var totalTools: Int = 0
    var skills: Int = 0
    var mcp: Int = 0
    var subagents: Int = 0
    var prompts: Int = 0
    var sessions: Int = 0
    var repos: [RepoUsage] = []
}

@MainActor
final class UsageStore: ObservableObject {
    @Published var repos: [RepoUsage] = []
    @Published var genres: [GenreSummary] = []
    @Published var lastUpdated: Date?

    private let usageDir: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/usage")
    }()

    func reload() {
        let fm = FileManager.default
        var allRepos: [RepoUsage] = []

        guard let orgDirs = try? fm.contentsOfDirectory(
            at: usageDir, includingPropertiesForKeys: nil
        ) else { return }

        for orgDir in orgDirs where orgDir.hasDirectoryPath {
            guard let files = try? fm.contentsOfDirectory(
                at: orgDir, includingPropertiesForKeys: nil
            ) else { continue }

            for file in files where file.pathExtension == "json" {
                guard let data = try? Data(contentsOf: file),
                      let usage = try? JSONDecoder().decode(RepoUsage.self, from: data)
                else { continue }
                allRepos.append(usage)
            }
        }

        repos = allRepos.sorted { $0.totalToolCalls > $1.totalToolCalls }

        var genreMap: [String: GenreSummary] = [:]
        for repo in repos {
            var g = genreMap[repo.genre] ?? GenreSummary(genre: repo.genre)
            g.totalTools += repo.totalToolCalls
            g.skills += repo.skillCalls
            g.mcp += repo.mcpCalls
            g.subagents += repo.subagentCalls
            g.prompts += repo.promptCount
            g.sessions += repo.sessionCount
            g.repos.append(repo)
            genreMap[repo.genre] = g
        }
        genres = genreMap.values.sorted { $0.totalTools > $1.totalTools }
        lastUpdated = Date()
    }

    var totalSkills: Int { repos.reduce(0) { $0 + $1.skillCalls } }
    var totalMCP: Int { repos.reduce(0) { $0 + $1.mcpCalls } }
    var totalSubagents: Int { repos.reduce(0) { $0 + $1.subagentCalls } }
    var totalPrompts: Int { repos.reduce(0) { $0 + $1.promptCount } }
    var totalSessions: Int { repos.reduce(0) { $0 + $1.sessionCount } }
}
