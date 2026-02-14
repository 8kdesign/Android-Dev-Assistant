//
//  GitFileSection.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 14/2/26.
//

import SwiftUI

struct GitFileSection: View {
    
    @EnvironmentObject var repoHelper: RepoHelper
    @EnvironmentObject var gitHelper: GitHelper
    @FocusState var focus: Bool
    
    @State var searchTerm: String = ""
    @State var files: [GitFileItem] = []
    @State var searchResults: [GitFileItem] = []
    @State var selectedFile: GitFileItem? = nil
    @State var content: (list: [String], error: LocalizedStringResource?)? = nil
    @State var job: Task<(), Never>? = nil
    @State var firstIndexSelection: Int? = nil
    @State var secondIndexSelection: Int? = nil
    @State var selectedRange: ClosedRange<Int>? = nil
    
    var body: some View {
        VStack {
            if let selectedFile {
                BrowseFileView(file: selectedFile)
            } else {
                SelectFileView()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                getFiles()
            }.onTapGesture {
                focus = false
            }.onChange(of: gitHelper.selectedCommit) { _ in
                focus = false
                getFiles()
                getFileContent()
            }.onChange(of: searchTerm) { _ in
                search()
            }.onChange(of: selectedFile) { _ in
                getFileContent()
            }.onReceive(repoHelper.$selectedRepo) { _ in
                searchTerm = ""
                selectedFile = nil
            }
    }
    
    private func SelectFileView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                TextField("Search", text: $searchTerm)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .focused($focus)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                Image(systemName: "xmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .opacity(searchTerm.isEmpty ? 0.3 : 0.7)
                    .onTapGesture {
                        searchTerm = ""
                        focus = false
                    }.hoverOpacity(searchTerm.isEmpty ? 1 : HOVER_OPACITY)
            }.padding(.horizontal, 20)
                .frame(height: 40)
                .background(Capsule().fill(Color(red: 0.13, green: 0.13, blue: 0.13)))
                .frame(maxWidth: 300, alignment: .leading)
                .padding(.all)
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(searchResults) { file in
                        FileItemView(file: file)
                            .onTapGesture {
                                selectedFile = file
                            }.hoverOpacity()
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollIndicators(.hidden)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func FileItemView(file: GitFileItem) -> some View {
        HStack(spacing: 15) {
            if selectedFile != nil {
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
            }
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
            .background(RoundedRectangle(cornerRadius: 5).fill(Color(red: 0.15, green: 0.15, blue: 0.15)))
            .padding(.horizontal, 15)
    }
    
    private func BrowseFileView(file: GitFileItem) -> some View {
        VStack(spacing: 0) {
            FileItemView(file: file)
                .padding(.top)
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
    
}

extension GitFileSection {
    
    private func getFiles() {
        files = []
        searchResults = []
        if let repo = repoHelper.selectedRepo, let hash = gitHelper.selectedCommit?.longHash {
            gitHelper.getFiles(repo: repo, hash: hash) { list in
                files = list
                search()
            }
        }
    }
    
    private func search() {
        job?.cancel()
        let existingFiles = files
        let lowercaseSearchTerm = searchTerm.lowercased()
        job = runOnLogicThread {
            let results = existingFiles.filter { $0.name.lowercased().contains(lowercaseSearchTerm) }
            if !Task.isCancelled {
                Task { @MainActor in
                    self.searchResults = results
                }
            }
        }
    }
    
    private func getFileContent() {
        job?.cancel()
        content = nil
        selectIndex(index: nil)
        if let repo = repoHelper.selectedRepo, let hash = gitHelper.selectedCommit?.longHash, let file = selectedFile {
            job = gitHelper.getFileData(repo: repo, hash: hash, file: file.path) { result in
                if let result {
                    content = (result.split(separator: "\n").map { String($0) }, nil)
                } else {
                    content = ([], "File not found")
                }
            }
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
