import Foundation
import Combine

@MainActor
class StoreViewModel: ObservableObject {
    @Published var apps: [AppItem] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""

    // رابط سورس التطبيقات المباشر
    private let sourceURL = "https://raw.githubusercontent.com/ikiraplus/ipastore/main/jom.json"

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
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("فشل الاتصال، رمز الاستجابة: \(httpResponse.statusCode)")
                isLoading = false
                return
            }

            let jsonObject = try JSONSerialization.jsonObject(with: data)
            var targetArray: [[String: Any]] = []

            // التعامل مع السورس سواء كان قاموس أو مصفوفة مباشرة
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
                let name = dict["name"] as? String ?? dict["title"] as? String ?? "تطبيق"
                let version = dict["version"] as? String ?? dict["ver"] as? String ?? "1.0"
                let desc = dict["description"] as? String ?? dict["desc"] as? String ?? "تطبيق بلس متوافق مع iOS 16"
                let iconStr = dict["icon"] as? String ?? dict["iconURL"] as? String ?? dict["image"] as? String ?? ""
                let downloadStr = dict["downloadLink"] as? String ?? dict["downloadURL"] as? String ?? dict["link"] as? String ?? dict["url"] as? String ?? dict["ipa"] as? String ?? ""

                loadedItems.append(AppItem(
                    id: "app-\(idx)",
                    name: name,
                    version: version,
                    description: desc,
                    iconURL: URL(string: iconStr),
                    downloadURL: URL(string: downloadStr)
                ))
            }

            self.apps = loadedItems
            print("تم جلب \(loadedItems.count) تطبيق بنجاح.")

        } catch {
            print("خطأ أثناء معالجة البيانات: \(error)")
        }

        isLoading = false
    }
}