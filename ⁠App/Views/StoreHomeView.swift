import SwiftUI

struct StoreHomeView: View {
    @EnvironmentObject var viewModel: StoreViewModel
    @ObservedObject private var loc = LocalizationManager.shared
    @State private var selectedCategory: AppCategory = .all

    private var filteredApps: [AppItem] {
        if selectedCategory == .all {
            return viewModel.displayedApps
        }
        return viewModel.displayedApps.filter { ($0.category ?? .tools) == selectedCategory }
    }

    var body: some View {
        ZStack {
            AppTheme.bgDeepBlue.ignoresSafeArea()

            VStack(spacing: 0) {
                // ترويسة المتجر واللغة
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(loc.tr("store"))
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppTheme.textTitle)
                        
                        Text(selectedCategory.title(using: loc))
                            .font(.subheadline)
                            .foregroundColor(AppTheme.vibrantBlue)
                    }

                    Spacer()

                    Button(action: {
                        withAnimation {
                            loc.currentLanguage = (loc.currentLanguage == .ar) ? .en : .ar
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "globe")
                            Text(loc.currentLanguage == .ar ? "EN" : "عربي")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(AppTheme.cardNavy)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(AppTheme.cardBorder, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 12)

                // شريط التصنيفات
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(AppCategory.allCases, id: \.self) { category in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedCategory = category
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 13))
                                    Text(category.title(using: loc))
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? AppTheme.vibrantBlue : AppTheme.cardNavy)
                                .foregroundColor(selectedCategory == category ? .white : AppTheme.textSecondary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(AppTheme.cardBorder, lineWidth: selectedCategory == category ? 0 : 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }

                // عرض التطبيقات
                if viewModel.isLoading && viewModel.allApps.isEmpty {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.vibrantBlue))
                    Spacer()
                } else if filteredApps.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 36))
                            .foregroundColor(AppTheme.textSecondary.opacity(0.6))
                        Text(loc.currentLanguage == .ar ? "لا توجد تطبيقات في هذا القسم حالياً" : "No apps available in this section")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredApps) { app in
                                AppCardView(app: app)
                                    .onAppear {
                                        viewModel.loadMoreIfNeeded(currentItem: app)
                                    }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .environment(\.layoutDirection, loc.currentLanguage == .ar ? .rightToLeft : .leftToRight)
        .navigationBarHidden(true)
    }
}