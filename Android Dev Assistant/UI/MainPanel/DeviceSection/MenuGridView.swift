//
//  MenuGridView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 5/2/26.
//

import SwiftUI

struct MenuGridView: View {
    
    @EnvironmentObject var uiController: UIController
    @EnvironmentObject var apkHelper: ApkHelper
    @EnvironmentObject var adbHelper: AdbHelper
    @EnvironmentObject var externalToolsHelper: ExternalToolsHelper
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 10)], spacing: 10) {
                MenuGridItem(name: "Screenshot", icon: "camera.viewfinder", iconColor: .gray, requireAdb: true) {
                    adbHelper.screenshot()
                }
                MenuGridItem(name: "Mock Screen", icon: "rectangle.expand.vertical", iconColor: .red, requireAdb: true) {
                    uiController.showingPopup = .mockScreenSize
                }
                MenuGridItem(name: "Scrcpy", icon: "smartphone", iconColor: .teal, requireAdb: true) {
                    if let deviceId = adbHelper.selectedDevice {
                        externalToolsHelper.launchScrcpy(deviceId: deviceId, adbPath: adbHelper.adbPath)
                    }
                }
                MenuGridItem(name: "Read Layout", icon: "sidebar.squares.left", iconColor: .blue, requireAdb: true) {
                    uiController.showingPopup = .layout
                }
                MenuGridItem(name: "Last Crash", icon: "exclamationmark.triangle.fill", iconColor: .orange, requireAdb: true) {
                    adbHelper.getLastCrashLogs {
                        uiController.showingPopup = .lastCrashLogs(logs: $0)
                    }
                }
                MenuGridItem(name: "TalkBack", icon: "text.bubble.fill", iconColor: Color(red: 0.5, green: 0.2, blue: 1), requireAdb: true) {
                    adbHelper.toggleTalkback()
                }
                MenuGridItem(name: "Shared Prefs", icon: "tray.full.fill", iconColor: .green, requireAdb: true) {
                    uiController.showingPopup = .sharedPreferences
                }
                MenuGridItem(name: "Cleaner", icon: "trash.circle.fill", iconColor: .pink, requireAdb: true) {
                    uiController.showingPopup = .downloadCleanup
                }
            }.padding([.horizontal, .bottom])
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}
