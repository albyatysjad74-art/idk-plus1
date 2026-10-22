    private func installDirectly(_ url: URL) {
        let urlString = url.absoluteString

        // 1. إذا كان الرابط يبدأ مسبقاً بـ itms-services
        if urlString.hasPrefix("itms-services://") {
            UIApplication.shared.open(url)
            return
        }

        // 2. إذا كان الرابط ينتهي بـ .plist
        if urlString.hasSuffix(".plist") {
            if let itmsURL = URL(string: "itms-services://?action=download-manifest&url=\(urlString)") {
                UIApplication.shared.open(itmsURL)
                return
            }
        }

        // 3. إذا كان الرابط هو ملف .ipa مباشر (يحوله فوراً لتثبيت مباشر بدون تحميل كسفاري)
        let appNameEncoded = app.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "App"
        let bundleID = app.id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "com.idk.app"
        let ipaUrlEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        // نستخدم مولّد manifest لحظي وسريع معتمد للتثبيت الهوائي المباشر
        let otaService = "https://api.palera.in/install?url=\(ipaUrlEncoded)&name=\(appNameEncoded)&bundle=\(bundleID)"
        
        if let directInstallURL = URL(string: "itms-services://?action=download-manifest&url=\(otaService)") {
            UIApplication.shared.open(directInstallURL)
        } else {
            // بديل في حال تعذر التحويل
            UIApplication.shared.open(url)
        }
    }