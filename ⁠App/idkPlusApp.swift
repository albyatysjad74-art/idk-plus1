import SwiftUI

@main
struct idkPlusApp: App {
    @StateObject private var viewModel = StoreViewModel()
    @State private var minTimeElapsed = false

    // تفتح الواجهة فقط إذا انتهى التحميل ومرت ثانية ونصف على الأقل لشكل احترافي
    private var canShowHome: Bool {
        viewModel.isDataLoaded && minTimeElapsed
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(viewModel)
                    .opacity(canShowHome ? 1 : 0)

                if !canShowHome {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        minTimeElapsed = true
                    }
                }
            }
        }
    }
}