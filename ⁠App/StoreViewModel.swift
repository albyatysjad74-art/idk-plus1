import Foundation
import Combine

@MainActor
class StoreViewModel: ObservableObject {
    @Published var apps: [AppItem] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    
    // عدد العناصر المعروضة حالياً
    @Published var displayLimit: Int = 50
    private let pageSize: Int = 50

    private let sourceURL = "https://raw.githubusercontent.com/NEXT11DEV/NEXT-SOURCE/main/NEXTDEV-ESign.json"

    // تصفية التطبيقات
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

    // التطبيقات المعروضة في الشاشة فقط (لتفادي البطء)
    var paginatedApps: [AppItem] {
        let currentFiltered = filteredApps
        return Array(currentFiltered.prefix(displayLimit))
    }

    // تحميل المزيد عند الوصول لآخر القائمة
    func loadMoreContentIfNeeded(currentItem app: AppItem) {
        guard let lastItem = paginatedApps.last, lastItem.id == app.id else { return }
        if displayLimit < filteredApps.count {
            displayLimit += pageSize
        }
    }

    // جلب البيانات
    func loadApps() async {
        isLoading = true
        guard let url = URL(string: sourceURL) else {
            isLoading = false
            return
        }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 20
            request.cachePolicy = .reloadIgnoringLocalCacheData

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                isLoading = false
                return
            }

            let jsonObject = try JSONSerialization.jsonObject(with: data)
            var targetArray: [[String: Any]] = []

            if let dict = jsonObject as? [String: Any], let apps = dict["apps"] as? [[String: Any]] {
                targetArray = apps
            } else if let directArray = jsonObject as? [[String: Any]] {
                targetArray = directArray
            }

            var loadedItems: [AppItem] = []
            loadedItems.reserveCapacity(targetArray.count)

            for (idx, dict) in targetArray.enumerated() {
                let name = dict["name"] as? String ?? dict["title"] as? String ?? "تطبيق بدون اسم"
                let version = dict["version"] as? String ?? dict["ver"] as? String ?? "1.0"
                let desc = dict["description"] as? String ?? dict["localizedDescription"] as? String ?? dict["desc"] as? String ?? "لا يوجد وصف متوفر لهذا التطبيق."
                let iconStr = dict["iconURL"] as? String ?? dict["icon"] as? String ?? dict["image"] as? String ?? ""
                let downloadStr = dict["downloadURL"] as? String ?? dict["downloadLink"] as? String ?? dict["link"] as? String ?? dict["url"] as? String ?? dict["ipa"] as? String ?? ""

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
            self.displayLimit = 50 // إعادة تعيين الحد

        } catch {
            print("خطأ أثناء تحميل السورس: \(error.localizedDescription)")
        }

        isLoading = false
    }
}