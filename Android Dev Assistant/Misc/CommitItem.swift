//
//  CommitItem.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 14/2/26.
//

import Foundation

struct CommitItem: Identifiable {
    
    var id: String { longHash }
    let longHash: String
    let shortHash: String
    let author: String
    let date: String
    let message: String
    
}
