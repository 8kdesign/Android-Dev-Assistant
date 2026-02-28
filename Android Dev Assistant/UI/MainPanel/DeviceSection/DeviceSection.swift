//
//  DeviceSection.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import SwiftUI

struct DeviceSection: View {

    @EnvironmentObject var adbHelper: AdbHelper
    @EnvironmentObject var externalToolsHelper: ExternalToolsHelper
    @EnvironmentObject var theme: ThemeManager
    @State var input: String = ""
    @FocusState var focusState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CurrentDeviceSelector()
            InputView()
            MenuGridView()
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
                    .font(.title2)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                if adbHelper.selectedDevice != nil {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.primary)
                }
            }
        }.buttonStyle(.plain)
            .hoverOpacity()
            .padding(.all)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func InputView() -> some View {
        HStack {
            Image(systemName: "keyboard")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(.all, 10)
                .foregroundStyle(.primary)
                .opacity(0.7)
            HStack {
                TextField("", text: $input)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .focused($focusState)
                    .foregroundStyle(.primary)
                Image(systemName: "xmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(.primary)
                    .opacity(input.isEmpty ? 0.3 : 0.7)
                    .onTapGesture {
                        input = ""
                        focusState = false
                    }.hoverOpacity(input.isEmpty ? 1 : HOVER_OPACITY)
            }.padding(.horizontal, 20)
                .frame(height: 40)
                .background(Capsule().fill(theme.backgroundTertiary))
                .frame(maxWidth: 200, alignment: .leading)
            Button {
                sendText()
            } label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(input.isEmpty ? theme.surface : .red))
                    .foregroundStyle(input.isEmpty ? Color.primary : Color.white)
            }.buttonStyle(.plain)
                .hoverOpacity()
        }.padding([.horizontal, .bottom])
            .disabled(isAdbDisabled())
            .opacity(isAdbDisabled() ? 0.3 : 1)
    }

}

extension DeviceSection {

    private func isAdbDisabled() -> Bool {
        return adbHelper.isInstalling != nil || adbHelper.selectedDevice == nil || externalToolsHelper.isExternalToolAdbBlocking
    }

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
