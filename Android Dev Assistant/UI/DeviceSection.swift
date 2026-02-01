//
//  DeviceSection.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import SwiftUI

struct DeviceSection: View {
    
    @EnvironmentObject var apkHelper: ApkHelper
    @EnvironmentObject var adbHelper: AdbHelper

    var body: some View {
        VStack(spacing: 0) {
            CurrentDeviceSelector()
            if let deviceId = adbHelper.selectedDevice {
                MenuGridView(deviceId: deviceId)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private func CurrentDeviceSelector() -> some View {
        Menu {
            ForEach(Array(adbHelper.currentDevices.enumerated()), id: \.offset) { index, item in
                Button {
                    adbHelper.selectedDevice = item
                } label: {
                    Text(getName(item) ?? "")
                }
            }
        } label: {
            HStack {
                Text(getName(adbHelper.selectedDevice) ?? "No device connected")
                    .font(.title3)
                    .lineLimit(1)
                if adbHelper.selectedDevice != nil {
                    Image(systemName: "chevron.down")
                }
            }
        }.buttonStyle(.plain)
            .padding(.all)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func MenuGridView(deviceId: String) -> some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 5)], spacing: 5) {
                MenuGridItem(deviceId: deviceId, name: "Screenshot", icon: "camera.viewfinder") { adbHelper.screenshot() }
            }.padding([.horizontal, .bottom])
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}

extension DeviceSection {
    
    private func getName(_ id: String?) -> String? {
        guard let id else { return nil }
        return adbHelper.deviceNameMap[id] ?? id
    }
    
}
