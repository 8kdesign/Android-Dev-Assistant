//
//  NetworkInterceptView.swift
//  Android Dev Assistant
//

import SwiftUI
import AppKit

// MARK: - Network Line Model

struct NetworkLine: Identifiable {
    let id: Int
    let timestamp: String
    let pid: String
    let tid: String
    let level: String
    let tag: String
    let message: String
    let method: String?
    let url: String?
    let statusCode: String?
    let direction: Direction?

    enum Direction {
        case request
        case response
    }

    init(id: Int, timestamp: String, pid: String, tid: String, level: String, tag: String, message: String) {
        self.id = id
        self.timestamp = timestamp
        self.pid = pid
        self.tid = tid
        self.level = level
        self.tag = tag
        self.message = message

        let trimmed = message.trimmingCharacters(in: .whitespaces)

        // OkHttp request: --> GET https://...
        if trimmed.hasPrefix("-->") {
            self.direction = .request
            let rest = trimmed.dropFirst(3).trimmingCharacters(in: .whitespaces)
            let parts = rest.split(separator: " ", maxSplits: 1)
            if parts.count == 2 {
                self.method = String(parts[0])
                self.url = String(parts[1]).components(separatedBy: " ").first
            } else {
                self.method = nil
                self.url = NetworkLine.extractURL(from: rest)
            }
            self.statusCode = nil
        }
        // OkHttp response: <-- 200 OK https://... (150ms)
        else if trimmed.hasPrefix("<--") {
            self.direction = .response
            let rest = trimmed.dropFirst(3).trimmingCharacters(in: .whitespaces)
            let parts = rest.split(separator: " ", maxSplits: 2)
            if parts.count >= 1, parts[0].allSatisfy({ $0.isNumber }) {
                self.statusCode = String(parts[0])
            } else {
                self.statusCode = nil
            }
            self.url = NetworkLine.extractURL(from: rest)
            self.method = nil
        } else {
            self.direction = nil
            self.statusCode = nil
            self.url = NetworkLine.extractURL(from: trimmed)
            let methods = ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS"]
            self.method = methods.first { method in
                trimmed.hasPrefix(method + " ") || trimmed.contains(" \(method) ")
            }
        }
    }

    private static func extractURL(from text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: #"https?://[^\s\)\]\"']+"#) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let matchRange = Range(match.range, in: text) else { return nil }
        return String(text[matchRange])
    }
}

// MARK: - Main View

struct NetworkInterceptView: View {

    @EnvironmentObject var adbHelper: AdbHelper
    @EnvironmentObject var theme: ThemeManager
    @State private var parsedLines: [NetworkLine] = []
    @State private var displayedLines: [NetworkLine] = []
    @State private var isLoading: Bool = true
    @State private var streamGeneration: Int = 0
    @State private var nextLineId: Int = 0
    @State private var isActive: Bool = true
    @State private var isPaused: Bool = false
    @State private var tagFilter: String = ""
    @State private var expandedLineId: Int? = nil

    private static let maxLines = 1000
    private static let logRegex = try? NSRegularExpression(
        pattern: #"^(\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3})\s+(\d+)\s+(\d+)\s+([VDIWEF])\s+(.+?)\s*:\s(.*)$"#
    )

    var body: some View {
        PopupView(title: "Network", willClose: {
            isActive = false
        }, onExit: {
            streamGeneration += 1
            adbHelper.stopNetworkStream()
        }) {
            VStack(spacing: 0) {
                FilterBar()
                Divider().opacity(0.3)
                LogContent()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                startStream()
            }
        }
        .onDisappear {
            adbHelper.stopNetworkStream()
        }
    }

    private func startStream() {
        isLoading = true
        parsedLines = []
        displayedLines = []
        nextLineId = 0
        streamGeneration += 1
        let gen = streamGeneration
        adbHelper.startNetworkStream { rawLines in
            guard gen == streamGeneration else { return }
            appendLines(rawLines)
            if isLoading { isLoading = false }
        }
    }

    private func refilter() {
        let filter = tagFilter.trimmingCharacters(in: .whitespacesAndNewlines)
        if filter.isEmpty {
            displayedLines = parsedLines
        } else {
            displayedLines = parsedLines.filter { line in
                line.tag.localizedCaseInsensitiveContains(filter) ||
                line.message.localizedCaseInsensitiveContains(filter) ||
                (line.url?.localizedCaseInsensitiveContains(filter) == true)
            }
        }
    }

}

// MARK: - Filter Bar

extension NetworkInterceptView {

    private func FilterBar() -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "line.3.horizontal.decrease")
                    .foregroundStyle(.secondary)
                TextField("Search", text: $tagFilter)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.primary)
                    .onChange(of: tagFilter) { _ in refilter() }
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
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 6).fill(.red.opacity(0.15)))
                        .foregroundStyle(.red)
                }.buttonStyle(.plain)
                    .hoverOpacity()
                Button {
                    isPaused.toggle()
                } label: {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 6).fill(.gray.opacity(0.15)))
                        .foregroundStyle(.gray)
                }.buttonStyle(.plain)
                    .hoverOpacity()
                Circle()
                    .fill(isPaused ? .orange : .green)
                    .frame(width: 8, height: 8)
                Text(isPaused ? "Paused" : "Live")
                    .font(.callout)
                    .foregroundStyle(isPaused ? .orange : .green)
                Spacer()
                Text("\(displayedLines.count) entries")
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

