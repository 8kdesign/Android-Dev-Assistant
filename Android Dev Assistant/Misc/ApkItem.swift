//
//  ApkItem.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import Foundation

class ApkItem: Identifiable {
    
    let id: String
    let path: String
    var name: String
    var lastModified: Date?
    
    var packageName: String? = nil
    var versionName: String? = nil
    
    static func fromPath(_ url: URL) -> ApkItem? {
        guard url.pathExtension == "apk" else { return nil }
        let name = url.lastPathComponent
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path())
        let lastModified = attributes?[.modificationDate] as? Date
        return ApkItem(path: url.path(), name: name, lastModified: lastModified)
    }
    
    init(path: String, name: String, lastModified: Date?) {
        self.id = sha256(path)
        self.path = path
        self.name = name
        self.lastModified = lastModified
    }
}
