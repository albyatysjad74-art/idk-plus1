import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StoreViewModel()
    @State private var isSplashScreenActive = true
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            if isSplashScreenActive {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                TabView(selection: $selectedTab) {
                    StoreHomeView(viewModel: viewModel)
                        .tabItem {
                            Label("المتجر", systemImage: "square.grid.2x2.fill")
                        }
                        .tag(0)

                    SearchSectionView(viewModel: viewModel)
                        .tabItem {
                            Label("البحث", systemImage: "magnifyingglass")
                        }
                        .tag(1)

                    CertificateSectionView()
                        .tabItem {
                            Label("الشهادات", systemImage: "doc.badge.plus")
                        }
                        .tag(2)

                    DeveloperSectionView()
                        .tabItem {
                            Label("المطور", systemImage: "person.crop.circle.fill")
                        }
                        .tag(3)
                }
                .tint(AppTheme.vibrantBlue)
                .preferredColorScheme(.dark)
                .environment(\.layoutDirection, .rightToLeft)
            }
        }
        .task {
            await viewModel.loadApps()
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation(.easeInOut(duration: 0.5)) {
                isSplashScreenActive = false
            }
        }
    }
}