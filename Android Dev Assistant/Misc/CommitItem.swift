//
//  CommitItem.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 14/2/26.
//

import Foundation

struct CommitItem: Identifiable, Equatable, Hashable {
    
    var id: String { longHash }
    let longHash: String
    let shortHash: String
    let author: String
    let date: String
    let message: String
    
    
    static func == (lhs: CommitItem, rhs: CommitItem) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(longHash)
    }
    
}
