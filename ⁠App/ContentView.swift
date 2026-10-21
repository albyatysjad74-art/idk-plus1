import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StoreViewModel()

    // ألوان الأزرق الليلي المريحة للعين
    private let bgDeepBlue = Color(red: 0.04, green: 0.08, blue: 0.16)      // خلفية داكنة #0A1428
    private let cardNavy = Color(red: 0.09, green: 0.15, blue: 0.27)        // بطاقة كحلية #172645
    private let cardBorder = Color(red: 0.15, green: 0.24, blue: 0.40)      // إطار البطاقة
    private let textTitle = Color(red: 0.96, green: 0.97, blue: 1.0)        // نصوص بيضاء
    private let textSecondary = Color(red: 0.65, green: 0.74, blue: 0.88)    // نصوص رمادية للوصف
    private let vibrantBlue = Color(red: 0.12, green: 0.53, blue: 0.98)      // أزرق الأزرار والتفاعل

    var body: some View {
        NavigationView {
            ZStack {
                bgDeepBlue.ignoresSafeArea()

                VStack(spacing: 0) {
                    // الشريط الإحصائي العلوي
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("متجر idk Plus")
                                .font(.caption.bold())
                                .foregroundColor(vibrantBlue)
                            Text("التطبيقات والألعاب المتاحة")
                                .font(.headline.bold())
                                .foregroundColor(textTitle)
                        }

                        Spacer()

                        // عداد التطبيقات الفعلي
                        HStack(spacing: 6) {
                            Image(systemName: "gamecontroller.fill")
                                .foregroundColor(.white)
                                .font(.caption)
                            Text("\(viewModel.filteredApps.count) تطبيق")
                                .font(.footnote.bold())
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(vibrantBlue)
                        .clipShape(Capsule())
                        .shadow(color: vibrantBlue.opacity(0.4), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)

                    // عرض المحتوى
                    if viewModel.isLoading && viewModel.apps.isEmpty {
                        Spacer()
                        VStack(spacing: 14) {
                            ProgressView()
                                .tint(vibrantBlue)
                                .scaleEffect(1.4)
                            Text("جاري تحميل التطبيقات والألعاب...")
                                .font(.subheadline)
                                .foregroundColor(textSecondary)
                        }
                        Spacer()
                    } else if viewModel.filteredApps.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 42))
                                .foregroundColor(textSecondary.opacity(0.5))
                            Text("لا توجد لعبة أو تطبيق بهذا الاسم")
                                .font(.subheadline)
                                .foregroundColor(textSecondary)
                        }
                        Spacer()
                    } else {
                        List(viewModel.filteredApps) { app in
                            AppCardView(
                                app: app,
                                cardBg: cardNavy,
                                borderColor: cardBorder,
                                titleColor: textTitle,
                                subtitleColor: textSecondary,
                                accentColor: vibrantBlue
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 14, bottom: 5, trailing: 14))
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.loadApps()
                        }
                    }
                }
            }
            .navigationTitle("idk Plus")
            .searchable(text: $viewModel.searchText, prompt: "ابحث عن تطبيق أو لعبة...")
            .preferredColorScheme(.dark)
            .task {
                if viewModel.apps.isEmpty {
                    await viewModel.loadApps()
                }
            }
        }
        .navigationViewStyle(.stack)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// تصميم بطاقة التطبيق
struct AppCardView: View {
    let app: AppItem
    let cardBg: Color
    let borderColor: Color
    let titleColor: Color
    let subtitleColor: Color
    let accentColor: Color

    var body: some View {
        HStack(spacing: 12) {
            // أيقونة التطبيق
            AsyncImage(url: app.iconURL) { phase in
                if let img = phase.image {
                    img.resizable().scaledToFill()
                } else if phase.error != nil {
                    ZStack {
                        accentColor.opacity(0.2)
                        Image(systemName: "app.fill")
                            .foregroundColor(accentColor)
                            .font(.system(size: 24))
                    }
                } else {
                    ZStack {
                        cardBg
                        ProgressView().tint(accentColor)
                    }
                }
            }
            .frame(width: 58, height: 58)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )

            // نصوص وتفاصيل التطبيق
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(titleColor)
                    .lineLimit(1)

                Text(app.description)
                    .font(.system(size: 11))
                    .foregroundColor(subtitleColor)
                    .lineLimit(2)

                Text("الإصدار: \(app.version)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(accentColor)
            }

            Spacer()

            // زر التثبيت
            if let targetURL = app.downloadURL, !targetURL.absoluteString.isEmpty {
                Link(destination: targetURL) {
                    Text("تثبيت")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: accentColor.opacity(0.35), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(11)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )
        )
    }
}
