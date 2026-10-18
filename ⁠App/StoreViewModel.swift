import Foundation
import Combine

@MainActor
class StoreViewModel: ObservableObject {
    @Published var apps: [AppItem] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""

    // رابط سورس كيرا المباشر (يحتوي أكثر من 1100 تطبيق ولعبة)
    private let kiraSourceURL = "https://raw.githubusercontent.com/ikiraplus/ipastore/main/jom.json"

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
    func loadKiraApps() async {
        isLoading = true
        guard let url = URL(string: kiraSourceURL) else {
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // قراءة مرنة لضمان جلب كل العناصر دون استثناء حتى مع اختلاف مسميات المفاتيح
            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                var loadedItems: [AppItem] = []
                loadedItems.reserveCapacity(jsonArray.count)

                for (idx, dict) in jsonArray.enumerated() {
                    let name = dict["name"] as? String ?? dict["title"] as? String ?? "تطبيق بلس"
                    let version = dict["version"] as? String ?? dict["ver"] as? String ?? "1.0"
                    let desc = dict["description"] as? String ?? dict["desc"] as? String ?? "تطبيق من سورس كيرا بلس"
                    let iconStr = dict["icon"] as? String ?? dict["image"] as? String ?? ""
                    let downloadStr = dict["downloadLink"] as? String ?? dict["link"] as? String ?? dict["url"] as? String ?? dict["ipa"] as? String ?? ""

                    loadedItems.append(AppItem(
                        id: "kira-\(idx)",
                        name: name,
                        version: version,
                        description: desc,
                        iconURL: URL(string: iconStr),
                        downloadURL: URL(string: downloadStr)
                    ))
                }

                self.apps = loadedItems
            }
        } catch {
            print("خطأ في قراءة سورس كيرا: \(error)")
        }

        isLoading = false
    }
}