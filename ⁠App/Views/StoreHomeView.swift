import SwiftUI

struct StoreHomeView: View {
    @ObservedObject var viewModel: StoreViewModel
    @State private var selectedApp: AppItem? = nil

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.bgDeepBlue.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("متجر idk Plus")
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.vibrantBlue)
                            Text("التطبيقات والألعاب المتاحة")
                                .font(.headline.bold())
                                .foregroundColor(AppTheme.textTitle)
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
                        .background(AppTheme.vibrantBlue)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)

                    if viewModel.displayedApps.isEmpty {
                        Spacer()
                        ProgressView().tint(AppTheme.vibrantBlue).scaleEffect(1.3)
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
                                        .onAppear {
                                            viewModel.onItemAppear(app)
                                        }
                                }

                                if viewModel.displayedApps.count < viewModel.totalCount {
                                    ProgressView().tint(AppTheme.vibrantBlue).padding()
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
                AppDetailView(app: app)
            }
        }
        .navigationViewStyle(.stack)
    }
}