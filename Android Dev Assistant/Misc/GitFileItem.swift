//
//  GitFileItem.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 14/2/26.
//

import SwiftUI

struct GitFileItem: Identifiable {
    
    var id: String
    var name: String
    var path: String
    
    init(path: String) {
        self.id = sha256(path)
        self.path = path
        self.name = String(path.split(separator: "/").last ?? "")
    }
    
}
