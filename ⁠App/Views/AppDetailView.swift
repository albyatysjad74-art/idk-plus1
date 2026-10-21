import SwiftUI

struct AppDetailView: View {
    let app: AppItem

    var body: some View {
        ZStack {
            AppTheme.bgDeepBlue.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    HStack(spacing: 16) {
                        AsyncImage(url: app.iconURL) { phase in
                            if let img = phase.image {
                                img.resizable().scaledToFill()
                            } else {
                                Image(systemName: "app.fill")
                                    .foregroundColor(AppTheme.vibrantBlue)
                                    .font(.system(size: 38))
                            }
                        }
                        .frame(width: 75, height: 75)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        VStack(alignment: .leading, spacing: 5) {
                            Text(app.name)
                                .font(.title3.bold())
                                .foregroundColor(AppTheme.textTitle)

                            Text("الإصدار: \(app.version)")
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.vibrantBlue)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.cardNavy)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    if let targetURL = app.downloadURL, !targetURL.absoluteString.isEmpty {
                        Link(destination: targetURL) {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("تثبيت التطبيق الآن")
                            }
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.vibrantBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("وصف التطبيق")
                            .font(.headline.bold())
                            .foregroundColor(AppTheme.textTitle)

                        Text(app.description)
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppTheme.cardNavy)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}