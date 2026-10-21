import SwiftUI
import Combine

class StoreViewModel: ObservableObject {
    @Published var apps: [AppItem] = []
    @Published var isLoading: Bool = false

    init() {
        fetchApps()
    }

    func fetchApps() {
        self.isLoading = true
        // رابط سورس ESign الخاص بك
        guard let url = URL(string: "https://raw.githubusercontent.com/NEXT11DEV/NEXT-SOURCE/main/NEXTDEV-ESign.json") else {
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let data = data, error == nil else { return }
                
                do {
                    // فك ترميز بنية ESign Source
                    let response = try JSONDecoder().decode(ESignSourceResponse.self, data: data)
                    self?.apps = response.apps ?? []
                } catch {
                    print("Error decoding ESign source: \(error)")
                }
            }
        }.resume()
    }
}