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
        VStack {
            CurrentDeviceSelector()
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
                Image(systemName: "chevron.down")
            }
        }.buttonStyle(.plain)
            .padding(.all)
    }
    
}

extension DeviceSection {
    
    private func getName(_ id: String?) -> String? {
        guard let id else { return nil }
        return adbHelper.deviceNameMap[id] ?? id
    }
    
}
