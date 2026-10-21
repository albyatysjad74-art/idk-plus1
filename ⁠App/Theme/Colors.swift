import SwiftUI

struct AppTheme {
    // السواد النقي للواجهة والخلفيات لدمج حواف اللوجو
    static let bgDeepBlue = Color.black
    static let bgPrimary = Color.black

    // ألوان الكروت المطلوبة في AppDetailView و AppCardView
    static let cardNavy = Color(red: 0.08, green: 0.08, blue: 0.10)
    static let cardBackground = Color(red: 0.08, green: 0.08, blue: 0.10)

    // لون الحدود الذي يطلبه الخطأ الحالي في AppCardView
    static let cardBorder = Color(white: 0.2)
    static let borderSubtle = Color(white: 0.15)

    // الألوان الإضافية للنصوص والتفاعل
    static let vibrantBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let textTitle = Color.white
    static let textSecondary = Color(white: 0.7)
}