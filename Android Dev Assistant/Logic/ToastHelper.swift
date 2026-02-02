//
//  ToastHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 2/2/26.
//

import Foundation
import SwiftUI
import Combine

class ToastHelper: ObservableObject {
    
    static let shared = ToastHelper()
    
    let objectWillChange = ObservableObjectPublisher()

    @Published var toasts: [Toast] = []
    private var toastExpiryDates: [Date] = []
    private var timer: Timer? = nil
    
    @MainActor func addToast(_ message: LocalizedStringResource, icon: String = "info.circle") {
        let expiryDate = Date() + 2
        let newToast = Toast(message: message, icon: icon, expiryDate: expiryDate)
        toastExpiryDates.append(expiryDate)
        toasts.append(newToast)
        objectWillChange.send()
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                Task { @MainActor in
                    self.removeToasts()
                }
            }
        }
    }
    
    @MainActor func removeToasts() {
        let currentDate = Date()
        while let expiryDate = toastExpiryDates.first, expiryDate < currentDate {
            toastExpiryDates.removeFirst()
        }
        while let toast = toasts.first, toast.expiryDate < currentDate {
            toasts.removeFirst()
        }
        objectWillChange.send()
        timer = nil
        if let nextDate = toastExpiryDates.first {
            timer = Timer.scheduledTimer(withTimeInterval: nextDate.timeIntervalSince1970 - currentDate.timeIntervalSince1970, repeats: false) { _ in
                Task { @MainActor in
                    self.removeToasts()
                }
            }
        }
    }
    
    
}
