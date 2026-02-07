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

    var deviceId: String
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 10)], spacing: 10) {
                MenuGridItem(deviceId: deviceId, name: "Screenshot", icon: "camera.viewfinder") { adbHelper.screenshot() }
                MenuGridItem(deviceId: deviceId, name: "Scrcpy", icon: "smartphone") {
                    externalToolsHelper.launchScrcpy(deviceId: deviceId, adbPath: adbHelper.adbPath)
                }
                MenuGridItem(deviceId: deviceId, name: "Perfetto", icon: "chart.bar.fill") {
                    externalToolsHelper.launchPerfetto()
                }
            }.padding([.horizontal, .bottom])
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}
