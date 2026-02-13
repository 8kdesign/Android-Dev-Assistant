//
//  RepoItem.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 13/2/26.
//

import Foundation

class RepoItem: Identifiable {
    
    var id: String
    var name: String
    var path: String
    
    init(url: URL) {
        id = sha256(url.path(percentEncoded: false))
        name = url.lastPathComponent
        path = url.path(percentEncoded: false)
    }
    
}
