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

// نموذج غلاف سورس ESign
struct ESignSourceResponse: Codable {
    let name: String?
    let identifier: String?
    let apps: [AppItem]?
}

// نموذج بيانات التطبيق المتوافق مع ESign
struct AppItem: Identifiable, Codable {
    var id: String {
        bundleIdentifier ?? UUID().uuidString
    }
    
    let name: String
    let bundleIdentifier: String?
    let version: String
    let descriptionText: String?
    let iconURL: URL?
    let downloadURL: URL?
    var category: AppCategory?

    var description: String {
        descriptionText ?? "لا يوجد وصف متوفر لهذا التطبيق حالياً."
    }

    enum CodingKeys: String, CodingKey {
        case name
        case bundleIdentifier
        case version
        case descriptionText = "description"
        case iconURL = "icon"
        case downloadURL = "down"
        case category
    }

    // تهيئة مخصصة لفك الترميز بمرونة
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "بدون اسم"
        self.bundleIdentifier = try container.decodeIfPresent(String.self, forKey: .bundleIdentifier)
        self.version = try container.decodeIfPresent(String.self, forKey: .version) ?? "1.0"
        self.descriptionText = try container.decodeIfPresent(String.self, forKey: .descriptionText)
        self.iconURL = try container.decodeIfPresent(URL.self, forKey: .iconURL)
        self.downloadURL = try container.decodeIfPresent(URL.self, forKey: .downloadURL)
        
        // تصنيف تلقائي ذكي حسب الاسم إذا لم يكن محدداً في السورس
        if let cat = try container.decodeIfPresent(AppCategory.self, forKey: .category) {
            self.category = cat
        } else {
            let lower = name.lowercased()
            if lower.contains("pubg") || lower.contains("craft") || lower.contains("game") || lower.contains("ball") {
                self.category = .games
            } else if lower.contains("tik") || lower.contains("insta") || lower.contains("snap") || lower.contains("what") || lower.contains("tele") {
                self.category = .social
            } else if lower.contains("esign") || lower.contains("scarlet") || lower.contains("troll") || lower.contains("filza") {
                self.category = .tools
            } else {
                self.category = .tweaks
            }
        }
    }
}