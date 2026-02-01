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
    var logs: [String] = []
    @Published var screenshotImage: NSImage? = nil

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
        guard let data = try? await runAdbCommand(adbPath: await adbPath, arguments: ["-s", id, "shell", "getprop", "ro.product.model"]) else { return }
        let name = String(data: data, encoding: .utf8)
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
                let message = String(data: result, encoding: .utf8)
                Task { @MainActor in
                    self.insertLog(string: message ?? "Result parse error")
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
    
    func screenshot() {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                let result = try await runAdbCommand(adbPath: adbPath, arguments: ["-s", selectedDevice, "exec-out", "screencap", "-p"])
                let image = NSImage(data: result)
                if let image {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.writeObjects([image])
                    Task { @MainActor in
                        self.screenshotImage = image
                        self.objectWillChange.send()
                    }
                }
                Task { @MainActor in
                    self.insertLog(string: image != nil ? "Screenshot copied to clipboard" : "Screenshot failed")
                }
            } catch {
                Task { @MainActor in
                    self.insertLog(string: error.localizedDescription)
                }
            }
        }
    }
    
    func inputText(input: String) {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                let _ = try await runAdbCommand(adbPath: adbPath, arguments: ["-s", selectedDevice, "shell", "input", "text", "'\(input)'"])
                Task { @MainActor in
                    self.insertLog(string: "Paste success")
                }
            } catch {
                Task { @MainActor in
                    self.insertLog(string: error.localizedDescription)
                }
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
