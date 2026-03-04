//
//  ContentView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var uiController: UIController
    @EnvironmentObject var externalTool: ExternalToolsHelper
    @EnvironmentObject var theme: ThemeManager
    @State var isRepoTab = UserDefaultsHelper.getLastSelectedTabIsRepo()

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    HeaderTabView(isRepoTab: $isRepoTab)
                    if (isRepoTab) {
                        RepoSection()
                    } else {
                        AppSection()
                    }
                    BottomTogglesSection()
                }.frame(maxWidth: 250, maxHeight: .infinity)
                    .background(theme.backgroundSecondary)
                Divider().opacity(0.7)
                VStack(spacing: 0) {
                    if (isRepoTab) {
                        GitSection()
                    } else {
                        DeviceSection()
                    }
                    Divider().opacity(0.7)
                    LogsSection()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            ScreenshotOverlayView()
            switch uiController.showingPopup {
            case .settings: SettingsView()
            case .screenshot(let image): ScreenshotEditView(image: image)
            case .mockScreenSize: ResizeScreenView()
            case .layout: AnalyzeLayoutPopupView()
            case .lastCrashLogs(let logs): LastCrashLogsView(logs: logs)
            case .sharedPreferences: SharedPreferencesView()
            case .downloadCleanup: DownloadCleanupView()
            case .logcat: LogcatView()
            default: EmptyView()
            }
            ToastView()
        }.frame(minWidth: 900, maxWidth: .infinity, minHeight: 800, maxHeight: .infinity)
            .background(theme.background)
            .preferredColorScheme(theme.colorScheme)
    }
}
