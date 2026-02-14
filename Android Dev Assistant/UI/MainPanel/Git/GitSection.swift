//
//  GitSection.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 13/2/26.
//

import SwiftUI

struct GitSection: View {
    
    @EnvironmentObject var repoHelper: RepoHelper
    @EnvironmentObject var gitHelper: GitHelper

    @State var selectedBranch: String? = nil
    @State var selectedCommit: CommitItem? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            SourceSelectorView(
                selectedBranch: $selectedBranch,
                selectedCommit: $selectedCommit
            )
            GitFileSection(selectedCommit: $selectedCommit)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(selectedBranch == nil ? 0.3 : 1)
            .disabled(selectedBranch == nil)
    }
    
}
