//
//  Toast.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 2/2/26.
//

import Foundation
import SwiftUI

class Toast: Identifiable {
    
    var id = UUID()
    var message: LocalizedStringResource
    var expiryDate: Date
    var style: ToastStyle
    
    init(message: LocalizedStringResource, expiryDate: Date, style: ToastStyle) {
        self.message = message
        self.expiryDate = expiryDate
        self.style = style
    }
    
    enum ToastStyle {
        case normal
        case error
        case success
        case clipboard;
        
        func getIcon() -> String {
            switch self {
            case .normal: return "info.circle"
            case .success: return "checkmark.circle"
            case .error: return "exclamationmark.circle"
            case .clipboard: return "list.bullet.clipboard"
            }
        }
        
        func getColor() -> Color {
            switch self {
            case .success: return Color(red: 0, green: 0.7, blue: 0)
            case .error: return Color(red: 0.7, green: 0, blue: 0)
            default: return Color(red: 0.2, green: 0.2, blue: 0.2)
            }
        }
        
    }
    
}
