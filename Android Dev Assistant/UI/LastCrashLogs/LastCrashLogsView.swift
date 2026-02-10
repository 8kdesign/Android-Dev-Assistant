//
//  LastCrashLogsView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 10/2/26.
//

import SwiftUI

struct LastCrashLogsView: View {
    
    @EnvironmentObject var uiController: UIController
    var logs: String
    
    var body: some View {
        PopupView(title: "Last Crash", exit: { uiController.showingPopup = nil }) {
            ScrollView {
                Text(String(logs.prefix(50000)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .textSelection(.enabled)
                    .padding(.all)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
}
