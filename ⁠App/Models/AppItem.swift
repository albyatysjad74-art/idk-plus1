import Foundation

enum AppCategory: String, CaseIterable, Codable {
    case all = "all"
    case social = "social"
    case games = "games"
    case tools = "tools"
    case tweaks = "tweaks"

    func title(using loc: LocalizationManager) -> String {
        switch self {
        case .all: return loc.tr("all")
        case .social: return loc.tr("social")
        case .games: return loc.tr("games")
        case .tools: return loc.tr("tools")
        case .tweaks: return loc.tr("tweaks")
        }
    }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .social: return "message.fill"
        case .games: return "gamecontroller.fill"
        case .tools: return "wrench.and.screwdriver.fill"
        case .tweaks: return "sparkles"
        }
    }
}

struct AppItem: Identifiable, Codable {
    var id: String
    var name: String
    var version: String
    var description: String
    var iconURL: URL?
    var downloadURL: URL?
    var category: AppCategory?

    enum CodingKeys: String, CodingKey {
        case id, name, version, description
        case iconURL = "icon"
        case downloadURL = "url"
        case category
    }
}