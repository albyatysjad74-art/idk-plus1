import Foundation
import Combine

@MainActor
class StoreViewModel: ObservableObject {
    @Published var apps: [AppItem] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""

    // روابط المصادر الرسمية لمتجر idk Plus
    private let source1URL = "https://raw.githubusercontent.com/ikiraplus/ipastore/main/jom.json"
    private let source2URL = "https://ipaomtk.com/wp-json/wp/v2/posts?per_page=50"

    // تصفية التطبيقات حسب شريط البحث
    var filteredApps: [AppItem] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return apps
        } else {
            return apps.filter { app in
                app.name.localizedCaseInsensitiveContains(searchText) ||
                app.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // جلب ودمج المصدرين في نفس الوقت
    func loadAllSources() async {
        isLoading = true
        var allApps: [AppItem] = []

        async let fetchSource1 = getJSONApps()
        async let fetchSource2 = getWPApps()

        let (res1, res2) = await (fetchSource1, fetchSource2)
        allApps.append(contentsOf: res1)
        allApps.append(contentsOf: res2)

        self.apps = allApps
        self.isLoading = false
    }

    // معالجة بيانات سورس JSON
    private func getJSONApps() async -> [AppItem] {
        guard let url = URL(string: source1URL) else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let items = try JSONDecoder().decode([JSONStoreItem].self, data: data)
            return items.enumerated().map { idx, item in
                AppItem(
                    id: "json-\(idx)",
                    name: item.name ?? "تطبيق غير معروف",
                    version: item.version ?? "1.0",
                    description: item.description ?? "لا يتوفر وصف لهذا التطبيق",
                    iconURL: URL(string: item.icon ?? ""),
                    downloadURL: URL(string: item.downloadLink ?? item.url ?? ""),
                    sourceBadge: "idk JSON"
                )
            }
        } catch {
            return []
        }
    }

    // معالجة بيانات سورس IPAOMTK
    private func getWPApps() async -> [AppItem] {
        guard let url = URL(string: source2URL) else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let posts = try JSONDecoder().decode([WPPost].self, data: data)
            return posts.map { post in
                let cleanName = TextCleaner.cleanHTML(post.title.rendered)
                let cleanDesc = TextCleaner.cleanHTML(post.excerpt.rendered)
                let imgURL = post.yoast_head_json?.og_image?.first?.url ?? ""

                return AppItem(
                    id: "wp-\(post.id)",
                    name: cleanName.isEmpty ? "تطبيق بلس" : cleanName,
                    version: "أحدث إصدار",
                    description: cleanDesc.isEmpty ? "اضغط على تثبيت لمعاينة التفاصيل والتحميل" : cleanDesc,
                    iconURL: URL(string: imgURL),
                    downloadURL: URL(string: post.link),
                    sourceBadge: "IPAOMTK"
                )
            }
        } catch {
            return []
        }
    }
}