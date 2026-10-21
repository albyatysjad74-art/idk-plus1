import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StoreViewModel()
    @State private var isSplashScreenActive = true
    @State private var selectedTab = 0

    // لوحة الألوان المعتمدة
    private let bgDeepBlue = Color(red: 0.04, green: 0.08, blue: 0.16)
    private let cardNavy = Color(red: 0.09, green: 0.15, blue: 0.27)
    private let cardBorder = Color(red: 0.15, green: 0.24, blue: 0.40)
    private let textTitle = Color(red: 0.96, green: 0.97, blue: 1.0)
    private let textSecondary = Color(red: 0.65, green: 0.74, blue: 0.88)
    private let vibrantBlue = Color(red: 0.12, green: 0.53, blue: 0.98)

    var body: some View {
        ZStack {
            if isSplashScreenActive {
                // MARK: - واجهة البداية (Splash Screen)
                SplashScreenView(accentColor: vibrantBlue)
                    .transition(.opacity)
            } else {
                // MARK: - الأقسام الرئيسية (TabView)
                TabView(selection: $selectedTab) {
                    
                    // 1. قسم المتجر (الرئيسية)
                    StoreHomeView(viewModel: viewModel)
                        .tabItem {
                            Label("المتجر", systemImage: "square.grid.2x2.fill")
                        }
                        .tag(0)

                    // 2. قسم البحث
                    SearchSectionView(viewModel: viewModel)
                        .tabItem {
                            Label("البحث", systemImage: "magnifyingglass")
                        }
                        .tag(1)

                    // 3. قسم إضافة شهادة (واجهة جاهزة للتطوير لاحقاً)
                    CertificateSectionView()
                        .tabItem {
                            Label("الشهادات", systemImage: "doc.badge.plus")
                        }
                        .tag(2)

                    // 4. قسم المطور
                    DeveloperSectionView()
                        .tabItem {
                            Label("المطور", systemImage: "person.crop.circle.fill")
                        }
                        .tag(3)
                }
                .tint(vibrantBlue)
                .preferredColorScheme(.dark)
                .environment(\.layoutDirection, .rightToLeft)
            }
        }
        .task {
            // جلب التطبيقات في الخلفية أثناء ظهور الشاشة الافتتاحية
            await viewModel.loadApps()
            
            // الانتظار 3 ثوانٍ قبل التحويل للمتجر
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation(.easeInOut(duration: 0.5)) {
                isSplashScreenActive = false
            }
        }
    }
}

