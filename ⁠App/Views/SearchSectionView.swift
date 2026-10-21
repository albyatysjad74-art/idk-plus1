import SwiftUI

struct SearchSectionView: View {
    @StateObject private var viewModel = StoreViewModel()
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        ZStack {
            AppTheme.bgDeepBlue.ignoresSafeArea()

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.textSecondary)
                    TextField(loc.tr("search_placeholder"), text: $viewModel.searchText)
                        .foregroundColor(.white)
                    if !viewModel.searchText.isEmpty {
                        Button(action: { viewModel.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                .padding(12)
                .background(AppTheme.cardNavy)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 10)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.vibrantBlue))
                    Spacer()
                } else if viewModel.displayedApps.isEmpty {
                    Spacer()
                    Text(loc.currentLanguage == .ar ? "لا توجد نتائج مطابقة" : "No matching results")
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.displayedApps) { app in
                                AppCardView(app: app)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .environment(\.layoutDirection, loc.currentLanguage == .ar ? .rightToLeft : .leftToRight)
        .navigationTitle(loc.tr("search"))
    }
}