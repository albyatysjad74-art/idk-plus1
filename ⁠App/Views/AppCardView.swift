import SwiftUI

struct AppCardView: View {
    let app: AppItem
    @ObservedObject var dlManager = DownloadManager.shared

    // التحقق مما إذا كان هذا التطبيق بالذات قيد التحميل أو التوقيع حالياً
    private var isCurrentAppBusy: Bool {
        dlManager.currentAppName == app.name && (dlManager.isDownloading || dlManager.isSigning)
    }

    var body: some View {
        NavigationLink(destination: AppDetailView(app: app)) {
            HStack(spacing: 12) {
                AsyncImage(url: app.iconURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        ZStack {
                            AppTheme.vibrantBlue.opacity(0.15)
                            Image(systemName: "app.fill")
                                .foregroundColor(AppTheme.vibrantBlue)
                                .font(.system(size: 24))
                        }
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.textTitle)
                        .lineLimit(1)

                    Text(app.description)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)

                    Text("الإصدار: \(app.version)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(AppTheme.vibrantBlue)
                }

                Spacer()

                // زر التثبيت والتوقيع المباشر بدون سفاري
                if let targetURL = app.downloadURL, !targetURL.absoluteString.isEmpty {
                    Button(action: {
                        if !isCurrentAppBusy {
                            dlManager.startDownloadAndSign(app: app)
                        }
                    }) {
                        HStack(spacing: 4) {
                            if isCurrentAppBusy {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.7)
                                Text(dlManager.isDownloading ? "\(Int(dlManager.progress * 100))%" : "توقيع...")
                                    .font(.system(size: 11, weight: .bold))
                            } else {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 12))
                                Text("تثبيت")
                                    .font(.system(size: 12, weight: .bold))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(isCurrentAppBusy ? Color.orange : AppTheme.vibrantBlue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle()) // لمنع تضارب الضغط مع NavigationLink
                    .disabled(isCurrentAppBusy)
                }
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
}