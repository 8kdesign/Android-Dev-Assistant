//
//  UIController.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 9/2/26.
//

import Foundation
import Combine

class UIController: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var showingPopup: PopupScreen? = nil {
        didSet {
            objectWillChange.send()
        }
    }
    
}
