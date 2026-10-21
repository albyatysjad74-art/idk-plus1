import SwiftUI
import Combine

class StoreViewModel: ObservableObject {
    @Published var apps: [AppItem] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""

    var filteredApps: [AppItem] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return apps
        }
        return apps.filter {
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
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let data = data, error == nil else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(ESignSourceResponse.self, from: data)
                    self?.apps = decodedResponse.apps ?? []
                } catch {
                    print("Error decoding ESign source: \(error)")
                }
            }
        }.resume()
    }
}