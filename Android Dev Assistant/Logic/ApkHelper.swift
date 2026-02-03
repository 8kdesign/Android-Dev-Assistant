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
    
    var aaptPath: String? = nil
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
            if let path = await locateAaptViaSDK() {
                Task { @MainActor in
                    self.aaptPath = path
                }
            }
            let items = StorageHelper.shared.getApkItems()
            var infoMap: [String: (name: String?, packageName: String?, versionName: String?)] = [:]
            for item in items {
                infoMap[item.id] = await self.getApkInfo(item)
            }
            let fixedInfoMap = infoMap
            Task { @MainActor in
                for item in items {
                    if let info = fixedInfoMap[item.id] {
                        if let name = info.name {
                            item.name = name
                        }
                        item.packageName = info.packageName
                        item.versionName = info.versionName
                    }
                }
                self.apks = items
                self.objectWillChange.send()
            }
        }
    }
    
    // List

    @MainActor func addApk(_ item: ApkItem) {
        if apks.contains(where: { $0.path == item.path }) { return }
        apks.append(item)
        apks.sort(by: { ($0.lastModified ?? Date(timeIntervalSince1970: 0)) > ($1.lastModified ?? Date(timeIntervalSince1970: 0)) })
        runOnLogicThread {
            StorageHelper.shared.addLink(item.path)
            let info = await self.getApkInfo(item)
            Task { @MainActor in
                if let name = info.name {
                    item.name = name
                }
                item.packageName = info.packageName
                item.versionName = info.versionName
                self.objectWillChange.send()
            }
        }
    }
    
    @MainActor func removeApk(_ path: String) {
        apks.removeAll(where: { $0.path == path })
        runOnLogicThread {
            StorageHelper.shared.removeLink(path)
        }
        objectWillChange.send()
    }
    
    // AAPT
    
    @LogicActor func getApkInfo(_ item: ApkItem) async -> (name: String?, packageName: String?, versionName: String?) {
        guard let data = try? await runCommand(path: await aaptPath, arguments: ["dump", "badging", item.path]) else { return (nil, nil, nil) }
        let result = normalize(String(data: data, encoding: .utf8)).split(separator: "\n").map(String.init)
        var name: String? = nil
        var packageName: String? = nil
        var versionName: String? = nil
        if let packageInfo = result.first(where: { $0.starts(with: "package:") }) {
            packageName = value("name", line: packageInfo)
            versionName = value("versionName", line: packageInfo)
        }
        if let appLabel = result.first(where: { $0.starts(with: "application-label:") }) {
            name = appLabel.split(separator: ":").last?.trimmingCharacters(in: CharacterSet(charactersIn: "'"))
        }
        return (name, packageName, versionName)
    }
    
    @LogicActor private func normalize(_ input: String?) -> String {
        guard let input else { return "" }
        if input.hasPrefix("Optional(\"") && input.hasSuffix("\")") {
            return String(input.dropFirst(10).dropLast(2))
        }
        return input
    }
    
    @LogicActor private func value(_ key: String, line: String) -> String? {
        let pattern = "\(key)='([^']+)'"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(line.startIndex..., in: line)
        guard let match = regex.firstMatch(in: line, range: range),
              let r = Range(match.range(at: 1), in: line) else {
            return nil
        }
        return String(line[r])
    }
    
}
