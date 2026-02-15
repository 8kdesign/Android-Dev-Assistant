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
    
    @State var files: [GitFileItem]? = nil
    @State var selectedFile: GitFileItem? = nil
    @State var filesJob: Task<(), Never>? = nil
    
    var body: some View {
        VStack {
            if selectedFile != nil {
                BrowseFileView(selectedFile: $selectedFile)
            } else {
                SelectFileView(files: $files, selectedFile: $selectedFile)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                getFiles()
            }.onChange(of: gitHelper.selectedCommit) { _ in
                getFiles()
            }.onReceive(repoHelper.$selectedRepo) { _ in
                selectedFile = nil
            }
    }
    
}

extension GitFileSection {
    
    private func getFiles() {
        filesJob?.cancel()
        files = nil
        if let repo = repoHelper.selectedRepo, let hash = gitHelper.selectedCommit?.longHash {
            filesJob = gitHelper.getFiles(repo: repo, hash: hash) { list in
                files = list
            }
        }
    }
    
}
