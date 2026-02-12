//
//  RepoItem.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 13/2/26.
//

import Foundation

class RepoItem {
    
    var id: String
    var name: String
    var path: String
    
    init(url: URL) {
        id = sha256(url.path())
        name = url.deletingLastPathComponent().lastPathComponent
        path = url.path()
    }
    
}
