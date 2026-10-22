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

// نموذج قراءة سورس ESign
struct ESignSourceResponse: Decodable {
    let name: String?
    let identifier: String?
    let apps: [AppItem]?
}

// مفتاح فك ديناميكي لتفادي أي خطأ ترجمة في Swift
struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}

struct AppItem: Identifiable, Decodable {
    let id: String
    let name: String
    let version: String
    let descriptionText: String?
    let iconURL: URL?
    let downloadURL: URL?
    var category: AppCategory?

    var description: String {
        if let desc = descriptionText, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return desc
        }
        return "تطبيق مخصص بصيغة IPA جاهز للتثبيت والاستخدام المباشر."
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)

        // 1. الاسم
        let rawName = Self.decodeString(from: container, keys: ["name", "title"])
        self.name = rawName ?? "تطبيق بدون اسم"

        // 2. الإصدار
        self.version = Self.decodeString(from: container, keys: ["version", "appVersion"]) ?? "1.0"

        // 3. المعرف
        let rawID = Self.decodeString(from: container, keys: ["bundleIdentifier", "bundleID", "id"])
        self.id = rawID ?? UUID().uuidString

        // 4. الوصف
        self.descriptionText = Self.decodeString(from: container, keys: ["description", "desc", "localizedDescription", "versionDescription", "subtitle"])

        // 5. رابط الأيقونة (مع معالجة الروابط التي تحتوي على مسافات)
        if let iconRaw = Self.decodeString(from: container, keys: ["icon", "iconURL", "appIcon"]) {
            self.iconURL = Self.cleanURL(iconRaw)
        } else {
            self.iconURL = nil
        }

        // 6. رابط التحميل (يدعم down و url و link وغيرها)
        if let downRaw = Self.decodeString(from: container, keys: ["down", "downloadURL", "url", "link"]) {
            self.downloadURL = Self.cleanURL(downRaw)
        } else {
            self.downloadURL = nil
        }

        // 7. التصنيف التلقائي الذكي
        let lower = name.lowercased()
        if lower.contains("gta") || lower.contains("pubg") || lower.contains("craft") || lower.contains("game") || lower.contains("ride") || lower.contains("ball") || lower.contains("race") {
            self.category = .games
        } else if lower.contains("tik") || lower.contains("insta") || lower.contains("snap") || lower.contains("tele") || lower.contains("chat") || lower.contains("social") {
            self.category = .social
        } else if lower.contains("esign") || lower.contains("scarlet") || lower.contains("troll") || lower.contains("filza") || lower.contains("maker") || lower.contains("alarm") {
            self.category = .tools
        } else {
            self.category = .tweaks
        }
    }

    private static func decodeString(from container: KeyedDecodingContainer<DynamicCodingKey>, keys: [String]) -> String? {
        for k in keys {
            if let key = DynamicCodingKey(stringValue: k),
               let val = try? container.decodeIfPresent(String.self, forKey: key),
               !val.isEmpty {
                return val
            }
        }
        return nil
    }

    private static func cleanURL(_ raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let direct = URL(string: trimmed) {
            return direct
        }
        if let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: encoded)
        }
        return nil
    }
}