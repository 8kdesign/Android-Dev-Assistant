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
    @State var input: String = ""
    @FocusState var focusState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CurrentDeviceSelector()
            if let deviceId = adbHelper.selectedDevice {
                InputView(deviceId: deviceId)
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
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                }
            }
        } label: {
            HStack {
                Text(getName(adbHelper.selectedDevice) ?? "No device connected")
                    .font(.title3)
                    .lineLimit(1)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                if adbHelper.selectedDevice != nil {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                }
            }
        }.buttonStyle(.plain)
            .padding(.all)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func InputView(deviceId: String) -> some View {
        HStack {
            Image(systemName: "keyboard")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(.all, 10)
                .foregroundStyle(.white)
                .foregroundColor(.white)
            HStack {
                TextField("", text: $input)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .focused($focusState)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                Image(systemName: "xmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .opacity(0.3)
                    .onTapGesture {
                        input = ""
                        focusState = false
                    }
            }.padding(.horizontal, 20)
                .frame(height: 40)
                .background(Capsule().fill(Color(red: 0.1, green: 0.1, blue: 0.1)))
                .frame(maxWidth: 200, alignment: .leading)
            Button {
                sendText()
            } label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(input.isEmpty ? Color(red: 0.15, green: 0.15, blue: 0.15) : .red))
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
            }.buttonStyle(.plain)
        }.padding([.horizontal, .bottom])
            
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
    
    private func sendText() {
        if input.isEmpty { return }
        adbHelper.inputText(input: input)
        input = ""
        focusState = false
    }
    
}
