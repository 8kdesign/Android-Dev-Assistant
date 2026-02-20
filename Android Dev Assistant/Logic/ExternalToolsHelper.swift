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
