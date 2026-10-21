import SwiftUI

struct AppDetailView: View {
    let app: AppItem
    @ObservedObject var dlManager = DownloadManager.shared
    @State private var shareURL: URL?
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            AppTheme.bgDeepBlue.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    // تفاصيل التطبيق العلوية
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
                        .cornerRadius(16)

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
                    .cornerRadius(16)

                    // قسم التحميل ومؤشر التقدم الحقيقي
                    VStack(spacing: 12) {
                        if dlManager.isDownloading {
                            VStack(spacing: 8) {
                                ProgressView(value: dlManager.progress, total: 1.0)
                                    .progressViewStyle(LinearProgressViewStyle(tint: AppTheme.vibrantBlue))
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                                
                                Text(dlManager.statusText)
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(AppTheme.cardNavy)
                            .cornerRadius(14)
                        } else if dlManager.isSigning {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("جاري توقيع التطبيق...")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.cardNavy)
                            .cornerRadius(14)
                        } else {
                            Button(action: {
                                dlManager.startDownloadAndSign(app: app)
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                    Text("تنزيل وتوقيع التطبيق")
                                }
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.vibrantBlue)
                                .cornerRadius(14)
                            }
                        }

                        if !dlManager.statusText.isEmpty && !dlManager.isDownloading && !dlManager.isSigning {
                            Text(dlManager.statusText)
                                .font(.caption.bold())
                                .foregroundColor(dlManager.statusText.contains("بنجاح") ? .green : .red)
                        }
                    }

                    // قائمة التطبيقات الموقعة والمحفوظة للتثبيت السريع
                    if !dlManager.signedApps.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("التطبيقات الموقعة والجاهزة للتثبيت")
                                .font(.headline.bold())
                                .foregroundColor(AppTheme.textTitle)

                            ForEach(dlManager.signedApps) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.subheadline.bold())
                                            .foregroundColor(.white)
                                        Text(item.dateAdded.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption2)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    Spacer()
                                    Button(action: {
                                        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                        let file = docs.appendingPathComponent(item.fileName)
                                        shareURL = file
                                        showShareSheet = true
                                    }) {
                                        Text("تثبيت / إرسال")
                                            .font(.caption.bold())
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(12)
                                .background(AppTheme.bgDeepBlue.opacity(0.6))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(AppTheme.cardNavy)
                        .cornerRadius(16)
                    }

                    // وصف التطبيق
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
                    .cornerRadius(16)
                }
                .padding()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $showShareSheet) {
            if let fileURL = shareURL {
                ShareActivityView(activityItems: [fileURL])
            }
        }
    }
}