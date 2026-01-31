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
    
    @Published var apks: [ApkItem] = [] {
        didSet {
            if (selectedIndex >= apks.count) {
                selectedIndex = max(0, apks.count - 1)
            }
        }
    }
    @Published var selectedIndex: Int = 0

    @MainActor func addApk(_ item: ApkItem) {
        if apks.contains(where: { $0.path == item.path }) { return }
        apks.append(item)
        apks.sort(by: { $0.lastModified > $1.lastModified })
        objectWillChange.send()
    }
    
    @MainActor func removeApk(_ path: String) {
        apks.removeAll(where: { $0.path == path })
        objectWillChange.send()
    }
    
}
