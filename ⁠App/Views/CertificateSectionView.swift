import SwiftUI
import UniformTypeIdentifiers

struct CertificateSectionView: View {
    @State private var p12FileName: String = ""
    @State private var provFileName: String = ""
    @State private var passwordText: String = ""
    
    @State private var showP12Picker = false
    @State private var showProvPicker = false
    @State private var alertMessage = ""
    @State private var showAlert = false

    var body: some View {
        ZStack {
            AppTheme.bgDeepBlue.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("إدارة الشهادات")
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.textTitle)
                        .padding(.top, 10)

                    // 1. اختيار ملف p12
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ملف الشهادة (.p12)")
                            .font(.headline)
                            .foregroundColor(AppTheme.textTitle)

                        Button(action: {
                            showP12Picker = true
                        }) {
                            HStack {
                                Image(systemName: p12FileName.isEmpty ? "doc.badge.plus" : "checkmark.seal.fill")
                                    .foregroundColor(p12FileName.isEmpty ? AppTheme.vibrantBlue : .green)
                                    .font(.title3)
                                
                                Text(p12FileName.isEmpty ? "اضغط لاختيار ملف p12" : p12FileName)
                                    .font(.subheadline.bold())
                                    .foregroundColor(p12FileName.isEmpty ? AppTheme.textSecondary : .white)
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.cardNavy)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(p12FileName.isEmpty ? Color.clear : Color.green.opacity(0.6), lineWidth: 1.5)
                            )
                        }
                    }

                    // 2. اختيار ملف mobileprovision
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ملف التعريف (.mobileprovision)")
                            .font(.headline)
                            .foregroundColor(AppTheme.textTitle)

                        Button(action: {
                            showProvPicker = true
                        }) {
                            HStack {
                                Image(systemName: provFileName.isEmpty ? "doc.text.fill" : "checkmark.seal.fill")
                                    .foregroundColor(provFileName.isEmpty ? AppTheme.vibrantBlue : .green)
                                    .font(.title3)
                                
                                Text(provFileName.isEmpty ? "اضغط لاختيار ملف provision" : provFileName)
                                    .font(.subheadline.bold())
                                    .foregroundColor(provFileName.isEmpty ? AppTheme.textSecondary : .white)
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.cardNavy)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(provFileName.isEmpty ? Color.clear : Color.green.opacity(0.6), lineWidth: 1.5)
                            )
                        }
                    }

                    // 3. كلمة المرور
                    VStack(alignment: .leading, spacing: 8) {
                        Text("كلمة مرور الشهادة")
                            .font(.headline)
                            .foregroundColor(AppTheme.textTitle)

                        SecureField("أدخل كلمة المرور (إن وجدت)", text: $passwordText)
                            .padding()
                            .background(AppTheme.cardNavy)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }

                    // 4. زر الحفظ
                    Button(action: saveCertificateSettings) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("حفظ الشهادة للاستخدام")
                        }
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.vibrantBlue)
                        .cornerRadius(14)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear(perform: loadCurrentSavedCert)
        .fileImporter(isPresented: $showP12Picker, allowedContentTypes: [.data, .item], allowsMultipleSelection: false) { result in
            handleFileSelection(result: result, targetExtension: "p12")
        }
        .fileImporter(isPresented: $showProvPicker, allowedContentTypes: [.data, .item], allowsMultipleSelection: false) { result in
            handleFileSelection(result: result, targetExtension: "mobileprovision")
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("تنبيه"), message: Text(alertMessage), dismissButton: .default(Text("حسناً")))
        }
    }

    private func handleFileSelection(result: Result<[URL], Error>, targetExtension: String) {
        do {
            guard let selectedFile = try result.get().first else { return }
            
            // تفعيل صلاحية القراءة من نظام الملفات
            if selectedFile.startAccessingSecurityScopedResource() {
                defer { selectedFile.stopAccessingSecurityScopedResource() }
                
                let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let destination = docs.appendingPathComponent("cert.\(targetExtension)")
                
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.copyItem(at: selectedFile, to: destination)
                
                if targetExtension == "p12" {
                    p12FileName = selectedFile.lastPathComponent
                } else {
                    provFileName = selectedFile.lastPathComponent
                }
            }
        } catch {
            alertMessage = "فشل استيراد الملف: \(error.localizedDescription)"
            showAlert = true
        }
    }

    private func saveCertificateSettings() {
        UserDefaults.standard.set(passwordText, forKey: "cert_password")
        alertMessage = "تم حفظ إعدادات الشهادة بنجاح! جاهزة لتوقيع أي تطبيق."
        showAlert = true
    }

    private func loadCurrentSavedCert() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let p12 = docs.appendingPathComponent("cert.p12")
        let prov = docs.appendingPathComponent("cert.mobileprovision")

        if FileManager.default.fileExists(atPath: p12.path) {
            p12FileName = "تم حفظ cert.p12 سابقاً"
        }
        if FileManager.default.fileExists(atPath: prov.path) {
            provFileName = "تم حفظ cert.mobileprovision سابقاً"
        }
        passwordText = UserDefaults.standard.string(forKey: "cert_password") ?? ""
    }
}