import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                StoreHomeView()
            }
            .tabItem {
                Label("المتجر", systemImage: "square.grid.2x2.fill")
            }
            .tag(0)

            NavigationView {
                SearchSectionView()
            }
            .tabItem {
                Label("البحث", systemImage: "magnifyingglass")
            }
            .tag(1)

            NavigationView {
                DeveloperSectionView()
            }
            .tabItem {
                Label("المطور", systemImage: "person.crop.circle.fill")
            }
            .tag(2)
        }
        .accentColor(AppTheme.vibrantBlue)
        .environment(\.layoutDirection, .rightToLeft)
    }
}