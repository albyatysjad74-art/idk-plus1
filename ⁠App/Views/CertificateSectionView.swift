import SwiftUI
import UniformTypeIdentifiers

struct CertificateSectionView: View {
    @State private var p12FileName: String = "لم يتم اختيار ملف p12"
    @State private var provFileName: String = "لم يتم اختيار ملف provision"
    @State private var certPassword: String = ""
    @State private var showingP12Picker = false
    @State private var showingProvPicker = false
    @State private var alertMessage = ""
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // قسم رفع ملف P12
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ملف الشهادة (.p12)")
                                .font(.headline)
                                .foregroundColor(.white)

                            Button(action: { showingP12Picker = true }) {
                                HStack {
                                    Image(systemName: "doc.badge.plus")
                                    Text(p12FileName)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding()
                                .background(AppTheme.cardNavy)
                                .cornerRadius(12)
                                .foregroundColor(AppTheme.vibrantBlue)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                                )
                            }
                        }

                        // قسم رفع ملف Provision
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ملف التعريف (.mobileprovision)")
                                .font(.headline)
                                .foregroundColor(.white)

                            Button(action: { showingProvPicker = true }) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                    Text(provFileName)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding()
                                .background(AppTheme.cardNavy)
                                .cornerRadius(12)
                                .foregroundColor(AppTheme.vibrantBlue)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                                )
                            }
                        }

                        // حقل كلمة السر
                        VStack(alignment: .leading, spacing: 10) {
                            Text("كلمة مرور الشهادة")
                                .font(.headline)
                                .foregroundColor(.white)

                            SecureField("أدخل الرمز أو اتركه فارغاً", text: $certPassword)
                                .padding()
                                .background(AppTheme.cardNavy)
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                                )
                        }

                        // زر الحفظ
                        Button(action: saveCertificateData) {
                            Text("حفظ الشهادة للاستخدام")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.vibrantBlue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationTitle("إدارة الشهادات")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingP12Picker) {
                DocumentPicker(types: [UTType(filenameExtension: "p12") ?? .data]) { url in
                    saveFileToDocuments(url: url, destName: "cert.p12")
                    p12FileName = url.lastPathComponent
                }
            }
            .sheet(isPresented: $showingProvPicker) {
                DocumentPicker(types: [UTType(filenameExtension: "mobileprovision") ?? .data]) { url in
                    saveFileToDocuments(url: url, destName: "profile.mobileprovision")
                    provFileName = url.lastPathComponent
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("تنبيه"), message: Text(alertMessage), dismissButton: .default(Text("حسناً")))
            }
        }
    }

    private func saveFileToDocuments(url: URL, destName: String) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dest = docs.appendingPathComponent(destName)
        
        try? fileManager.removeItem(at: dest)
        try? fileManager.copyItem(at: url, to: dest)
    }

    private func saveCertificateData() {
        UserDefaults.standard.set(certPassword, forKey: "CertPassword")
        alertMessage = "تم حفظ الشهادة بنجاح، يمكنك الآن توقيع أي تطبيق من المتجر."
        showAlert = true
    }
}

// منتقي الملفات من الآيفون
struct DocumentPicker: UIViewControllerRepresentable {
    let types: [UTType]
    let onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        init(_ parent: DocumentPicker) { self.parent = parent }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.onPick(url)
            }
        }
    }
}