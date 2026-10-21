import SwiftUI

struct SplashScreenView: View {
    // دالة مساعدة لتحميل الصورة مباشرة من حزمة التطبيق (Bundle)
    private var logoImage: UIImage? {
        if let path = Bundle.main.path(forResource: "Logo", ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        return UIImage(named: "Logo")
    }

    var body: some View {
        ZStack {
            AppTheme.bgDeepBlue.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // عرض صورة Logo.png المرفوعة في المجلد
                if let uiImage = logoImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: AppTheme.vibrantBlue.opacity(0.6), radius: 18, x: 0, y: 5)
                } else {
                    // شكل احتياطي يظهر فقط إذا تعذر الوصول للملف
                    Image(systemName: "flame.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(AppTheme.vibrantBlue)
                        .shadow(color: AppTheme.vibrantBlue.opacity(0.6), radius: 18, x: 0, y: 5)
                }

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