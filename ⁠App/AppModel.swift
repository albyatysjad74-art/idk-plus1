import Foundation

// نموذج التطبيق الموحد لمتجر idk Plus
struct AppItem: Identifiable, Hashable {
    let id: String
    let name: String
    let version: String
    let description: String
    let iconURL: URL?
    let downloadURL: URL?
    let sourceBadge: String
}

// قراءة بيانات المصدر الأول: GitHub JSON
struct JSONStoreItem: Codable {
    let name: String?
    let version: String?
    let description: String?
    let icon: String?
    let downloadLink: String?
    let url: String?
}

// قراءة بيانات المصدر الثاني: WordPress REST API (ipaomtk)
struct WPPost: Codable {
    let id: Int
    let title: WPContent
    let excerpt: WPContent
    let link: String
    let yoast_head_json: WPYoastHead?
}

struct WPContent: Codable {
    let rendered: String
}

struct WPYoastHead: Codable {
    let og_image: [WPOgImage]?
}

struct WPOgImage: Codable {
    let url: String
}

// دالة تنظيف وسوم الـ HTML والنصوص
struct TextCleaner {
    static func cleanHTML(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else { return html }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributed.string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&#8211;", with: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}