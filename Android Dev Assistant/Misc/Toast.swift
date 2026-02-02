//
//  Toast.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 2/2/26.
//

import Foundation

class Toast: Identifiable {
    
    var id = UUID()
    var message: LocalizedStringResource
    var icon: String
    var expiryDate: Date
    
    init(message: LocalizedStringResource, icon: String, expiryDate: Date) {
        self.message = message
        self.icon = icon
        self.expiryDate = expiryDate
    }
    
}
