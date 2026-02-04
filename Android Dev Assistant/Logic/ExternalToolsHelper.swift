//
//  ExternalToolsHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 4/2/26.
//

import Foundation
import SwiftUI
import Combine

class ExternalToolsHelper: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()

    var requestInstall: String? = nil
    var scrcpyPath: String? = nil
    
    var isExternalToolAdbBlocking: Bool = false
    
    init() {
        runOnLogicThread {
            let scrcpyPath = runWhich(command: "scrcpy")
            Task { @MainActor in
                self.scrcpyPath = scrcpyPath
                self.objectWillChange.send()
            }
        }
    }
    
    func launchScrcpy(deviceId: String, adbPath: String?) {
        guard let adbPath else { return }
        guard let scrcpyPath else {
            recheck(command: "scrcpy") { self.scrcpyPath = $0 }
            return
        }
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
                    self.objectWillChange.send()
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
