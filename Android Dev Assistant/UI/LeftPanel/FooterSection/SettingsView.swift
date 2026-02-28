//
//  SettingsView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 4/2/26.
//

import SwiftUI

struct SettingsView: View {

    @Environment(\.openURL) private var openURL
    @EnvironmentObject var versionHelper: VersionHelper
    @EnvironmentObject var uiController: UIController
    @EnvironmentObject var adbHelper: AdbHelper
    @EnvironmentObject var apkHelper: ApkHelper
    @EnvironmentObject var theme: ThemeManager

    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "X"
    @State var enableCleanScreenshot: Bool = UserDefaultsHelper.getScreenshotCleanerEnabled()

    var body: some View {
        PopupView(title: "Settings") {
            HStack(spacing: 0) {
                InfoView()
                TogglesView()
            }
        }.onChange(of: enableCleanScreenshot) { value in
            UserDefaultsHelper.setScreenshotCleanerEnabled(value)
        }
    }

    private func InfoView() -> some View {
        VStack(spacing: 10) {
            Text("Android Dev Assistant")
                .font(.title2)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            Text("v\(appVersion)")
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .opacity(0.7)
            if !versionHelper.isUpToDate {
                HStack(spacing: 10) {
                    Image(systemName: "arrowshape.down.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.white)
                        .opacity(0.7)
                        .padding(.vertical, 5)
                    Text("New Version Available")
                        .foregroundStyle(.white)
                        .opacity(0.9)
                }.padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(LinearGradient(
                                colors: [.red, .pink, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing)
                            )
                    ).onTapGesture {
                        openUpdateLink()
                    }.hoverOpacity()
                    .padding(.top, 10)
            }
            Spacer()
            Text("by 8K")
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .opacity(0.3)
        }.padding(.all, 30)
            .frame(maxWidth: 200, maxHeight: .infinity, alignment: .top)
            .background(theme.backgroundInfoPanel)
    }

    private func TogglesView() -> some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                HeaderItemView(title: "Appearance")
                SwitchItemView(title: "Dark mode", isEnabled: $theme.isDarkMode)
                HeaderItemView(title: "Screenshots")
                SwitchItemView(title: "Auto cleanup screenshots", isEnabled: $enableCleanScreenshot)
                HeaderItemView(title: "Folders")
                FolderItemView(title: "ADB", path: adbHelper.adbPath)
                FolderItemView(title: "AAPT", path: apkHelper.aaptPath)
            }.padding(.all, 20)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func HeaderItemView(title: LocalizedStringResource) -> some View {
        Text(title)
            .font(.body)
            .foregroundStyle(theme.badgeText)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .background(RoundedRectangle(cornerRadius: 5).fill(theme.badgeBackground))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
    }

    private func SwitchItemView(title: LocalizedStringResource, isEnabled: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.primary)
            Spacer()
            Toggle(isOn: isEnabled, label: {})
                .toggleStyle(.switch)
        }.frame(maxWidth: .infinity)
    }

    private func FolderItemView(title: LocalizedStringResource, path: String?) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.primary)
                .padding(.horizontal, 10)
                .opacity(0.7)
            HStack(spacing: 0) {
                Text(path ?? String(localized: "Not found"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.primary)
                    .opacity(0.7)
                    .padding(.all)
                    .textSelection(path == nil ? .disabled : .disabled)
                Divider()
                Button {
                    if let path {
                        openFolder(path)
                    }
                } label: {
                    Image(systemName: "folder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.primary)
                        .opacity(0.7)
                        .padding(.all, 16)
                        .background(theme.backgroundTertiary)
                }.buttonStyle(.plain)
                    .hoverOpacity()
            }.frame(maxWidth: .infinity)
                .background(theme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

}

extension SettingsView {

    private func openUpdateLink() {
        if let url = URL(string: "https://github.com/8kdesign/Android-Dev-Assistant/releases/latest") {
            openURL(url)
        }
    }

}
