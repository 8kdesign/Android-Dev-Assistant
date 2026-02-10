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
    @State var lines: [String] = []
    
    var body: some View {
        PopupView(title: "Last Crash", exit: { uiController.showingPopup = nil }) {
            ScrollView {
                LazyVStack {
                    ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                        Text(String(line))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.white)
                            .foregroundColor(.white)
                    }
                }.padding(.all, 20)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.onAppear {
            lines = logs.split(separator: "\n").map { String($0.suffix(200)) }
        }
    }
    
}
