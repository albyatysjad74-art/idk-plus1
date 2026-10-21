import Foundation
import Combine

@MainActor
class StoreViewModel: ObservableObject {
    // جميع التطبيقات القادمة من السورس (في الذاكرة فقط بدون رسمها في الواجهة)
    private var allRawApps: [AppItem] = []
    
    // التطبيقات المعروضة للمستخدم فعلياً
    @Published var displayedApps: [AppItem] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var searchText: String = "" {
        didSet {
            resetAndFilter()
        }
    }

    private let pageSize = 30
    private var currentIndex = 0
    private let sourceURL = "https://raw.githubusercontent.com/NEXT11DEV/NEXT-SOURCE/main/NEXTDEV-ESign.json"

    // التطبيقات بعد الفلترة بالبحث
    private var currentFilteredPool: [AppItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return allRawApps
        } else {
            return allRawApps.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.description.localizedCaseInsensitiveContains(query)
            }
        }
    }

    // إجمالي التطبيقات المتاحة حالياً
    var totalCount: Int {
        currentFilteredPool.count
    }

    func loadApps() async {
        guard allRawApps.isEmpty else { return }
        isLoading = true

        guard let url = URL(string: sourceURL) else {
            isLoading = false
            return
        }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 15

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
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
                let name = dict["name"] as? String ?? dict["title"] as? String ?? "تطبيق"
                let version = dict["version"] as? String ?? dict["ver"] as? String ?? "1.0"
                let desc = dict["description"] as? String ?? dict["localizedDescription"] as? String ?? dict["desc"] as? String ?? "لا يوجد وصف متوفر"
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

            self.allRawApps = loadedItems
            resetAndFilter()

        } catch {
            print("خطأ السورس: \(error)")
        }

        isLoading = false
    }

    private func resetAndFilter() {
        currentIndex = 0
        displayedApps = []
        loadNextBatch()
    }

    // ضخ دفعة جديدة عند النزول
    func loadNextBatch() {
        guard !isLoadingMore else { return }
        let pool = currentFilteredPool
        guard currentIndex < pool.count else { return }

        isLoadingMore = true
        let nextIndex = min(currentIndex + pageSize, pool.count)
        let newBatch = pool[currentIndex..<nextIndex]
        
        displayedApps.append(contentsOf: newBatch)
        currentIndex = nextIndex
        isLoadingMore = false
    }

    // التحقق عند ظهور العنصر
    func onItemAppear(_ item: AppItem) {
        guard let last = displayedApps.last, last.id == item.id else { return }
        loadNextBatch()
    }
}