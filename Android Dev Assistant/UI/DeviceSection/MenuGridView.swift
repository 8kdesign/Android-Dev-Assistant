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
                MenuGridItem(name: "Mock Screen", icon: "rectangle.expand.vertical", iconColor: .yellow, requireAdb: true) {
                    uiController.showingPopup = .mockScreenSize
                }
                MenuGridItem(name: "Scrcpy", icon: "smartphone", iconColor: .teal, requireAdb: true) {
                    if let deviceId = adbHelper.selectedDevice {
                        externalToolsHelper.launchScrcpy(deviceId: deviceId, adbPath: adbHelper.adbPath)
                    }
                }
                MenuGridItem(name: "Perfetto", icon: "chart.bar.fill", iconColor: .red, requireAdb: false) {
                    externalToolsHelper.launchPerfetto()
                }
                MenuGridItem(name: "Last Crash", icon: "exclamationmark.triangle.fill", iconColor: .orange, requireAdb: true) {
                    adbHelper.getLastCrashLogs {
                        uiController.showingPopup = .lastCrashLogs(logs: $0)
                    }
                }
            }.padding([.horizontal, .bottom])
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}
