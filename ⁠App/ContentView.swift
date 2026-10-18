import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StoreViewModel()
    
    // اللون الأزرق المريح
    private let primaryBlue = Color(red: 0.10, green: 0.46, blue: 0.92)
    private let softBackground = Color(red: 0.95, green: 0.96, blue: 0.98)

    var body: some View {
        NavigationView {
            ZStack {
                softBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // شريط العداد الإحصائي
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("المصادر المتصلة: 2")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("التطبيقات المتوفرة")
                                .font(.headline.bold())
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        HStack(spacing: 6) {
                            Image(systemName: "square.stack.3d.up.fill")
                                .foregroundColor(primaryBlue)
                                .font(.caption)
                            Text("\(viewModel.filteredApps.count) تطبيق")
                                .font(.footnote.bold())
                                .foregroundColor(primaryBlue)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(primaryBlue.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                    // المحتوى
                    if viewModel.isLoading && viewModel.apps.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(primaryBlue)
                                .scaleEffect(1.2)
                            Text("جاري سحب التطبيقات...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else if viewModel.filteredApps.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 38))
                                .foregroundColor(.secondary.opacity(0.4))
                            Text("لا توجد نتائج مطابقة لبحثك")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        List(viewModel.filteredApps) { app in
                            AppCardView(app: app, accentColor: primaryBlue)
                                .listRowBackground(Color.white)
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 4)
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.loadAllSources()
                        }
                    }
                }
            }
            .navigationTitle("idk Plus")
            .searchable(text: $viewModel.searchText, prompt: "ابحث في idk Plus...")
            .task {
                if viewModel.apps.isEmpty {
                    await viewModel.loadAllSources()
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
    let accentColor: Color

    var body: some View {
        HStack(spacing: 12) {
            // معالجة صورة الأيقونة بدون أخطاء switch
            AsyncImage(url: app.iconURL) { phase in
                if let img = phase.image {
                    img.resizable().scaledToFill()
                } else if phase.error != nil {
                    ZStack {
                        accentColor.opacity(0.12)
                        Image(systemName: "arrow.down.app.fill")
                            .foregroundColor(accentColor)
                            .font(.system(size: 22))
                    }
                } else {
                    ZStack {
                        accentColor.opacity(0.08)
                        ProgressView().tint(accentColor)
                    }
                }
            }
            .frame(width: 58, height: 58)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)

            // بيانات التطبيق
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(app.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(app.sourceBadge)
                        .font(.system(size: 8, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.12))
                        .foregroundColor(.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                Text(app.description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Text("الإصدار: \(app.version)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(accentColor.opacity(0.9))
            }

            Spacer()

            // زر التثبيت
            if let targetURL = app.downloadURL {
                Link(destination: targetURL) {
                    Text("تثبيت")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: accentColor.opacity(0.25), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
        )
    }
}