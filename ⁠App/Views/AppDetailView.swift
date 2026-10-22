import SwiftUI

struct AppDetailView: View {
    let app: AppItem
    @ObservedObject private var loc = LocalizationManager.shared

    var body: some View {
        ZStack {
            AppTheme.bgDeepBlue.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    HStack(spacing: 16) {
                        AsyncImage(url: app.iconURL) { phase in
                            if let img = phase.image {
                                img
                                    .resizable()
                                    .scaledToFill()
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

                            Text("\(loc.tr("version")): \(app.version)")
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.vibrantBlue)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.cardNavy)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // زر التثبيت
                    if let targetURL = app.downloadURL, !targetURL.absoluteString.isEmpty {
                        Button(action: {
                            installDirectly(targetURL)
                        }) {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                Text(loc.tr("install"))
                            }
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.vibrantBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }

                    // تفاصيل ووصف التطبيق
                    VStack(alignment: .leading, spacing: 10) {
                        Text(loc.tr("description"))
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
        .environment(\.layoutDirection, loc.currentLanguage == .ar ? .rightToLeft : .leftToRight)
    }

    private func installDirectly(_ url: URL) {
        let urlString = url.absoluteString

        if urlString.hasPrefix("itms-services://") {
            UIApplication.shared.open(url)
            return
        }

        if urlString.hasSuffix(".plist") {
            if let itmsURL = URL(string: "itms-services://?action=download-manifest&url=\(urlString)") {
                UIApplication.shared.open(itmsURL)
                return
            }
        }

        let appNameEncoded = app.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "App"
        let bundleID = app.id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "com.idk.app"
        let ipaUrlEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let otaService = "https://api.palera.in/install?url=\(ipaUrlEncoded)&name=\(appNameEncoded)&bundle=\(bundleID)"

        if let directInstallURL = URL(string: "itms-services://?action=download-manifest&url=\(otaService)") {
            UIApplication.shared.open(directInstallURL)
        } else {
            UIApplication.shared.open(url)
        }
    }
}