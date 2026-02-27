//
//  SharedPreferencesView.swift
//  Android Dev Assistant
//

import SwiftUI
import AppKit

struct SharedPreferencesView: View {

    @EnvironmentObject var adbHelper: AdbHelper
    @EnvironmentObject var toastHelper: ToastHelper
    var packageName: String
    @State var files: [String]? = nil
    @State var selectedFile: String? = nil
    @State var xmlContent: String? = nil
    @State var entries: [SharedPrefEntry] = []

    var body: some View {
        PopupView(title: "Shared Preferences", interceptEscape: {
            if selectedFile != nil {
                withAnimation(.easeInOut(duration: 0.15)) {
                    selectedFile = nil
                    xmlContent = nil
                    entries = []
                }
                return true
            }
            return false
        }) {
            if let selectedFile {
                DetailView(fileName: selectedFile)
            } else {
                ListView()
            }
        }
        .onAppear {
            adbHelper.listSharedPreferences(packageName: packageName) { result in
                files = result
            }
        }
    }

}

// MARK: - List View

extension SharedPreferencesView {

    @ViewBuilder
    private func ListView() -> some View {
        if let files {
            if files.isEmpty {
                Text("No shared preferences found")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(files, id: \.self) { file in
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedFile = file
                                }
                                adbHelper.readSharedPreference(packageName: packageName, fileName: file) { content in
                                    xmlContent = content
                                    entries = parseXml(content)
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "doc.text")
                                        .foregroundStyle(.green)
                                        .foregroundColor(.green)
                                    Text(file)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                        .foregroundStyle(.white)
                                        .foregroundColor(.white)
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(.white.opacity(0.00001))
                            }
                            .buttonStyle(.plain)
                            .hoverOpacity(HOVER_OPACITY)
                            if file != files.last {
                                Divider().opacity(0.3).padding(.leading, 46)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollIndicators(.never)
            }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

}

// MARK: - Detail View

extension SharedPreferencesView {

    @ViewBuilder
    private func DetailView(fileName: String) -> some View {
        if entries.isEmpty && xmlContent == nil {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if entries.isEmpty {
            Text("Empty or unreadable preference file")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: 0) {
                HStack {
                    Text("\(entries.count) entries")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        if let xmlContent {
                            copyToClipboard(xmlContent as NSString)
                            toastHelper.addToast("Copied to clipboard", style: .clipboard)
                        }
                    } label: {
                        Image(systemName: "list.clipboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(.green)
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                    .hoverOpacity()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                Divider().opacity(0.3)
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                            EntryRow(entry: entry)
                            if index < entries.count - 1 {
                                Divider().opacity(0.2).padding(.leading, 16)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollIndicators(.never)
            }
        }
    }

    @ViewBuilder
    private func EntryRow(entry: SharedPrefEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(entry.key)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.green)
                    .foregroundColor(.green)
                    .textSelection(.enabled)
                Spacer()
                Text(entry.type)
                    .font(.caption2)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(entry.typeColor.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            Text(entry.value)
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.8)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

}

// MARK: - XML Parsing

struct SharedPrefEntry {
    let key: String
    let value: String
    let type: String

    var typeColor: Color {
        switch type {
        case "string": return .green
        case "int": return .blue
        case "long": return .cyan
        case "float": return .orange
        case "boolean": return .purple
        case "set": return .yellow
        default: return .gray
        }
    }
}

extension SharedPreferencesView {

    func parseXml(_ xml: String) -> [SharedPrefEntry] {
        var results: [SharedPrefEntry] = []
        let lines = xml.split(separator: "\n").map(String.init)
        var i = 0
        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            if let entry = parseSingleLineEntry(line) {
                results.append(entry)
            } else if line.hasPrefix("<set name=") {
                if let entry = parseSetEntry(lines: lines, startIndex: &i) {
                    results.append(entry)
                    continue
                }
            }
            i += 1
        }
        results.sort { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
        return results
    }

    private func parseSingleLineEntry(_ line: String) -> SharedPrefEntry? {
        // <string name="key">value</string>
        if let match = matchTag(line, tag: "string") {
            return SharedPrefEntry(key: match.key, value: match.value, type: "string")
        }
        // <int name="key" value="123" />
        if let match = matchSelfClosing(line, tag: "int") {
            return SharedPrefEntry(key: match.key, value: match.value, type: "int")
        }
        if let match = matchSelfClosing(line, tag: "long") {
            return SharedPrefEntry(key: match.key, value: match.value, type: "long")
        }
        if let match = matchSelfClosing(line, tag: "float") {
            return SharedPrefEntry(key: match.key, value: match.value, type: "float")
        }
        if let match = matchSelfClosing(line, tag: "boolean") {
            return SharedPrefEntry(key: match.key, value: match.value, type: "boolean")
        }
        return nil
    }

    private func matchTag(_ line: String, tag: String) -> (key: String, value: String)? {
        let pattern = "<\(tag) name=\"([^\"]+)\">(.*?)</\(tag)>"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let keyRange = Range(match.range(at: 1), in: line),
              let valueRange = Range(match.range(at: 2), in: line) else { return nil }
        return (String(line[keyRange]), String(line[valueRange]))
    }

    private func matchSelfClosing(_ line: String, tag: String) -> (key: String, value: String)? {
        let pattern = "<\(tag) name=\"([^\"]+)\" value=\"([^\"]*)\"\\s*/>"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let keyRange = Range(match.range(at: 1), in: line),
              let valueRange = Range(match.range(at: 2), in: line) else { return nil }
        return (String(line[keyRange]), String(line[valueRange]))
    }

    private func parseSetEntry(lines: [String], startIndex: inout Int) -> SharedPrefEntry? {
        let line = lines[startIndex].trimmingCharacters(in: .whitespaces)
        let namePattern = "<set name=\"([^\"]+)\">"
        guard let regex = try? NSRegularExpression(pattern: namePattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let keyRange = Range(match.range(at: 1), in: line) else { return nil }
        let key = String(line[keyRange])
        var values: [String] = []
        startIndex += 1
        while startIndex < lines.count {
            let setLine = lines[startIndex].trimmingCharacters(in: .whitespaces)
            if setLine == "</set>" {
                startIndex += 1
                break
            }
            if let valMatch = matchSetMember(setLine) {
                values.append(valMatch)
            }
            startIndex += 1
        }
        return SharedPrefEntry(key: key, value: "[\(values.joined(separator: ", "))]", type: "set")
    }

    private func matchSetMember(_ line: String) -> String? {
        let pattern = "<string>([^<]*)</string>"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line) else { return nil }
        return String(line[range])
    }

}
