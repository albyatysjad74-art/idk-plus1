import SwiftUI

struct CertificateSectionView: View {
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.bgDeepBlue.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "signature")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.vibrantBlue)
                                Text("إدارة شهادات المطورين (P12)")
                                    .font(.headline.bold())
                                    .foregroundColor(AppTheme.textTitle)
                            }

                            Text("يمكنك هنا استيراد شهادتك الخاصة وملف التعريف (Mobileprovision) لتوقيع التطبيقات مباشرة بدون قيود.")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.cardNavy)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.cardBorder, lineWidth: 1))

                        VStack(spacing: 12) {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "doc.fill")
                                    Text("اختيار ملف الشهادة (.p12)")
                                    Spacer()
                                    Image(systemName: "chevron.left")
                                }
                                .padding()
                                .background(AppTheme.cardNavy)
                                .foregroundColor(AppTheme.textTitle)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.cardBorder, lineWidth: 1))
                            }

                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                    Text("اختيار ملف (.mobileprovision)")
                                    Spacer()
                                    Image(systemName: "chevron.left")
                                }
                                .padding()
                                .background(AppTheme.cardNavy)
                                .foregroundColor(AppTheme.textTitle)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.cardBorder, lineWidth: 1))
                            }
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("الشهادات والتوقيع")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}