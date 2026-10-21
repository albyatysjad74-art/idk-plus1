import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StoreViewModel()
    @State private var selectedApp: AppItem? = nil

    private let bgDeepBlue = Color(red: 0.04, green: 0.08, blue: 0.16)
    private let cardNavy = Color(red: 0.09, green: 0.15, blue: 0.27)
    private let cardBorder = Color(red: 0.15, green: 0.24, blue: 0.40)
    private let textTitle = Color(red: 0.96, green: 0.97, blue: 1.0)
    private let textSecondary = Color(red: 0.65, green: 0.74, blue: 0.88)
    private let vibrantBlue = Color(red: 0.12, green: 0.53, blue: 0.98)

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

                        // العداد
                        HStack(spacing: 6) {
                            Image(systemName: "gamecontroller.fill")
                                .foregroundColor(.white)
                                .font(.caption)
                            Text("\(viewModel.displayedApps.count) من \(viewModel.totalCount)")
                                .font(.footnote.bold())
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(vibrantBlue)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)

                    // المحتوى
                    if viewModel.isLoading && viewModel.displayedApps.isEmpty {
                        Spacer()
                        ProgressView()
                            .tint(vibrantBlue)
                            .scaleEffect(1.4)
                        Spacer()
                    } else if viewModel.displayedApps.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(textSecondary.opacity(0.5))
                            Text("لا توجد نتائج")
                                .font(.subheadline)
                                .foregroundColor(textSecondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.displayedApps) { app in
                                    AppCardView(
                                        app: app,
                                        cardBg: cardNavy,
                                        borderColor: cardBorder,
                                        titleColor: textTitle,
                                        subtitleColor: textSecondary,
                                        accentColor: vibrantBlue
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedApp = app
                                    }
                                    .onAppear {
                                        viewModel.onItemAppear(app)
                                    }
                                }

                                if viewModel.displayedApps.count < viewModel.totalCount {
                                    ProgressView()
                                        .tint(vibrantBlue)
                                        .padding()
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.top, 8)
                        }
                    }
                }
            }
            .navigationTitle("idk Plus")
            .searchable(text: $viewModel.searchText, prompt: "ابحث عن تطبيق أو لعبة...")
            .preferredColorScheme(.dark)
            .task {
                await viewModel.loadApps()
            }
            .sheet(item: $selectedApp) { app in
                AppDetailView(app: app, bgNavy: cardNavy, accentColor: vibrantBlue)
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
            AsyncImage(url: app.iconURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    ZStack {
                        accentColor.opacity(0.15)
                        Image(systemName: "app.fill")
                            .foregroundColor(accentColor)
                            .font(.system(size: 24))
                    }
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )

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

            if let targetURL = app.downloadURL, !targetURL.absoluteString.isEmpty {
                Link(destination: targetURL) {
                    Text("تثبيت")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
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

// نافذة تفاصيل التطبيق عند الضغط عليه
struct AppDetailView: View {
    let app: AppItem
    let bgNavy: Color
    let accentColor: Color

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.08, blue: 0.16).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    HStack(spacing: 16) {
                        AsyncImage(url: app.iconURL) { phase in
                            if let img = phase.image {
                                img.resizable().scaledToFill()
                            } else {
                                Image(systemName: "app.fill")
                                    .foregroundColor(accentColor)
                                    .font(.system(size: 38))
                            }
                        }
                        .frame(width: 75, height: 75)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        VStack(alignment: .leading, spacing: 5) {
                            Text(app.name)
                                .font(.title3.bold())
                                .foregroundColor(.white)

                            Text("الإصدار: \(app.version)")
                                .font(.subheadline.bold())
                                .foregroundColor(accentColor)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(bgNavy)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    if let targetURL = app.downloadURL, !targetURL.absoluteString.isEmpty {
                        Link(destination: targetURL) {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("تثبيت التطبيق الآن")
                            }
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("وصف التطبيق")
                            .font(.headline.bold())
                            .foregroundColor(.white)

                        Text(app.description)
                            .font(.body)
                            .foregroundColor(Color.white.opacity(0.8))
                            .lineSpacing(5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(bgNavy)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
