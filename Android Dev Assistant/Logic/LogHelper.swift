//
//  LogHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 5/2/26.
//

import SwiftUI
import Combine

class LogHelper: ObservableObject {
    
    static let shared = LogHelper()
    
    let objectWillChange = ObservableObjectPublisher()

    var logs: [String] = []
    
    @MainActor func insertLog(string: String) {
        let date = Date().formatted(date: .omitted, time: .shortened)
        string.split(whereSeparator: \.isNewline).forEach { line in
            logs.insert("\(date): \(line)", at: 0
            )
            if (logs.count > 10) {
                logs.removeLast()
            }
        }
        objectWillChange.send()
    }
    
}

