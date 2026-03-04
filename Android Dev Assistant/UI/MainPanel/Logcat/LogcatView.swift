//
//  LogcatView.swift
//  Android Dev Assistant
//

import SwiftUI
import AppKit

struct LogcatView: View {

    @EnvironmentObject var adbHelper: AdbHelper
    @EnvironmentObject var toastHelper: ToastHelper
    @EnvironmentObject var theme: ThemeManager
    @State private var parsedLines: [LogcatLine] = []
    @State private var displayedLines: [LogcatLine] = []
    @State private var runningPackages: [(package: String, pid: String)] = []
    @State private var selectedPackage: String = ""
    @State private var packagePids: Set<String> = []
    @State private var tagFilter: String = ""
    @State private var isLoading: Bool = true
    @State private var streamGeneration: Int = 0
    @State private var nextLineId: Int = 0
    @State private var isActive: Bool = true

    private static let maxLines = 1000
    private static let logRegex = try? NSRegularExpression(
        pattern: #"^(\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3})\s+(\d+)\s+(\d+)\s+([VDIWEF])\s+(.+?)\s*:\s(.*)$"#
    )

    var body: some View {
        PopupView(title: "Logcat", willClose: {
            isActive = false
        }, onExit: {
            streamGeneration += 1
            adbHelper.stopLogcatStream()
        }) {
            VStack(spacing: 0) {
                FilterBar()
                Divider().opacity(0.3)
                LogContent()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                loadPackages()
                startStream()
            }
        }
        .onDisappear {
            adbHelper.stopLogcatStream()
        }
    }

    private func loadPackages() {
        adbHelper.listRunningPackages { packages in
            runningPackages = packages
        }
    }

    private func startStream() {
        isLoading = true
        parsedLines = []
        displayedLines = []
        nextLineId = 0
        streamGeneration += 1
        let gen = streamGeneration
        adbHelper.startLogcatStream { rawLines in
            guard gen == streamGeneration else { return }
            appendLines(rawLines)
            if isLoading { isLoading = false }
        }
    }

    private func selectPackage(_ package: String) {
        selectedPackage = package
        if package.isEmpty {
            packagePids = []
            refilter()
        } else {
            packagePids = Set(runningPackages.filter { $0.package == package }.map { $0.pid })
            parsedLines = []
            displayedLines = []
        }
    }

    private func refilter(destructive: Bool = false) {
        let tag = tagFilter.trimmingCharacters(in: .whitespacesAndNewlines)
        if packagePids.isEmpty && tag.isEmpty {
            displayedLines = parsedLines
        } else {
            if destructive {
                parsedLines = parsedLines.filter { line in
                    if !packagePids.isEmpty && !packagePids.contains(line.pid) { return false }
                    if !tag.isEmpty && !line.tag.localizedCaseInsensitiveContains(tag) { return false }
                    return true
                }
                displayedLines = parsedLines
            } else {
                displayedLines = parsedLines.filter { line in
                    if !packagePids.isEmpty && !packagePids.contains(line.pid) { return false }
                    if !tag.isEmpty && !line.tag.localizedCaseInsensitiveContains(tag) { return false }
                    return true
                }
            }
        }
    }

}

// MARK: - Filter Bar

extension LogcatView {

    private func FilterBar() -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "shippingbox")
                    .foregroundStyle(.secondary)
                Menu {
                    Button("All processes") { selectPackage("") }
                    Divider()
                    ForEach(runningPackages, id: \.package) { item in
                        Button(item.package) { selectPackage(item.package) }
                    }
                } label: {
                    HStack {
                        Text(selectedPackage.isEmpty ? "All processes" : selectedPackage)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    loadPackages()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(.secondary)
                }.buttonStyle(.plain)
                    .hoverOpacity()
            }
            HStack(spacing: 8) {
                Image(systemName: "tag")
                    .foregroundStyle(.secondary)
                TextField("Filter by tag", text: $tagFilter)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.primary)
                    .onChange(of: tagFilter) { _ in refilter(destructive: true) }
                if !tagFilter.isEmpty {
                    Button {
                        tagFilter = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }.buttonStyle(.plain)
                        .hoverOpacity()
                }
            }
            HStack(spacing: 8) {
                Button {
                    startStream()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                    }
                    .font(.callout)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(RoundedRectangle(cornerRadius: 6).fill(.red.opacity(0.15)))
                    .foregroundStyle(.red)
                }.buttonStyle(.plain)
                    .hoverOpacity()
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                Text("Live")
                    .font(.callout)
                    .foregroundStyle(.green)
                Spacer()
                Text("\(displayedLines.count) lines")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(theme.backgroundInput)
    }

}

// MARK: - Log Content

extension LogcatView {

    @ViewBuilder
    private func LogContent() -> some View {
        if !isActive {
            Spacer()
        } else if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if displayedLines.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("No logs found")
                    .foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(displayedLines) { line in
                        LogcatRowView(line: line, accentColor: theme.accent)
                            .equatable()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

}

// MARK: - Row View

struct LogcatRowView: View, Equatable {

    let line: LogcatLine
    let accentColor: Color

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.line.id == rhs.line.id
    }

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text(line.level)
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundStyle(levelColor)
                .frame(width: 14)
            Text(line.tag)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(accentColor)
                .lineLimit(1)
                .frame(width: 120, alignment: .leading)
            Text(line.message)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 3)
        .contextMenu {
            Button("Copy") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(
                    "\(line.timestamp) \(line.level)/\(line.tag): \(line.message)",
                    forType: .string
                )
            }
        }
    }

    private var levelColor: Color {
        switch line.level {
        case "E": .red
        case "W": .orange
        case "I": .blue
        case "D": .green
        case "V": .gray
        default: .primary
        }
    }

}

// MARK: - Data

struct LogcatLine: Identifiable {
    let id: Int
    let timestamp: String
    let pid: String
    let tid: String
    let level: String
    let tag: String
    let message: String
}

extension LogcatView {

    private func appendLines(_ rawLines: [String]) {
        guard isActive, let regex = Self.logRegex else { return }
        let tag = tagFilter.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasPackageFilter = !packagePids.isEmpty
        let hasTagFilter = !tag.isEmpty
        var newLines: [LogcatLine] = []
        var currentId = nextLineId
        for raw in rawLines {
            guard let match = regex.firstMatch(in: raw, range: NSRange(raw.startIndex..., in: raw)) else { continue }
            func extract(_ i: Int) -> String {
                guard let range = Range(match.range(at: i), in: raw) else { return "" }
                return String(raw[range])
            }
            let line = LogcatLine(
                id: currentId,
                timestamp: extract(1),
                pid: extract(2),
                tid: extract(3),
                level: extract(4),
                tag: extract(5).trimmingCharacters(in: .whitespaces),
                message: extract(6)
            )
            currentId += 1
            // Skip non-matching lines entirely so they don't persist
            if hasPackageFilter && !packagePids.contains(line.pid) { continue }
            if hasTagFilter && !line.tag.localizedCaseInsensitiveContains(tag) { continue }
            newLines.append(line)
        }
        nextLineId = currentId
        if !newLines.isEmpty {
            parsedLines.append(contentsOf: newLines)
            displayedLines.append(contentsOf: newLines)
            if parsedLines.count > Self.maxLines {
                let overflow = parsedLines.count - Self.maxLines
                parsedLines.removeFirst(overflow)
                displayedLines = parsedLines
            }
        }
    }

}
