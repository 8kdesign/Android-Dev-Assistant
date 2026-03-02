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
    @Published var lastAnalyzeItemHelper: AnalyzeScreenHelper? = nil

    init() {
        runOnLogicThread {
            guard let path = locateADBViaSDK() else { return }
            await MainActor.run {
                self.adbPath = path
            }
            startADBDeviceListener(adbPath: path) { id, state in
                Task { @MainActor in
                    switch state {
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
                        ToastHelper.shared.addToast("Install success", style: .success)
                    } else {
                        ToastHelper.shared.addToast("Install failed", style: .error)
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
                        ToastHelper.shared.addToast("Copied to clipboard", style: .clipboard)
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
    
    func setScreenSize(type: MockScreenType, originalSize: ScreenSize, onSuccess: @escaping @MainActor () -> ()) {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                let secureSettingsError = try await runCommand(
                    path: adbPath,
                    arguments: ["-s", selectedDevice, "shell", "settings", "put", "global", "adb_enabled", "1"]
                )
                if secureSettingsError.count > 0 {
                    Task { @MainActor in
                        LogHelper.shared.insertLog(string: "WRITE_SECURE_SETTINGS not enabled. Please enable it in developer options")
                        ToastHelper.shared.addToast("WRITE_SECURE_SETTINGS disabled", style: .error)
                    }
                    return
                }
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: "Set screen size")
                    onSuccess()
                }
                if case .NORMAL = type {
                    let result = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "shell", "wm", "size", "reset"])
                    let _ = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "shell", "wm", "density", "reset"])
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
                let result = try await runCommand(
                    path: adbPath,
                    arguments: ["-s", selectedDevice, "logcat", "-b", "crash", "-d", "-v", "threadtime"]
                )
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
    
    func toggleTalkback() {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                let stateResult = try await runCommand(
                    path: adbPath,
                    arguments: ["-s", selectedDevice, "shell", "settings", "get", "secure", "enabled_accessibility_services"]
                )
                let isEnabled = String(data: stateResult, encoding: .utf8)?.split(separator: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .contains(where: { $0 == "com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService" })
                if isEnabled == true {
                    _ = try await runCommand(
                        path: adbPath,
                        arguments: ["-s", selectedDevice, "shell", "settings", "delete", "secure", "enabled_accessibility_services"]
                    )
                    _ = try await runCommand(
                        path: adbPath,
                        arguments: ["-s", selectedDevice, "shell", "am", "force-stop", "com.google.android.marvin.talkback"]
                    )
                    Task { @MainActor in
                        ToastHelper.shared.addToast("TalkBack disabled", style: .normal)
                    }
                } else {
                    _ = try await runCommand(
                        path: adbPath,
                        arguments: ["-s", selectedDevice, "shell", "settings", "put", "secure", "enabled_accessibility_services", "\\com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService"]
                    )
                    Task { @MainActor in
                        ToastHelper.shared.addToast("TalkBack enabled", style: .normal)
                    }
                }
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }
    
    func getLayout(resultCalback: @escaping @MainActor (AnalyzeScreenHelper) -> (), completionCallback: @escaping @MainActor () -> ()) {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            defer {
                Task { @MainActor in
                    completionCallback()
                }
            }
            do {
                let imageData = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "exec-out", "screencap", "-p"])
                let image = NSImage(data: imageData)
                guard let image else { return }
                let densityData = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "shell", "wm", "density"])
                let density = self.getDpScale(String(data: densityData, encoding: .utf8) ?? "")
                let item = await ComponentLayoutItem(image: image, density: density)
                Task { @MainActor in
                    let helper = AnalyzeScreenHelper(layout: item)
                    self.lastAnalyzeItemHelper = helper
                    resultCalback(helper)
                }
                _ = try await runCommand(
                    path: adbPath,
                    arguments: ["-s", selectedDevice, "shell", "uiautomator", "dump", "/sdcard/ui.xml"],
                    timeout: 15
                )
                let data = try await runCommand(
                    path: adbPath,
                    arguments: ["-s", selectedDevice, "shell", "cat", "/sdcard/ui.xml"]
                )
                await item.loadData(data: data)
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }
    
    func listPackages(callback: @escaping @MainActor ([(package: String, debuggable: Bool)]) -> ()) {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                let script = "for p in $(pm list packages -3 | cut -d: -f2); do dumpsys package $p | grep -q 'DEBUGGABLE' && echo D:$p || echo N:$p; done"
                let result = try await runCommand(
                    path: adbPath,
                    arguments: ["-s", selectedDevice, "shell", script]
                )
                let packages = String(data: result, encoding: .utf8)?
                    .split(separator: "\n")
                    .compactMap { line -> (package: String, debuggable: Bool)? in
                        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.hasPrefix("D:") {
                            return (String(trimmed.dropFirst(2)), true)
                        } else if trimmed.hasPrefix("N:") {
                            return (String(trimmed.dropFirst(2)), false)
                        }
                        return nil
                    }
                    .sorted { $0.package < $1.package }
                    ?? []
                Task { @MainActor in
                    callback(packages)
                    LogHelper.shared.insertLog(string: "Listed packages")
                }
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }

    func listSharedPreferences(packageName: String, callback: @escaping @MainActor ([String]) -> ()) {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                let result = try await runCommand(
                    path: adbPath,
                    arguments: ["-s", selectedDevice, "shell", "run-as", packageName, "ls", "shared_prefs/"]
                )
                let files = String(data: result, encoding: .utf8)?
                    .split(separator: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty && $0.hasSuffix(".xml") }
                    ?? []
                Task { @MainActor in
                    callback(files)
                    LogHelper.shared.insertLog(string: "Listed shared preferences")
                }
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }

    func readSharedPreference(packageName: String, fileName: String, callback: @escaping @MainActor (String) -> ()) {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                let result = try await runCommand(
                    path: adbPath,
                    arguments: ["-s", selectedDevice, "shell", "run-as", packageName, "cat", "shared_prefs/\(fileName)"]
                )
                Task { @MainActor in
                    if let content = String(data: result, encoding: .utf8) {
                        callback(content)
                    }
                    LogHelper.shared.insertLog(string: "Read shared preference: \(fileName)")
                }
            } catch {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }

    func listDownloadApks(callback: @escaping @MainActor ([DownloadApkItem]) -> ()) {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            do {
                // List APK files in /sdcard/Download with details
                // Use find + ls to get modification epoch, compatible with Android toybox
                let script = "find /sdcard/Download -name '*.apk' -type f 2>/dev/null | while read f; do echo \"$(ls -ld --full-time \"$f\" 2>/dev/null | awk '{print $6\" \"$7}')|$f\"; done"
                let result = try await runCommand(
                    path: adbPath,
                    arguments: ["-s", selectedDevice, "shell", script]
                )
                let output = String(data: result, encoding: .utf8) ?? ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                var items: [DownloadApkItem] = []
                for line in output.split(separator: "\n") {
                    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { continue }
                    let parts = trimmed.split(separator: "|", maxSplits: 1)
                    guard parts.count == 2 else { continue }
                    let dateStr = String(parts[0]).trimmingCharacters(in: .whitespaces)
                    let path = String(parts[1])
                    let fileName = (path as NSString).lastPathComponent
                    // Parse date, truncate fractional seconds if present
                    let cleanDate = String(dateStr.prefix(19))
                    let date = dateFormatter.date(from: cleanDate) ?? Date.distantPast
                    items.append(DownloadApkItem(
                        path: path,
                        fileName: fileName,
                        date: date
                    ))
                }
                Task { @MainActor in
                    callback(items)
                    LogHelper.shared.insertLog(string: "Listed download APKs")
                }
            } catch {
                Task { @MainActor in
                    callback([])
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }

    func deleteDownloadFiles(paths: [String], callback: @escaping @MainActor (Int) -> ()) {
        guard let adbPath, let selectedDevice else { return }
        runOnLogicThread {
            var deleted = 0
            for path in paths {
                do {
                    let _ = try await runCommand(path: adbPath, arguments: ["-s", selectedDevice, "shell", "rm", path])
                    deleted += 1
                } catch {
                    Task { @MainActor in
                        LogHelper.shared.insertLog(string: "Failed to delete: \(path)")
                    }
                }
            }
            Task { @MainActor in
                callback(deleted)
                LogHelper.shared.insertLog(string: "Deleted \(deleted) file(s)")
            }
        }
    }

    @LogicActor private func getDpScale(_ output: String) -> CGFloat? {
        let patterns = [
            #"Override density:\s*(\d+)"#,
            #"Physical density:\s*(\d+)"#,
            #"Density:\s*(\d+)"#,
            #"(\d+)"#
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(
                    in: output,
                    range: NSRange(output.startIndex..., in: output)
               ),
               let range = Range(match.range(at: 1), in: output),
               let dpi = Int(output[range]) {
                return CGFloat(dpi) / 160.0
            }
        }
        return nil
    }
    
}
