import SwiftUI

enum Language: String, CaseIterable {
    case ar = "ar"
    case en = "en"

    var title: String {
        switch self {
        case .ar: return "العربية"
        case .en: return "English"
        }
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @AppStorage("selected_language") var currentLanguage: Language = .ar

    func tr(_ key: String) -> String {
        let isArabic = currentLanguage == .ar

        switch key {
        case "store": return isArabic ? "المتجر" : "Store"
        case "search": return isArabic ? "البحث" : "Search"
        case "developer": return isArabic ? "المطور" : "Developer"
        case "all": return isArabic ? "الكل" : "All"
        case "social": return isArabic ? "سوشيال ميديا" : "Social Media"
        case "games": return isArabic ? "ألعاب" : "Games"
        case "tools": return isArabic ? "أدوات وتطبيقات" : "Utilities"
        case "tweaks": return isArabic ? "تطبيقات بلس" : "Plus Apps"
        case "install": return isArabic ? "تثبيت" : "Install"
        case "version": return isArabic ? "الإصدار" : "Version"
        case "description": return isArabic ? "الوصف" : "Description"
        case "search_placeholder": return isArabic ? "ابحث عن تطبيق أو لعبة..." : "Search apps or games..."
        default: return key
        }
    }
}