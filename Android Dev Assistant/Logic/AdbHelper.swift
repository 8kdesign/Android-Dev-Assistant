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
    var screenshotUrl: URL? = nil
    var currentDevices: Set<String> = []
    var deviceNameMap: [String: String] = [:]
    @Published var selectedDevice: String? = nil {
        didSet {
            objectWillChange.send()
        }
    }

    var isInstalling: String? = nil
    @Published var screenshotImage: NSImage? = nil

    init() {
        runOnLogicThread {
            guard let path = locateADBViaSDK() else { return }
            await MainActor.run {
                self.adbPath = path
            }
            startADBDeviceListener(adbPath: path) { status in
                let lines = status.dropFirst(4).split(whereSeparator: \.isNewline)
                lines.forEach { line in
                    let splitStatus = line.split(separator: "\t")
                    if (splitStatus.count < 2) { return }
                    Task { @MainActor in
                        let id = String(splitStatus[0].trimmingCharacters(in: .whitespacesAndNewlines))
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
        runOnLogicThread {
            await self.setupScreenshotFolder()
        }
    }
    
    @LogicActor func setupScreenshotFolder() async {
        guard let appSupportURL else { return }
        let screenshotUrl = appSupportURL.appendingPathComponent("screenshots", isDirectory: true)
        try? FileManager.default.createDirectory(at: screenshotUrl, withIntermediateDirectories: true)
        Task { @MainActor in
            self.screenshotUrl = screenshotUrl
        }
        if await UserDefaultsHelper.getScreenshotCleanerEnabled() {
            do {
                let content = try FileManager.default.contentsOfDirectory(atPath: screenshotUrl.path(percentEncoded: false))
                guard let cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else { return }
                try content.forEach { item in
                    if (item.hasSuffix(".png")) {
                        let url = screenshotUrl.appending(path: item)
                        let attrs = try FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false))
                        if let creationDate = attrs[.creationDate] as? Date {
                            if creationDate < cutoffDate {
                                try FileManager.default.removeItem(at: url)
                            }
                        }
                    }
                }
            } catch {}
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
    
    func uninstall(item: ApkItem) {
        guard let adbPath, let selectedDevice, let packageName = item.packageName, isInstalling == nil else { return }
        LogHelper.shared.insertLog(string: "Installing app")
        runOnLogicThread {
            do {
                let result = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "uninstall", packageName])
                let message = String(data: result, encoding: .utf8)
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: message ?? "Result parse error")
                }
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
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
                        if let screenshotUrl = self.screenshotUrl  {
                            if !FileManager.default.fileExists(atPath: screenshotUrl.path(percentEncoded: false)) {
                                try? FileManager.default.createDirectory(at: screenshotUrl, withIntermediateDirectories: true)
                            }
                            let savePath = screenshotUrl.appendingPathComponent("\(Date().timeIntervalSince1970).png")
                            FileManager.default.createFile(atPath: savePath.path, contents: result)
                        }
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
        guard let adbPath, let selectedDevice, let packageName = item.packageName else { return }
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
    
    func getScreenSize(callback: @escaping @LogicActor (ScreenSize, ScreenSize) -> ()) {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                let result = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "shell", "wm", "size"])
                var physical: ScreenSize? = nil
                var overrideSize: ScreenSize? = nil
                String(data: result, encoding: .utf8)?.split(separator: "\n").forEach { line in
                    let parts = line.split(separator: ":")
                    guard parts.count == 2 else { return }
                    let size = parts[1].trimmingCharacters(in: .whitespaces)
                    let dims = size.split(separator: "x").compactMap { Int($0) }
                    guard dims.count == 2 else { return }
                    if line.contains("Physical") {
                        physical = ScreenSize(width: dims[0], height: dims[1])
                    } else if line.contains("Override") {
                        overrideSize = ScreenSize(width: dims[0], height: dims[1])
                    }
                }
                if let physical {
                    callback(physical, overrideSize ?? physical)
                }
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: "Get screen size")
                }
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }
    
    func setScreenSize(type: MockScreenType, originalSize: ScreenSize) {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: "Set screen size")
                }
                if case .NORMAL = type {
                    let result = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "shell", "wm", "size", "reset"])
                    if let message = String(data: result, encoding: .utf8) {
                        Task { @MainActor in
                            LogHelper.shared.insertLog(string: message)
                        }
                    }
                } else {
                    guard let size = type.getScreenSize(originalSize: originalSize) else { return }
                    let result = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "shell", "wm", "size", "\(size.width)x\(size.height)"])
                    if let message = String(data: result, encoding: .utf8) {
                        Task { @MainActor in
                            LogHelper.shared.insertLog(string: message)
                        }
                    }
                }
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }
    
    func getLastCrashLogs(callback: @escaping @MainActor (String) -> ()) {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                let result = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "logcat", "-d", "*:E"])
                Task { @MainActor in
                    if let string = String(data: result, encoding: .utf8) {
                        callback(string)
                    }
                    LogHelper.shared.insertLog(string: "Get crash logs")
                }
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }
    
}
