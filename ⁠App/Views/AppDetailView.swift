import SwiftUI

struct AppDetailView: View {
    let app: AppItem

    @State private var isDownloading = false
    @State private var isSigning = false
    @State private var downloadProgress: Double = 0.0
    @State private var signedIPAPath: URL?
    @State private var statusMessage = ""
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            AppTheme.bgDeepBlue.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    HStack(spacing: 16) {
                        AsyncImage(url: app.iconURL) { phase in
                            if let img = phase.image {
                                img.resizable().scaledToFill()
                            } else {
                                Image(systemName: "app.fill")
                                    .foregroundColor(AppTheme.vibrantBlue)
                                    .font(.system(size: 38))
                            }
                        }
                        .frame(width: 75, height: 75)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        VStack(alignment: .leading, spacing: 5) {
                            Text(app.name)
                                .font(.title3.bold())
                                .foregroundColor(AppTheme.textTitle)

                            Text("الإصدار: \(app.version)")
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.vibrantBlue)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.cardNavy)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // قسم التحميل والتوقيع
                    if let targetURL = app.downloadURL, !targetURL.absoluteString.isEmpty {
                        VStack(spacing: 12) {
                            Button(action: {
                                startDownloadAndSign(from: targetURL)
                            }) {
                                HStack {
                                    if isDownloading || isSigning {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 6)
                                    } else {
                                        Image(systemName: signedIPAPath == nil ? "arrow.down.circle.fill" : "checkmark.circle.fill")
                                    }
                                    
                                    Text(buttonTitle)
                                }
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(buttonBackgroundColor)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .disabled(isDownloading || isSigning)

                            if !statusMessage.isEmpty {
                                Text(statusMessage)
                                    .font(.caption.bold())
                                    .foregroundColor(AppTheme.vibrantBlue)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("وصف التطبيق")
                            .font(.headline.bold())
                            .foregroundColor(AppTheme.textTitle)

                        Text(app.description)
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppTheme.cardNavy)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $showShareSheet) {
            if let fileURL = signedIPAPath {
                ShareActivityView(activityItems: [fileURL])
            }
        }
    }

    private var buttonTitle: String {
        if isDownloading {
            return "جاري التنزيل..."
        } else if isSigning {
            return "جاري توقيع التطبيق..."
        } else if signedIPAPath != nil {
            return "تثبيت / مشاركة التطبيق الموقع"
        } else {
            return "تنزيل وتوقيع الآن"
        }
    }

    private var buttonBackgroundColor: Color {
        if signedIPAPath != nil {
            return Color.green
        }
        return AppTheme.vibrantBlue
    }

    private func startDownloadAndSign(from url: URL) {
        if signedIPAPath != nil {
            showShareSheet = true
            return
        }

        isDownloading = true
        statusMessage = "جاري الاتصال بالسيرفر وتحميل الملف..."

        let task = URLSession.shared.downloadTask(with: url) { tempLocalURL, response, error in
            DispatchQueue.main.async {
                self.isDownloading = false
            }

            guard let tempLocalURL = tempLocalURL, error == nil else {
                DispatchQueue.main.async {
                    self.statusMessage = "فشل التنزيل: تأكد من اتصال الإنترنت أو صحة الرابط."
                }
                return
            }

            let fileManager = FileManager.default
            let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let downloadedIPA = docs.appendingPathComponent("temp_input.ipa")
            let outputIPA = docs.appendingPathComponent("\(app.name)_Signed.ipa")

            do {
                if fileManager.fileExists(atPath: downloadedIPA.path) {
                    try fileManager.removeItem(at: downloadedIPA)
                }
                try fileManager.copyItem(at: tempLocalURL, to: downloadedIPA)

                DispatchQueue.main.async {
                    self.isSigning = true
                    self.statusMessage = "تم التنزيل بنجاح، جاري التوقيع بشهادتك..."
                }

                // جلب مسارات الشهادة المحفوظة
                let p12Path = docs.appendingPathComponent("cert.p12").path
                let provPath = docs.appendingPathComponent("cert.mobileprovision").path
                let password = UserDefaults.standard.string(forKey: "cert_password") ?? ""

                // التحقق من توفر الشهادات
                guard fileManager.fileExists(atPath: p12Path), fileManager.fileExists(atPath: provPath) else {
                    DispatchQueue.main.async {
                        self.isSigning = false
                        self.statusMessage = "خطأ: لم يتم استيراد الشهادة (.p12 و .mobileprovision) من قسم الشهادات."
                    }
                    return
                }

                // تنفيذ التوقيع الداخلي عبر الجسر
                let isSuccess = ZSignBridge.signIPA(
                    downloadedIPA.path,
                    p12Path: p12Path,
                    provPath: provPath,
                    password: password,
                    outputPath: outputIPA.path
                )

                DispatchQueue.main.async {
                    self.isSigning = false
                    if isSuccess && fileManager.fileExists(atPath: outputIPA.path) {
                        self.signedIPAPath = outputIPA
                        self.statusMessage = "تم توقيع التطبيق بنجاح!"
                        self.showShareSheet = true
                    } else {
                        self.statusMessage = "فشل التوقيع: تحقق من كلمة سر الشهادة أو مطابقة المعرف."
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self.isSigning = false
                    self.statusMessage = "حدث خطأ أثناء حفظ الملف: \(error.localizedDescription)"
                }
            }
        }
        task.resume()
    }
}

// نافذة المشاركة لتثبيت التطبيق أو إرساله
struct ShareActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}