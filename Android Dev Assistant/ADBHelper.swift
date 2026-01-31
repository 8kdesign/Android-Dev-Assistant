//
//  ADBHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import Foundation
import SwiftUI
import Combine

class ADBHelper: ObservableObject {
    
    static let shared = ADBHelper()

    let objectWillChange = ObservableObjectPublisher()
    
    @Published var adbPath: String? = nil
    var currentDevices: Set<String> = []
    
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
                    case "device": self.currentDevices.insert(id)
                    case "offline": self.currentDevices.remove(id)
                    default: ()
                    }
                }
            }
        }
    }
    
}
