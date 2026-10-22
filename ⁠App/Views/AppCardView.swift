import SwiftUI

struct AppCardView: View {
    let app: AppItem
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        NavigationLink(destination: AppDetailView(app: app)) {
            HStack(spacing: 12) {
                // أيقونة التطبيق مع تحميل مباشر
                AsyncImage(url: app.iconURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_), .empty:
                        ZStack {
                            AppTheme.cardNavy.opacity(0.8)
                            Image(systemName: "app.fill")
                                .foregroundColor(AppTheme.vibrantBlue)
                                .font(.system(size: 26))
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                )

                // نصوص العنوان والوصف
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.textTitle)
                        .lineLimit(1)

                    Text(app.description)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)

                    Text("\(loc.tr("version")): \(app.version)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(AppTheme.vibrantBlue)
                }

                Spacer()

                // زر التثبيت المباشر
                Button(action: {
                    if let targetURL = app.downloadURL {
                        installDirectly(targetURL)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 11))
                        Text(loc.tr("install"))
                            .font(.system(size: 12, weight: .bold))
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 7)
                    .background(AppTheme.vibrantBlue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(11)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.cardNavy)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppTheme.cardBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func installDirectly(_ url: URL) {
        let urlString = url.absoluteString
        if urlString.hasPrefix("itms-services://") {
            UIApplication.shared.open(url)
        } else if urlString.hasSuffix(".plist") {
            if let itmsURL = URL(string: "itms-services://?action=download-manifest&url=\(urlString)") {
                UIApplication.shared.open(itmsURL)
            }
        } else {
            UIApplication.shared.open(url)
        }
    }
}