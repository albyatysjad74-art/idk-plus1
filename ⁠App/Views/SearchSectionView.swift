import SwiftUI

struct SearchSectionView: View {
    @ObservedObject var viewModel: StoreViewModel
    @State private var selectedApp: AppItem? = nil

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.bgDeepBlue.ignoresSafeArea()

                VStack {
                    if viewModel.searchText.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass.circle")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.textSecondary.opacity(0.4))
                            Text("اكتب اسم التطبيق أو اللعبة للبحث المباشر")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else if viewModel.displayedApps.isEmpty {
                        Spacer()
                        Text("لا توجد نتائج مطابقة لبحثك")
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.displayedApps) { app in
                                    AppCardView(app: app)
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
                AppDetailView(app: app)
            }
        }
        .navigationViewStyle(.stack)
    }
}