import SwiftUI
import Combine

class StoreViewModel: ObservableObject {
    @Published var allApps: [AppItem] = []
    @Published var displayedApps: [AppItem] = []
    @Published var isLoading: Bool = true
    @Published var isDataLoaded: Bool = false
    @Published var searchText: String = ""

    private let pageSize = 30
    private var currentLimit = 30

    var searchResults: [AppItem] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return displayedApps
        }
        return allApps.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    init() {
        fetchApps()
    }

    func fetchApps() {
        self.isLoading = true
        guard let url = URL(string: "https://raw.githubusercontent.com/NEXT11DEV/NEXT-SOURCE/main/NEXTDEV-ESign.json") else {
            self.isLoading = false
            self.isDataLoaded = true
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let data = data, error == nil else {
                    self?.isDataLoaded = true
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(ESignSourceResponse.self, from: data)
                    let fetched = decodedResponse.apps ?? []
                    self?.allApps = fetched
                    self?.currentLimit = self?.pageSize ?? 30
                    self?.displayedApps = Array(fetched.prefix(self?.currentLimit ?? 30))
                } catch {
                    print("Error decoding ESign source: \(error)")
                }
                self?.isDataLoaded = true
            }
        }.resume()
    }

    // تحميل المزيد عند النزول لأسفل القائمة
    func loadMoreIfNeeded(currentItem: AppItem) {
        guard let lastItem = displayedApps.last, lastItem.id == currentItem.id else { return }
        guard currentLimit < allApps.count else { return }

        currentLimit += 20
        displayedApps = Array(allApps.prefix(currentLimit))
    }
}