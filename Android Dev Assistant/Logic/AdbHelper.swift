//
//  AdbHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import Foundation
import SwiftUI
import Combine

class AdbHelper: ObservableObject {
    
    static let shared = AdbHelper()

    let objectWillChange = ObservableObjectPublisher()
    
    @Published var adbPath: String? = nil
    @Published var currentDevices: Set<String> = []
    @Published var selectedDevice: String? = nil
    @Published var isInstalling: String? = nil

    func initialize() {
        runOnLogicThread {
            guard let path = locateADBViaSDK() else { return }
            await MainActor.run {
                self.adbPath = path
            }
            startADBDeviceListener(adbPath: path) { status in
                let splitStatus = status.split(separator: "\t")
                if (splitStatus.count < 2) { return }
                Task { @MainActor in
                    let id = String(splitStatus[0].trimmingCharacters(in: .whitespacesAndNewlines).dropFirst(4))
                    switch splitStatus[1].trimmingCharacters(in: .whitespacesAndNewlines) {
                    case "device":
                        self.currentDevices.insert(id)
                        if self.selectedDevice == nil {
                            self.selectedDevice = id
                        }
                    case "offline": self.currentDevices.remove(id)
                    default: ()
                    }
                }
            }
        }
    }
    
    func install(item: ApkItem) {
        guard let adbPath, let selectedDevice, isInstalling == nil else { return }
        isInstalling = item.path
        objectWillChange.send()
        runOnLogicThread {
            do {
                let result = try await runAdbCommand(adbPath: adbPath, arguments: ["-s", selectedDevice, "install", item.path])
                print(result)
            } catch {
                print(error)
            }
            Task { @MainActor in
                self.isInstalling = nil
                self.objectWillChange.send()
            }
        }
    }
    
}
