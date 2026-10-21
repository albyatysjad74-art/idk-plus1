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
        // رابط ملف apps.json الخاص بك على GitHub
        guard let url = URL(string: "https://raw.githubusercontent.com/albyatysjad74-art/idk-plus1/main/apps.json") else {
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let data = data, error == nil else { return }
                do {
                    let decodedApps = try JSONDecoder().decode([AppItem].self, data: data)
                    self?.apps = decodedApps
                } catch {
                    print("Error decoding apps: \(error)")
                }
            }
        }.resume()
    }
}
