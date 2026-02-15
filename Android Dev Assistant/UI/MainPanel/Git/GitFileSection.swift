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
    @State var files: [GitFileItem]? = nil
    @State var searchResults: [GitFileItem]? = nil
    @State var selectedFile: GitFileItem? = nil
    @State var filesJob: Task<(), Never>? = nil
    @State var searchJob: Task<(), Never>? = nil
    
    var body: some View {
        VStack {
            if selectedFile != nil {
                BrowseFileView(selectedFile: $selectedFile)
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
            }.onChange(of: searchTerm) { _ in
                search()
            }.onReceive(repoHelper.$selectedRepo) { _ in
                searchTerm = ""
                selectedFile = nil
            }
    }
    
    private func SelectFileView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let searchResults {
                SearchBarView()
                if searchTerm.isEmpty, let diff = gitHelper.selectedCommitFileDiff {
                    CommitInfoView(diff: diff)
                } else {
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
    }
    
    private func SearchBarView() -> some View {
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
    }
    
    private func FileItemView(file: GitFileItem) -> some View {
        HStack(spacing: 15) {
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

extension GitFileSection {
    
    private func getFiles() {
        filesJob?.cancel()
        files = nil
        searchResults = nil
        if let repo = repoHelper.selectedRepo, let hash = gitHelper.selectedCommit?.longHash {
            filesJob = gitHelper.getFiles(repo: repo, hash: hash) { list in
                files = list
                search()
            }
        }
    }
    
    private func search() {
        searchJob?.cancel()
        let existingFiles = files
        let lowercaseSearchTerm = searchTerm.lowercased()
        searchJob = runOnLogicThread {
            let results = existingFiles?.filter { $0.name.lowercased().contains(lowercaseSearchTerm) }
            if !Task.isCancelled {
                Task { @MainActor in
                    self.searchResults = results
                }
            }
        }
    }
    
}
