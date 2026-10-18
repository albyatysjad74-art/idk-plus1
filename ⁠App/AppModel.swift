import Foundation

// نموذج التطبيق الموحد لمتجر idk Plus
struct AppItem: Identifiable, Hashable {
    let id: String
    let name: String
    let version: String
    let description: String
    let iconURL: URL?
    let downloadURL: URL?
}