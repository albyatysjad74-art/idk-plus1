import SwiftUI

struct DeveloperSectionView: View {
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.bgDeepBlue.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        VStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 75)
                                .foregroundColor(AppTheme.vibrantBlue)

                            Text("تطوير وإشراف: idk")
                                .font(.title3.bold())
                                .foregroundColor(AppTheme.textTitle)

                            Text("مطور أدوات وتطبيقات متوافقة مع أنظمة iOS")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.cardNavy)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppTheme.cardBorder, lineWidth: 1))

                        VStack(alignment: .leading, spacing: 14) {
                            Text("قنوات الدعم والتحديثات")
                                .font(.headline.bold())
                                .foregroundColor(AppTheme.textTitle)
                                .padding(.horizontal, 4)

                            Link(destination: URL(string: "https://t.me/xar_ipa")!) {
                                HStack(spacing: 12) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(AppTheme.vibrantBlue)
                                        .font(.title3)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("قناة التلجرام الرسمية")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(AppTheme.textTitle)
                                        Text("@xar_ipa")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.left")
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                .padding()
                                .background(AppTheme.cardNavy)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.cardBorder, lineWidth: 1))
                            }
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("عن المطور")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}