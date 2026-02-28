//
//  BrowseFileView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 15/2/26.
//

import SwiftUI
import HighlightSwift

struct BrowseFileView: View {

    @EnvironmentObject var repoHelper: RepoHelper
    @EnvironmentObject var gitHelper: GitHelper
    @EnvironmentObject var theme: ThemeManager

    @Binding var selectedFile: GitFileItem?
    @State var content: (list: [AttributedString], image: NSImage?, error: LocalizedStringResource?)? = nil
    @State var isContentLatest: Bool = false
    @State var firstIndexSelection: Int? = nil
    @State var secondIndexSelection: Int? = nil
    @State var selectedRange: ClosedRange<Int>? = nil
    @State var contentJob: Task<(), Never>? = nil

    var body: some View {
        VStack(spacing: 0) {
            if let selectedFile {
                FileItemView(file: selectedFile)
                    .padding(.top)
            }
            if let content {
                if let error = content.error {
                    VStack(spacing: 15) {
                        Image(systemName: "externaldrive.badge.xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.primary)
                        Text(error)
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                    }.padding(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(isContentLatest ? 1 : 0.3)
                        .blur(radius: isContentLatest ? 0 : 5)
                } else if let image = content.image {
                    VStack {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    }.padding(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(content.list.enumerated()), id: \.offset) { index, item in
                                FileLineView(index: index, line: item)
                            }
                        }.padding(.all)
                            .opacity(isContentLatest ? 1 : 0.3)
                            .blur(radius: isContentLatest ? 0 : 5)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.primary)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                selectIndex(index: nil)
            }.contextMenu {
                Button("Copy") {
                    copyLines()
                }
            }.onChange(of: gitHelper.selectedCommit) { _ in
                getFileContent()
            }.onChange(of: selectedFile) { _ in
                getFileContent()
            }.onAppear {
                getFileContent()
            }.onChange(of: theme.isDarkMode) { _ in
                getFileContent()
            }
    }

    private func FileLineView(index: Int, line: AttributedString) -> some View {
        return HStack(alignment: .top) {
            Text("\(index + 1)")
                .frame(width: 50, alignment: .trailing)
                .foregroundStyle(.primary)
                .padding(.all, 5)
                .opacity(0.5)
            Divider()
                .opacity(0.5)
            Text(line)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.primary)
                .padding(.all, 5)
        }.background(selectedRange?.contains(index) == true || firstIndexSelection == index ? .red.opacity(0.1) : .primary.opacity(0.000001))
            .onTapGesture {
                selectIndex(index: index)
            }.hoverOpacity()
    }

    private func FileItemView(file: GitFileItem) -> some View {
        HStack(spacing: 15) {
            Image(systemName: "xmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.primary)
                .opacity(0.7)
                .onTapGesture {
                    selectedFile = nil
                }.hoverOpacity()
            VStack(spacing: 5) {
                Text(file.name)
                    .font(.body.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.primary)
                Text(file.path)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.primary)
                    .opacity(0.3)
            }
        }.padding(.horizontal, 15)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10).fill(theme.backgroundTertiary))
            .padding(.horizontal, 15)
    }

}

extension BrowseFileView {

    private func getFileContent() {
        contentJob?.cancel()
        isContentLatest = false
        selectIndex(index: nil)
        if let repo = repoHelper.selectedRepo, let hash = gitHelper.selectedCommit?.longHash, let file = selectedFile {
            contentJob = gitHelper.getFileData(repo: repo, hash: hash, file: file.path) { result in
                guard let result else {
                    Task { @MainActor in
                        content = ([], nil, "File not found")
                        isContentLatest = true
                    }
                    return
                }
                if let string = result as? String {
                    let highlight = Highlight()
                    let language = file.name.split(separator: ".").map { String($0) }.last
                    do {
                        let attributeString = try await highlight.attributedText(string, language: language ?? "", colors: theme.isDarkMode ? .dark(.github) : .light(.github))
                        let lines = splitAttributedString(inputString: attributeString, separator: "\n")
                        Task { @MainActor in
                            content = (lines, nil, nil)
                            isContentLatest = true
                        }
                    } catch {
                        Task { @MainActor in
                            content = (string.split(separator: "\n").map { AttributedString($0) }, nil, nil)
                            isContentLatest = true
                        }
                    }
                } else if let image = result as? NSImage {
                    Task { @MainActor in
                        content = ([], image, nil)
                        isContentLatest = true
                    }
                } else {
                    Task { @MainActor in
                        content = ([], nil, "Unable to open file")
                        isContentLatest = true
                    }
                }
            }
        } else {
            content = nil
            isContentLatest = true
        }
    }

    private func selectIndex(index: Int?) {
        guard let index else {
            firstIndexSelection = nil
            secondIndexSelection = nil
            selectedRange = nil
            return
        }
        let isShifting = NSEvent.modifierFlags.contains(.shift)
        if let selectedRange, selectedRange.contains(index), !isShifting {
            firstIndexSelection = nil
            secondIndexSelection = nil
            self.selectedRange = nil
            return
        }
        if isShifting, let firstIndexSelection {
            secondIndexSelection = index
            let minValue = min(firstIndexSelection, index)
            let maxValue = max(firstIndexSelection, index)
            selectedRange = minValue...maxValue
        } else {
            firstIndexSelection = index
            secondIndexSelection = nil
            selectedRange = nil
        }
    }

    private func copyLines() {
        if let list = content?.list {
            if let selectedRange {
                var lines = ""
                for index in selectedRange {
                    if let line = list[safe: index] {
                        lines += String(line.characters) + "\n"
                    }
                }
                if lines.last == "\n" {
                    lines.removeLast()
                }
                copyToClipboard(lines as NSString)
            } else if let firstIndexSelection, let line = list[safe: firstIndexSelection] {
                copyToClipboard(String(line.characters) as NSString)
            } else {
                let lines = list.map { String($0.characters) }.joined(separator: "\n")
                copyToClipboard(lines as NSString)
            }
        }
    }

    func splitAttributedString(inputString: AttributedString, separator: String) -> [AttributedString] {
        let nsAttributedString = NSAttributedString(inputString)
        let parts = nsAttributedString.string.components(separatedBy: separator)
        var result = [NSAttributedString]()
        var location = 0
        for part in parts {
            let range = NSRange(location: location, length: part.utf16.count)
            result.append(nsAttributedString.attributedSubstring(from: range))
            location += range.length + separator.utf16.count
        }
        return result.compactMap { AttributedString($0) }
    }

}
