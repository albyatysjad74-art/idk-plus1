import SwiftUI

struct SplashScreenView: View {
    private var logoImage: UIImage? {
        if let path = Bundle.main.path(forResource: "Logo", ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        return UIImage(named: "Logo")
    }

    var body: some View {
        ZStack {
            // خلفية سوداء نقية تبتلع سواد الصورة بالكامل
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                if let uiImage = logoImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: AppTheme.vibrantBlue.opacity(0.4), radius: 20, x: 0, y: 0)
                } else {
                    Image(systemName: "flame.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(AppTheme.vibrantBlue)
                }

                VStack(spacing: 8) {
                    Text("idk Plus")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("متجرك المتكامل للتطبيقات والألعاب")
                        .font(.subheadline)
                        .foregroundColor(Color(white: 0.7))
                }

                Spacer()

                VStack(spacing: 12) {
                    ProgressView()
                        .tint(AppTheme.vibrantBlue)
                        .scaleEffect(1.2)
                    Text("جاري تهيئة المتجر والتطبيقات...")
                        .font(.caption)
                        .foregroundColor(Color(white: 0.6))
                }
                .padding(.bottom, 40)
            }
        }
    }
}