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
    
    @Binding var selectedCommit: CommitItem?
    @State var searchTerm: String = ""
    @State var files: [GitFileItem] = []
    @State var searchResults: [GitFileItem] = []
    @State var selectedFile: GitFileItem? = nil
    @State var content: [String]? = nil
    @State var job: Task<(), Never>? = nil
    
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
            }.onChange(of: selectedCommit) { _ in
                focus = false
                getFiles()
                getFileContent()
            }.onChange(of: searchTerm) { _ in
                search()
            }.onChange(of: selectedFile) { _ in
                getFileContent()
            }
    }
    
    private func SelectFileView() -> some View {
        VStack(spacing: 0) {
            TextField("Search", text: $searchTerm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .focused($focus)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color(red: 0.15, green: 0.15, blue: 0.15)))
                .textFieldStyle(.plain)
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
    
    private func BrowseFileView(file: GitFileItem) -> some View {
        VStack(spacing: 0) {
            FileItemView(file: file)
                .padding(.vertical, 10)
            ScrollView {
                if let content {
                    LazyVStack(spacing: 2) {
                        ForEach(Array(content.enumerated()), id: \.offset) { index, item in
                            HStack(alignment: .top) {
                                Text("\(index)")
                                    .frame(width: 50, alignment: .trailing)
                                    .foregroundStyle(.white)
                                    .foregroundColor(.white)
                                    .opacity(0.5)
                                Divider()
                                    .opacity(0.5)
                                Text(item)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.white)
                                    .foregroundColor(.white)
                            }
                        }
                    }.padding(.all)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func FileItemView(file: GitFileItem) -> some View {
        HStack(spacing: 5) {
            if selectedFile != nil {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
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
    
}

extension GitFileSection {
    
    private func getFiles() {
        files = []
        searchResults = []
        if let repo = repoHelper.selectedRepo, let hash = selectedCommit?.longHash {
            gitHelper.getFiles(repo: repo, hash: hash) { list in
                files = list
                search()
            }
        }
    }
    
    private func search() {
        job?.cancel()
        searchResults = []
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
        if let repo = repoHelper.selectedRepo, let hash = selectedCommit?.longHash, let file = selectedFile {
            job = gitHelper.getFileData(repo: repo, hash: hash, file: file.path) { result in
                if let result {
                    content = result.split(separator: "\n").map { String($0) }
                } else {
                    content = nil
                }
            }
        }
    }
    
}
