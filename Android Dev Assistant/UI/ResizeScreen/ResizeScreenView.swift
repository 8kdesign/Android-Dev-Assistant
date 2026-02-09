//
//  ResizeScreenView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 9/2/26.
//

import SwiftUI

struct ResizeScreenView: View {
    
    @EnvironmentObject var uiController: UIController
    
    var body: some View {
        PopupView(title: "Mock Screen", exit: { uiController.showingPopup = nil }) {
            
        }
    }
}
