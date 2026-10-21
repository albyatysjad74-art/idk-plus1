import SwiftUI

struct AppCardView: View {
    let app: AppItem

    var body: some View {
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

            if let targetURL = app.downloadURL, !targetURL.absoluteString.isEmpty {
                Link(destination: targetURL) {
                    Text("تثبيت")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(AppTheme.vibrantBlue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
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
}