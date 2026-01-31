//
//  ApkHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import Foundation
import SwiftUI
import Combine

class ApkHelper: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    
    var apks: [ApkItem] = [] {
        didSet {
            if (selectedIndex >= apks.count) {
                selectedIndex = max(0, apks.count - 1)
            }
        }
    }
    @Published var selectedIndex: Int = 0
    
    init() {
        runOnLogicThread {
            let items = StorageHelper.shared.getApkItems()
            Task { @MainActor in
                self.apks = items
                self.objectWillChange.send()
            }
        }
    }

    @MainActor func addApk(_ item: ApkItem) {
        if apks.contains(where: { $0.path == item.path }) { return }
        apks.append(item)
        apks.sort(by: { $0.lastModified > $1.lastModified })
        runOnLogicThread {
            StorageHelper.shared.addLink(item.path)
        }
        objectWillChange.send()
    }
    
    @MainActor func removeApk(_ path: String) {
        apks.removeAll(where: { $0.path == path })
        runOnLogicThread {
            StorageHelper.shared.removeLink(path)
        }
        objectWillChange.send()
    }
    
}
