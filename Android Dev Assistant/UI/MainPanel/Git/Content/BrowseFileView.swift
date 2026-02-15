//
//  BrowseFileView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 15/2/26.
//

import SwiftUI

struct BrowseFileView: View {
    
    @EnvironmentObject var repoHelper: RepoHelper
    @EnvironmentObject var gitHelper: GitHelper
    
    @Binding var selectedFile: GitFileItem?
    @State var content: (list: [String], error: LocalizedStringResource?)? = nil
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
                            .foregroundStyle(.white)
                            .foregroundColor(.white)
                        Text(error)
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .foregroundColor(.white)
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
                        .accentColor(.white)
                        .tint(.white)
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
            }
    }
    
    private func FileLineView(index: Int, line: String) -> some View {
        return HStack(alignment: .top) {
            Text("\(index + 1)")
                .frame(width: 50, alignment: .trailing)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .padding(.all, 5)
                .opacity(0.5)
            Divider()
                .opacity(0.5)
            Text(line)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .padding(.all, 5)
        }.background(selectedRange?.contains(index) == true || firstIndexSelection == index ? .red.opacity(0.1) : .white.opacity(0.000001))
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
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.7)
                .onTapGesture {
                    selectedFile = nil
                }.hoverOpacity()
            VStack(spacing: 5) {
                Text(file.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                Text(file.path)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .opacity(0.3)
            }
        }.padding(.horizontal, 15)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.12, green: 0.12, blue: 0.12)))
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
                if let result {
                    content = (result.split(separator: "\n").map { String($0) }, nil)
                } else {
                    content = ([], "File not found")
                }
                isContentLatest = true
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
        if let selectedRange, selectedRange.contains(index) {
            firstIndexSelection = nil
            secondIndexSelection = nil
            self.selectedRange = nil
            return
        }
        if firstIndexSelection == nil || secondIndexSelection != nil {
            firstIndexSelection = index
            secondIndexSelection = nil
            selectedRange = nil
        } else if secondIndexSelection == nil, let firstIndexSelection {
            secondIndexSelection = index
            let minValue = min(firstIndexSelection, index)
            let maxValue = max(firstIndexSelection, index)
            selectedRange = minValue...maxValue
        }
    }
    
    private func copyLines() {
        if let list = content?.list {
            if let selectedRange {
                var lines = ""
                for index in selectedRange {
                    if let line = list[safe: index] {
                        lines += line + "\n"
                    }
                }
                if lines.last == "\n" {
                    lines.removeLast()
                }
                copyToClipboard(lines as NSString)
            } else {
                let lines = list.joined(separator: "\n")
                copyToClipboard(lines as NSString)
            }
        }
    }
    
}