// MARK: - 1. شاشة البداية الافتتاحية (Splash Screen)
struct SplashScreenView: View {
    let accentColor: Color
    
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.08, blue: 0.16).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // مكان وضع الصورة أو شعار المتجر
                // يمكنك استبدال Image(systemName:) بـ Image("LogoName") من مجلد Assets
                Image(systemName: "flame.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(accentColor)
                    .shadow(color: accentColor.opacity(0.6), radius: 18, x: 0, y: 5)

                VStack(spacing: 8) {
                    Text("idk Plus")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("متجرك المتكامل للتطبيقات والألعاب")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }

                Spacer()

                // مؤشر تحميل هادئ في الأسفل
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(accentColor)
                        .scaleEffect(1.2)
                    Text("جاري تهيئة المتجر والتطبيقات...")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - 2. واجهة الرئيسية (المتجر)
struct StoreHomeView: View {
    @ObservedObject var viewModel: StoreViewModel
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

                    if viewModel.displayedApps.isEmpty {
                        Spacer()
                        ProgressView().tint(vibrantBlue).scaleEffect(1.3)
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
                                    ProgressView().tint(vibrantBlue).padding()
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.top, 8)
                        }
                    }
                }
            }
            .navigationTitle("الرئيسية")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedApp) { app in
                AppDetailView(app: app, bgNavy: cardNavy, accentColor: vibrantBlue)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - 3. قسم البحث المخصص
struct SearchSectionView: View {
    @ObservedObject var viewModel: StoreViewModel
    @State private var selectedApp: AppItem? = nil

    private let bgDeepBlue = Color(red: 0.04, green: 0.08, blue: 0.16)
    private let cardNavy = Color(red: 0.09, green: 0.15, blue: 0.27)
    private let cardBorder = Color(red: 0.15, green: 0.24, blue: 0.40)
    private let vibrantBlue = Color(red: 0.12, green: 0.53, blue: 0.98)

    var body: some View {
        NavigationView {
            ZStack {
                bgDeepBlue.ignoresSafeArea()

                VStack {
                    if viewModel.searchText.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass.circle")
                                .font(.system(size: 60))
                                .foregroundColor(Color.gray.opacity(0.4))
                            Text("اكتب اسم التطبيق أو اللعبة للبحث المباشر")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else if viewModel.displayedApps.isEmpty {
                        Spacer()
                        Text("لا توجد نتائج مطابقة لبحثك")
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.displayedApps) { app in
                                    AppCardView(
                                        app: app,
                                        cardBg: cardNavy,
                                        borderColor: cardBorder,
                                        titleColor: .white,
                                        subtitleColor: Color.gray.opacity(0.8),
                                        accentColor: vibrantBlue
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedApp = app
                                    }
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.top, 8)
                        }
                    }
                }
            }
            .navigationTitle("بحث التطبيقات")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "ابحث بين آلاف التطبيقات...")
            .sheet(item: $selectedApp) { app in
                AppDetailView(app: app, bgNavy: cardNavy, accentColor: vibrantBlue)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - 4. قسم إضافة شهادة (واجهة جاهزة)
struct CertificateSectionView: View {
    private let bgDeepBlue = Color(red: 0.04, green: 0.08, blue: 0.16)
    private let cardNavy = Color(red: 0.09, green: 0.15, blue: 0.27)
    private let cardBorder = Color(red: 0.15, green: 0.24, blue: 0.40)
    private let vibrantBlue = Color(red: 0.12, green: 0.53, blue: 0.98)

    var body: some View {
        NavigationView {
            ZStack {
                bgDeepBlue.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // كارت التنبيه
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "signature")
                                    .font(.title2)
                                    .foregroundColor(vibrantBlue)
                                Text("إدارة شهادات المطورين (P12)")
                                    .font(.headline.bold())
                                    .foregroundColor(.white)
                            }

                            Text("يمكنك هنا استيراد شهادتك الخاصة وملف التعريف (Mobileprovision) لتوقيع التطبيقات مباشرة بدون قيود.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(cardNavy)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(cardBorder, lineWidth: 1))

                        // أزرار الاختيار (تجهيز للخطوة القادمة)
                        VStack(spacing: 12) {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "doc.fill")
                                    Text("اختيار ملف الشهادة (.p12)")
                                    Spacer()
                                    Image(systemName: "chevron.left")
                                }
                                .padding()
                                .background(cardNavy)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(cardBorder, lineWidth: 1))
                            }

                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                    Text("اختيار ملف (.mobileprovision)")
                                    Spacer()
                                    Image(systemName: "chevron.left")
                                }
                                .padding()
                                .background(cardNavy)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(cardBorder, lineWidth: 1))
                            }
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("الشهادات والتوقيع")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - 5. قسم المطور
struct DeveloperSectionView: View {
    private let bgDeepBlue = Color(red: 0.04, green: 0.08, blue: 0.16)
    private let cardNavy = Color(red: 0.09, green: 0.15, blue: 0.27)
    private let cardBorder = Color(red: 0.15, green: 0.24, blue: 0.40)
    private let vibrantBlue = Color(red: 0.12, green: 0.53, blue: 0.98)

    var body: some View {
        NavigationView {
            ZStack {
                bgDeepBlue.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        // بطاقة المطور التعريفية
                        VStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 75)
                                .foregroundColor(vibrantBlue)

                            Text("تطوير وإشراف: idk")
                                .font(.title3.bold())
                                .foregroundColor(.white)

                            Text("مطور أدوات وتطبيقات متوافقة مع أنظمة iOS")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                        .background(cardNavy)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(cardBorder, lineWidth: 1))

                        // قنوات التواصل
                        VStack(alignment: .leading, spacing: 14) {
                            Text("قنوات الدعم والتحديثات")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)

                            Link(destination: URL(string: "https://t.me/xar_ipa")!) {
                                HStack(spacing: 12) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(vibrantBlue)
                                        .font(.title3)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("قناة التلجرام الرسمية")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.white)
                                        Text("@xar_ipa")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.left")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(cardNavy)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(cardBorder, lineWidth: 1))
                            }
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("عن المطور")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - بطاقة عرض التطبيق (AppCardView)
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

// MARK: - صفحة تفاصيل التطبيق الكاملة (Detail View)
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