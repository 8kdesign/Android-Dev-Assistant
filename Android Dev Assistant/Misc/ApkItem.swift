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
    var lastModified: Date
    
    init(path: String, name: String, lastModified: Date) {
        self.id = path
        self.path = path
        self.name = name
        self.lastModified = lastModified
    }
}
