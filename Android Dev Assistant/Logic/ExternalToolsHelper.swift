//
//  ExternalToolsHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 4/2/26.
//

import Foundation
import Combine

class ExternalToolsHelper: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()

    var scrcpyPath: String? = nil
    
    init() {
        runOnLogicThread {
            let scrcpyPath = runWhich(command: "scrcpy")
            Task { @MainActor in
                self.scrcpyPath = scrcpyPath
            }
        }
    }
    
    func launchScrcpy(deviceId: String, adbPath: String?) {
        guard let scrcpyPath, let adbPath else { return }
        runOnLogicThread {
            let result = try await runCommand(
                path: scrcpyPath,
                arguments: ["-s", deviceId],
                environment: [
                    "ADB": adbPath
                ]
            )
        }
    }
    
}
