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
    @State var job: Task<(), Never>? = nil
    
    var body: some View {
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
                LazyVStack(spacing: 15) {
                    ForEach(searchResults) { file in
                        FileItemView(file: file)
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollIndicators(.hidden)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                getFiles()
            }.onTapGesture {
                focus = false
            }.onChange(of: selectedCommit) { _ in
                focus = false
                getFiles()
            }.onChange(of: searchTerm) { value in
                search()
            }
    }
    
    private func FileItemView(file: GitFileItem) -> some View {
        VStack {
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
        }.padding(.all, 15)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 5).fill(Color(red: 0.15, green: 0.15, blue: 0.15)))
            .padding(.horizontal, 15)
            .onTapGesture {
                
            }.hoverOpacity()
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
            let results = existingFiles.filter { $0.name.contains(lowercaseSearchTerm) }
            if !Task.isCancelled {
                Task { @MainActor in
                    self.searchResults = results
                }
            }
        }
    }
    
}
