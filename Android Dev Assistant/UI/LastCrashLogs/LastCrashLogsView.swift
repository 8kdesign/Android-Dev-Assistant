//
//  LastCrashLogsView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 10/2/26.
//

import SwiftUI
import AppKit

struct LastCrashLogsView: View {
    
    @EnvironmentObject var uiController: UIController
    var logs: String
    @State var parsedLogs: AttributedString = ""
    
    var body: some View {
        PopupView(title: "Last Crash", exit: { uiController.showingPopup = nil }) {
            ScrollView {
                Text(parsedLogs)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .textSelection(.enabled)
                    .padding(.all)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.onAppear {
            parseLogs()
        }
    }
    
}

extension LastCrashLogsView {
    
    private func parseLogs() {
        runOnLogicThread {
            var result = AttributedString()
            logs.prefix(50000).split(separator: "\n").forEach { line in
                if !line.isEmpty {
                    let pattern = #"^(\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}).*?: (.*)$"#
                    if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                       let match = regex.firstMatch(in: String(line), options: [], range: NSRange(line.startIndex..., in: line)),
                       let timestampRange = Range(match.range(at: 1), in: line),
                       let messageRange = Range(match.range(at: 2), in: line) {
                        let timestampString = String(line[timestampRange])
                        var coloredTimeStampString = AttributedString(timestampString)
                        coloredTimeStampString.foregroundColor = .green
                        result += coloredTimeStampString
                        result += AttributedString(" \(String(line[messageRange]))\n")
                    }
                }
            }
            let fixedResult = result
            Task { @MainActor in
                parsedLogs = fixedResult
            }
        }
    }
    
}