extension NetworkInterceptView {

    @ViewBuilder
    private func LogContent() -> some View {
        if !isActive {
            Spacer()
        } else if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if displayedLines.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("No network logs found")
                    .foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(displayedLines) { line in
                        NetworkRowView(
                            line: line,
                            accentColor: theme.accent,
                            isExpanded: expandedLineId == line.id,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    expandedLineId = expandedLineId == line.id ? nil : line.id
                                }
                            }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

}

// MARK: - Network Row View

struct NetworkRowView: View {

    let line: NetworkLine
    let accentColor: Color
    let isExpanded: Bool
    let onTap: () -> ()

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .top, spacing: 6) {
                    if let direction = line.direction {
                        Image(systemName: direction == .request ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .foregroundStyle(direction == .request ? .blue : .green)
                            .font(.callout)
                    }
                    if let method = line.method {
                        Text(method)
                            .font(.system(.caption, design: .monospaced).bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(RoundedRectangle(cornerRadius: 4).fill(methodColor(method)))
                    }
                    if let status = line.statusCode {
                        Text(status)
                            .font(.system(.caption, design: .monospaced).bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(RoundedRectangle(cornerRadius: 4).fill(statusColor(status)))
                    }
                    Text(line.tag)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                    Text(line.timestamp)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
                // URL - prominent display
                if let url = line.url {
                    Text(url)
                        .font(.system(.callout, design: .monospaced).bold())
                        .foregroundStyle(accentColor)
                        .lineLimit(isExpanded ? nil : 1)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                // Message content
                if (line.url == nil || messageHasExtra()) && !isExpanded {
                    Text(displayMessage())
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.primary.opacity(0.7))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                // Expanded detail
                if isExpanded {
                    Divider().opacity(0.3).padding(.vertical, 4)
                    VStack(alignment: .leading, spacing: 4) {
                        DetailRow(label: "Timestamp", value: line.timestamp)
                        DetailRow(label: "Tag", value: line.tag)
                        DetailRow(label: "PID/TID", value: "\(line.pid)/\(line.tid)")
                        DetailRow(label: "Level", value: line.level)
                        Text(line.message)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.primary)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(rowBackground())
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .hoverOpacity()
        .contextMenu {
            if let url = line.url {
                Button("Copy URL") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(url, forType: .string)
                }
            }
            Button("Copy Full Line") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(
                    "\(line.timestamp) \(line.level)/\(line.tag): \(line.message)",
                    forType: .string
                )
            }
        }
    }

    private func DetailRow(label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(label + ":")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 70, alignment: .trailing)
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.primary)
                .textSelection(.enabled)
        }
    }

    private func displayMessage() -> String {
        if let url = line.url {
            return line.message
                .replacingOccurrences(of: url, with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "-->", with: "")
                .replacingOccurrences(of: "<--", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return line.message
    }

    private func messageHasExtra() -> Bool {
        let cleaned = displayMessage()
        if let method = line.method {
            return cleaned.replacingOccurrences(of: method, with: "").trimmingCharacters(in: .whitespacesAndNewlines).count > 1
        }
        if let status = line.statusCode {
            return cleaned.replacingOccurrences(of: status, with: "").trimmingCharacters(in: .whitespacesAndNewlines).count > 1
        }
        return !cleaned.isEmpty
    }

    private func rowBackground() -> some ShapeStyle {
        if isExpanded {
            return Color.primary.opacity(0.05)
        } else if line.direction == .request {
            return Color.blue.opacity(0.04)
        } else if line.direction == .response {
            return Color.green.opacity(0.04)
        }
        return Color.clear.opacity(0)
    }

    private func methodColor(_ method: String) -> Color {
        switch method.uppercased() {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "PATCH": return .purple
        case "DELETE": return .red
        case "HEAD": return .gray
        case "OPTIONS": return .teal
        default: return .secondary
        }
    }

    private func statusColor(_ status: String) -> Color {
        guard let code = Int(status) else { return .gray }
        switch code {
        case 200..<300: return .green
        case 300..<400: return .blue
        case 400..<500: return .orange
        case 500..<600: return .red
        default: return .gray
        }
    }

}

// MARK: - Data

extension NetworkInterceptView {

    private func appendLines(_ rawLines: [String]) {
        guard isActive, !isPaused, let regex = Self.logRegex else { return }
        let filter = tagFilter.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasFilter = !filter.isEmpty
        var newLines: [NetworkLine] = []
        var currentId = nextLineId
        for raw in rawLines {
            guard let match = regex.firstMatch(in: raw, range: NSRange(raw.startIndex..., in: raw)) else { continue }
            func extract(_ i: Int) -> String {
                guard let range = Range(match.range(at: i), in: raw) else { return "" }
                return String(raw[range])
            }
            let line = NetworkLine(
                id: currentId,
                timestamp: extract(1),
                pid: extract(2),
                tid: extract(3),
                level: extract(4),
                tag: extract(5).trimmingCharacters(in: .whitespaces),
                message: extract(6)
            )
            currentId += 1
            if hasFilter &&
                !line.tag.localizedCaseInsensitiveContains(filter) &&
                !line.message.localizedCaseInsensitiveContains(filter) &&
                !(line.url?.localizedCaseInsensitiveContains(filter) == true) {
                continue
            }
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
