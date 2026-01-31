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
                    Text(item)
                }
            }
        } label: {
            Text("\(adbHelper.selectedDevice ?? "No device connected") \(Image(systemName: "chevron.down"))")
                .font(.title3)
        }.buttonStyle(.plain)
            .padding(.all)
    }
    
}
