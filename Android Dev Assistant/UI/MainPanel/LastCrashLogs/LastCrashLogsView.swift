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
    @EnvironmentObject var toastHelper: ToastHelper
    var logs: String
    @State var parsedLogs: [(Date, String)] = []
    
    var body: some View {
        PopupView(title: "Last Crash", exit: { uiController.showingPopup = nil }) {
            ScrollView {
                LazyVStack {
                    ForEach(Array(parsedLogs.enumerated()), id: \.offset) { index, item in
                        VStack(spacing: 10) {
                            HStack {
                                Text(item.0.formatted(date: .numeric, time: .complete))
                                    .font(.title3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(.green)
                                    .foregroundColor(.green)
                                Button {
                                    copyToClipboard(item.1 as NSString)
                                    toastHelper.addToast("Copied to clipboard", style: .clipboard)
                                } label: {
                                    Image(systemName: "list.clipboard")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                        .foregroundStyle(.green)
                                        .foregroundColor(.green)
                                }.buttonStyle(.plain)
                                    .hoverOpacity()
                            }.frame(maxWidth: .infinity)
                            Text(item.1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.white)
                                .foregroundColor(.white)
                                .textSelection(.enabled)
                        }.padding(.all)
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollIndicators(.never)
        }.onAppear {
            parseLogs()
        }
    }
    
}

extension LastCrashLogsView {
    
    private func parseLogs() {
        runOnLogicThread {
            var logSets: [(Date, String)] = []
            var lastDate = Date(timeIntervalSince1970: 0)
            var lastMessage = ""
            logs.split(separator: "\n").forEach { line in
                if !line.isEmpty {
                    let pattern = #"^(\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}).*?: (.*)$"#
                    if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                       let match = regex.firstMatch(in: String(line), options: [], range: NSRange(line.startIndex..., in: line)),
                       let timestampRange = Range(match.range(at: 1), in: line),
                       let time = parseLogcatTimestampSafely(String(line[timestampRange])),
                       let messageRange = Range(match.range(at: 2), in: line) {
                        let message = String(line[messageRange])
                        if time.timeIntervalSince1970 - lastDate.timeIntervalSince1970 > 2 {
                            if lastDate.timeIntervalSince1970 > 0 {
                                logSets.append((lastDate, lastMessage))
                            }
                            lastDate = time
                            lastMessage = ""
                        }
                        lastMessage += message + "\n"
                    }
                }
            }
            if !lastMessage.isEmpty {
                logSets.append((lastDate, String(lastMessage.trimmingCharacters(in: .whitespacesAndNewlines).prefix(50000))))
            }
            logSets.sort(by: { $0.0 > $1.0 })
            let finalResult = logSets
            Task { @MainActor in
                parsedLogs = finalResult
            }
        }
    }
    
    @LogicActor func parseLogcatTimestampSafely(_ ts: String) -> Date? {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        // Try current year
        if let date = formatter.date(from: "\(year)-\(ts)"), date <= now {
            return date
        }
        // Otherwise, assume previous year
        return formatter.date(from: "\(year - 1)-\(ts)")
    }
    
}
