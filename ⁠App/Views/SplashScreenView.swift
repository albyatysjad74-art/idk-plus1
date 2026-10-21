import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            AppTheme.bgDeepBlue.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // صورة الشعار المخصصة
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: AppTheme.vibrantBlue.opacity(0.5), radius: 15, x: 0, y: 5)

                VStack(spacing: 8) {
                    Text("idk Plus")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppTheme.textTitle)

                    Text("متجرك المتكامل للتطبيقات والألعاب")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                VStack(spacing: 12) {
                    ProgressView()
                        .tint(AppTheme.vibrantBlue)
                        .scaleEffect(1.2)
                    Text("جاري تهيئة المتجر والتطبيقات...")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.bottom, 40)
            }
        }
    }
}