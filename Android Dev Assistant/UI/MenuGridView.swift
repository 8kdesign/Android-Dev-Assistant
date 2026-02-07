//
//  MenuGridView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 5/2/26.
//

import SwiftUI

struct MenuGridView: View {
    
    @EnvironmentObject var apkHelper: ApkHelper
    @EnvironmentObject var adbHelper: AdbHelper
    @EnvironmentObject var externalToolsHelper: ExternalToolsHelper
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 10)], spacing: 10) {
                MenuGridItem(name: "Screenshot", icon: "camera.viewfinder", requireSelectedDevice: true) { adbHelper.screenshot() }
                MenuGridItem(name: "Scrcpy", icon: "smartphone", requireSelectedDevice: true) {
                    if let deviceId = adbHelper.selectedDevice {
                        externalToolsHelper.launchScrcpy(deviceId: deviceId, adbPath: adbHelper.adbPath)
                    }
                }
                MenuGridItem(name: "Perfetto", icon: "chart.bar.fill", requireSelectedDevice: false) {
                    externalToolsHelper.launchPerfetto()
                }
            }.padding([.horizontal, .bottom])
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}
