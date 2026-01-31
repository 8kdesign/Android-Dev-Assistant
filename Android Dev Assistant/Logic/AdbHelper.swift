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
    
    var adbPath: String? = nil
    var currentDevices: Set<String> = []
    @Published var selectedDevice: String? = nil
    var isInstalling: String? = nil
    var deviceNameMap: [String: String] = [:]
    var logs: [String] = []

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
                        self.objectWillChange.send()
                        runOnLogicThread {
                            await self.getName(forDeviceId: id)
                        }
                    case "offline":
                        self.currentDevices.remove(id)
                        if self.selectedDevice == id {
                            self.selectedDevice = self.currentDevices.first
                        }
                        self.objectWillChange.send()
                    default: ()
                    }
                }
            }
        }
    }
    
    @LogicActor private func getName(forDeviceId id: String) async {
        let name = try? await runAdbCommand(adbPath: await adbPath, arguments: ["-s", id, "shell", "getprop", "ro.product.model"])
        if let name, !name.isEmpty {
            Task { @MainActor in
                deviceNameMap[id] = name.trimmingCharacters(in: .whitespacesAndNewlines)
                self.objectWillChange.send()
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
                Task { @MainActor in
                    self.insertLog(string: result)
                }
            } catch {
                Task { @MainActor in
                    self.insertLog(string: error.localizedDescription)
                }
            }
            Task { @MainActor in
                self.isInstalling = nil
                self.objectWillChange.send()
            }
        }
    }
    
    private func insertLog(string: String) {
        let date = Date().formatted(date: .omitted, time: .shortened)
        string.split(whereSeparator: \.isNewline).forEach { line in
            logs.append("\(date): \(line)")
            if (logs.count > 10) {
                logs.removeFirst()
            }
        }
        objectWillChange.send()
    }
    
}
