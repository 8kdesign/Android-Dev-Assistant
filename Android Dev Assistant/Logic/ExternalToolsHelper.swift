//
//  ExternalToolsHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 4/2/26.
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

class ExternalToolsHelper: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()

    var toolsUrl: URL? = nil
    var requestInstall: String? = nil
    var scrcpyPath: String? = nil
    
    var isExternalToolAdbBlocking: Bool = false
    
    init() {
        runOnLogicThread {
            guard let appSupportURL else { return }
            let toolsUrl = appSupportURL.appendingPathComponent("tools", isDirectory: true)
            try? FileManager.default.createDirectory(at: toolsUrl, withIntermediateDirectories: true)
            let scrcpyPath = runWhich(command: "scrcpy")
            Task { @MainActor in
                self.toolsUrl = toolsUrl
                self.scrcpyPath = scrcpyPath
                self.objectWillChange.send()
            }
        }
    }
    
    func launchScrcpy(deviceId: String, adbPath: String?, isRetry: Bool = false) {
        guard let adbPath else { return }
        guard let scrcpyPath else {
            recheck(command: "scrcpy") {
                self.scrcpyPath = $0
                if (isRetry) {
                    self.objectWillChange.send()
                } else {
                    self.launchScrcpy(deviceId: deviceId, adbPath: adbPath, isRetry: true)
                }
            }
            return
        }
        LogHelper.shared.insertLog(string: "Starting scrcpy")
        isExternalToolAdbBlocking = true
        objectWillChange.send()
        runOnLogicThread {
            let _ = try await runCommand(
                path: scrcpyPath,
                arguments: ["-s", deviceId],
                environment: [
                    "ADB": adbPath
                ]
            )
            Task { @MainActor in
                self.isExternalToolAdbBlocking = false
                self.objectWillChange.send()
            }
        }
    }
    
    func launchPerfetto() {
        guard let toolsUrl else { return }
        runOnLogicThread {
            let perfettoPath = toolsUrl.appendingPathComponent("trace_processor").path(percentEncoded: false)
            if !FileManager.default.fileExists(atPath: perfettoPath) {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: "Downloading Perfetto")
                }
                _ = try await runCommand(path: "/usr/bin/curl", arguments: ["-LO", "https://get.perfetto.dev/trace_processor"], directory: toolsUrl)
                _ = try await runCommand(path: "/bin/chmod", arguments: ["+x", "./trace_processor"], directory: toolsUrl)
            }
            Task { @MainActor in
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseFiles = true
                panel.canChooseDirectories = false
                if panel.runModal() == .OK, let url = panel.url {
                    LogHelper.shared.insertLog(string: "Starting Perfetto")
                    runOnLogicThread {
                        let result = try await runCommand(path: perfettoPath, arguments: ["--httpd", url.path(percentEncoded: false)], directory: toolsUrl)
                        if let stringResult = String(data: result, encoding: .utf8) {
                            Task { @MainActor in
                                LogHelper.shared.insertLog(string: stringResult)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func recheck(command: String, set: @escaping (String) -> ()) {
        runOnLogicThread {
            if let path = runWhich(command: command) {
                Task { @MainActor in
                    set(path)
                }
            } else {
                Task { @MainActor in
                    LogHelper.shared.insertLog(string: "Not found. Please install using \"brew install \(command)\".")
                    self.requestInstall = command
                    self.objectWillChange.send()
                }
            }
        }
    }
    
}
