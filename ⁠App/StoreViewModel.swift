import Foundation
import Combine

@MainActor
class StoreViewModel: ObservableObject {
    @Published var apps: [AppItem] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""

    // رابط سورس ESign المباشر
    private let sourceURL = "https://raw.githubusercontent.com/NEXT11DEV/NEXT-SOURCE/main/NEXTDEV-ESign.json"

    // تصفية التطبيقات للبحث الفوري
    var filteredApps: [AppItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return apps
        } else {
            return apps.filter { app in
                app.name.localizedCaseInsensitiveContains(query) ||
                app.description.localizedCaseInsensitiveContains(query)
            }
        }
    }

    // جلب جميع التطبيقات من السورس
    func loadApps() async {
        isLoading = true
        guard let url = URL(string: sourceURL) else {
            isLoading = false
            return
        }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 15
            // تجاوز الكاش لضمان جلب أحدث نسخة من الرابط
            request.cachePolicy = .reloadIgnoringLocalCacheData

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("فشل جلب السورس، كود الخطأ: \(httpResponse.statusCode)")
                isLoading = false
                return
            }

            let jsonObject = try JSONSerialization.jsonObject(with: data)
            var targetArray: [[String: Any]] = []

            // التعامل مع بنية سورس ESign
            if let dict = jsonObject as? [String: Any] {
                if let apps = dict["apps"] as? [[String: Any]] {
                    targetArray = apps
                } else if let items = dict["items"] as? [[String: Any]] {
                    targetArray = items
                }
            } else if let directArray = jsonObject as? [[String: Any]] {
                targetArray = directArray
            }

            var loadedItems: [AppItem] = []
            loadedItems.reserveCapacity(targetArray.count)

            for (idx, dict) in targetArray.enumerated() {
                let name = dict["name"] as? String ?? dict["title"] as? String ?? "تطبيق بدون اسم"
                let version = dict["version"] as? String ?? dict["ver"] as? String ?? "1.0"
                let desc = dict["description"] as? String ?? dict["localizedDescription"] as? String ?? dict["desc"] as? String ?? "تطبيق متوفر على المتجر"
                let iconStr = dict["iconURL"] as? String ?? dict["icon"] as? String ?? dict["image"] as? String ?? ""
                let downloadStr = dict["downloadURL"] as? String ?? dict["downloadLink"] as? String ?? dict["link"] as? String ?? dict["url"] as? String ?? dict["ipa"] as? String ?? ""

                loadedItems.append(AppItem(
                    id: "app-\(idx)-\(name)",
                    name: name,
                    version: version,
                    description: desc,
                    iconURL: URL(string: iconStr),
                    downloadURL: URL(string: downloadStr)
                ))
            }

            self.apps = loadedItems
            print("تم استخراج \(loadedItems.count) تطبيق بنجاح.")

        } catch {
            print("حدث خطأ أثناء تحميل السورس: \(error.localizedDescription)")
        }

        isLoading = false
    }
}