//
//  AdbHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import Foundation
import SwiftUI
import Combine
import AppKit

class AdbHelper: ObservableObject {
    
    static let shared = AdbHelper()

    let objectWillChange = ObservableObjectPublisher()
    
    var adbPath: String? = nil
    var currentDevices: Set<String> = []
    var deviceNameMap: [String: String] = [:]
    @Published var selectedDevice: String? = nil

    var isInstalling: String? = nil
    @Published var screenshotImage: NSImage? = nil

    init() {
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
                            await self.getName(id: id)
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
    
    @LogicActor private func getName(id: String) async {
        guard let data = try? await runCommand(path: await adbPath, arguments: ["-s", id, "shell", "settings", "get", "global", "device_name"]) else { return }
        let name = String(data: data, encoding: .utf8)
        if let name, !name.isEmpty {
            if name.starts(with: "cmd:") == true { return }
            Task { @MainActor in
                deviceNameMap[id] = name.trimmingCharacters(in: .whitespacesAndNewlines)
                self.objectWillChange.send()
            }
        }
    }
    
    func install(item: ApkItem) {
        guard let adbPath, let selectedDevice, isInstalling == nil else { return }
        isInstalling = item.id
        objectWillChange.send()
        LogHelper.shared.insertLog(string: "Installing app")
        runOnLogicThread {
            do {
                let result = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "install", item.path])
                let message = String(data: result, encoding: .utf8)
                let isSuccess = message?.split(whereSeparator: \.isNewline).last == "Success"
                if isSuccess, let packageName = await item.packageName {
                    let _ = try? await runCommand(
                        path: adbPath,
                        arguments: ["-s", selectedDevice, "shell", "monkey", "-p", packageName, "-c", "android.intent.category.LAUNCHER", "1"]
                    )
                }
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: message ?? "Result parse error")
                    if isSuccess {
                        ToastHelper.shared.addToast("Install success", icon: "arrow.down.circle.dotted")
                    } else {
                        ToastHelper.shared.addToast("Install failed", icon: "exclamationmark.triangle")
                    }
                }
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
            Task { @MainActor in
                self.isInstalling = nil
                self.objectWillChange.send()
            }
        }
    }
    
    func screenshot() {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                let result = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "exec-out", "screencap", "-p"])
                let image = NSImage(data: result)
                if let image {
                    Task { @MainActor in
                        copyToClipboard(image)
                        self.screenshotImage = image
                        self.objectWillChange.send()
                    }
                }
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: image != nil ? "Screenshot copied to clipboard" : "Screenshot failed")
                    if image != nil {
                        ToastHelper.shared.addToast("Copied to clipboard", icon: "list.bullet.clipboard")
                    }
                }
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }
    
    func inputText(input: String) {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                let _ = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "shell", "input", "text", "'\(input)'"])
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: "Paste success")
                }
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }

    func forceRestart(item: ApkItem) {
        guard let adbPath, let selectedDevice,let packageName = item.packageName else { return }
        runOnLogicThread {
            do {
                let _ = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "shell", "am", "force-stop", packageName])
                let _ = try? await runCommand(
                    path: adbPath,
                    arguments: ["-s", selectedDevice, "shell", "monkey", "-p", packageName, "-c", "android.intent.category.LAUNCHER", "1"]
                )
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: "Force restarted")
                }
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }
    
}
