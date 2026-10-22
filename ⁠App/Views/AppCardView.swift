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