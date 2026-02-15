//
//  FileDiff.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 15/2/26.
//

import Foundation

struct FileDiff {
    let file: String
    var added: [String] = []
    var removed: [String] = []
}
