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

struct ESignSourceResponse: Codable {
    let name: String?
    let identifier: String?
    let apps: [AppItem]?
}

struct AppItem: Identifiable, Codable {
    var id: String
    let name: String
    let bundleIdentifier: String?
    let version: String
    let descriptionText: String?
    let iconURL: URL?
    let downloadURL: URL?
    var category: AppCategory?

    var description: String {
        if let desc = descriptionText, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return desc
        }
        return "تطبيق مخصص جاهز للتثبيت المباشر بنسخة كاملة."
    }

    enum CodingKeys: String, CodingKey {
        case id, name, version, category
        case bundleIdentifier, bundleID
        case icon, iconURL, appIcon
        case down, downloadURL, url, link
        case description, localizedDescription, versionDescription, subtitle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "تطبيق بدون اسم"
        self.version = try container.decodeIfPresent(String.self, forKey: .version) ?? "1.0"
        self.bundleIdentifier = try container.decodeIfPresent(String.self, forKey: .bundleIdentifier)
            ?? container.decodeIfPresent(String.self, forKey: .bundleID)
        self.id = self.bundleIdentifier ?? UUID().uuidString

        // 1. استخراج الوصف من أي مفتاح محتمل
        self.descriptionText = try container.decodeIfPresent(String.self, forKey: .description)
            ?? container.decodeIfPresent(String.self, forKey: .localizedDescription)
            ?? container.decodeIfPresent(String.self, forKey: .versionDescription)
            ?? container.decodeIfPresent(String.self, forKey: .subtitle)

        // 2. استخراج الأيقونة ومعالجة المسافات
        let iconString = try container.decodeIfPresent(String.self, forKey: .iconURL)
            ?? container.decodeIfPresent(String.self, forKey: .icon)
            ?? container.decodeIfPresent(String.self, forKey: .appIcon)
        if let iconStr = iconString, let cleanStr = iconStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.iconURL = URL(string: cleanStr)
        } else {
            self.iconURL = nil
        }

        // 3. استخراج رابط التنزيل المباشر ومعالجة المسافات
        let downString = try container.decodeIfPresent(String.self, forKey: .downloadURL)
            ?? container.decodeIfPresent(String.self, forKey: .down)
            ?? container.decodeIfPresent(String.self, forKey: .url)
            ?? container.decodeIfPresent(String.self, forKey: .link)
        if let downStr = downString, let cleanDown = downStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.downloadURL = URL(string: cleanDown)
        } else {
            self.downloadURL = nil
        }

        // 4. التصنيف التلقائي
        if let cat = try container.decodeIfPresent(AppCategory.self, forKey: .category) {
            self.category = cat
        } else {
            let lower = name.lowercased()
            if lower.contains("gta") || lower.contains("pubg") || lower.contains("craft") || lower.contains("game") || lower.contains("ride") || lower.contains("color") {
                self.category = .games
            } else if lower.contains("tik") || lower.contains("insta") || lower.contains("snap") || lower.contains("tele") || lower.contains("chat") {
                self.category = .social
            } else if lower.contains("esign") || lower.contains("scarlet") || lower.contains("troll") || lower.contains("filza") || lower.contains("maker") {
                self.category = .tools
            } else {
                self.category = .tweaks
            }
        }
    }
}