import SwiftUI
import Combine

struct SignedAppItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let fileName: String
    let dateAdded: Date
}

class DownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    static let shared = DownloadManager()

    @Published var isDownloading = false
    @Published var isSigning = false
    @Published var progress: Double = 0.0
    @Published var statusText: String = ""
    @Published var currentAppName: String = ""
    @Published var signedApps: [SignedAppItem] = []

    private var downloadTask: URLSessionDownloadTask?
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }()

    override init() {
        super.init()
        loadSavedApps()
    }

    func startDownloadAndSign(app: AppItem) {
        guard let url = app.downloadURL else { return }
        
        currentAppName = app.name
        isDownloading = true
        progress = 0.0
        statusText = "بدء الاتصال بالسيرفر..."

        downloadTask = urlSession.downloadTask(with: url)
        downloadTask?.resume()
    }

    // تتبع نسبة التنزيل في شريط التقدم
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            DispatchQueue.main.async {
                self.progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
                let percent = Int(self.progress * 100)
                self.statusText = "جاري التنزيل: \(percent)%"
            }
        }
    }

    // انتهاء التنزيل والبدء بالتوقيع
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            self.isDownloading = false
            self.isSigning = true
            self.statusText = "اكتمل التنزيل! جاري التوقيع بشهادتك..."
        }

        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let tempIPA = docs.appendingPathComponent("temp_target.ipa")
        let safeName = currentAppName.replacingOccurrences(of: " ", with: "_")
        let outputIPA = docs.appendingPathComponent("\(safeName)_Signed.ipa")

        do {
            if fileManager.fileExists(atPath: tempIPA.path) {
                try fileManager.removeItem(at: tempIPA)
            }
            try fileManager.copyItem(at: location, to: tempIPA)

            let p12Path = docs.appendingPathComponent("cert.p12").path
            let provPath = docs.appendingPathComponent("cert.mobileprovision").path
            let password = UserDefaults.standard.string(forKey: "cert_password") ?? ""

            guard fileManager.fileExists(atPath: p12Path), fileManager.fileExists(atPath: provPath) else {
                DispatchQueue.main.async {
                    self.isSigning = false
                    self.statusText = "خطأ: لم يتم إضافة ملفات الشهادة في قسم الشهادات!"
                }
                return
            }

            // استدعاء zsign
            let success = ZSignBridge.signIPA(tempIPA.path, p12Path: p12Path, provPath: provPath, password: password, outputPath: outputIPA.path)

            DispatchQueue.main.async {
                self.isSigning = false
                if success && fileManager.fileExists(atPath: outputIPA.path) {
                    self.statusText = "تم التوقيع بنجاح!"
                    self.addSignedApp(name: self.currentAppName, fileName: outputIPA.lastPathComponent)
                } else {
                    self.statusText = "فشل التوقيع: تحقق من كلمة سر الشهادة."
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isSigning = false
                self.statusText = "خطأ في معالجة الملف: \(error.localizedDescription)"
            }
        }
    }

    private func addSignedApp(name: String, fileName: String) {
        let newItem = SignedAppItem(name: name, fileName: fileName, dateAdded: Date())
        signedApps.insert(newItem, at: 0)
        saveSavedApps()
    }

    private func saveSavedApps() {
        if let encoded = try? JSONEncoder().encode(signedApps) {
            UserDefaults.standard.set(encoded, forKey: "saved_signed_apps")
        }
    }

    private func loadSavedApps() {
        if let data = UserDefaults.standard.data(forKey: "saved_signed_apps"),
           let decoded = try? JSONDecoder().decode([SignedAppItem].self, from: data) {
            signedApps = decoded
        }
    }
}