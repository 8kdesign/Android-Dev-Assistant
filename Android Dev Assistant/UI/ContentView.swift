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
    @State var isDeviceTab = true
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    HeaderTabView(isDeviceTab: $isDeviceTab)
                    if (isDeviceTab) {
                        AppSection()
                    } else {
                        RepoSection()
                    }
                    BottomTogglesSection()
                }.frame(maxWidth: 250, maxHeight: .infinity)
                    .background(Color(red: 0.07, green: 0.07, blue: 0.07))
                Divider().opacity(0.7)
                VStack(spacing: 0) {
                    if (isDeviceTab) {
                        DeviceSection()
                    } else {
                        GitSection()
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
            case .lastCrashLogs(let logs): LastCrashLogsView(logs: logs)
            default: EmptyView()
            }
            ToastView()
        }.frame(minWidth: 900, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            .preferredColorScheme(.dark)
    }
}
