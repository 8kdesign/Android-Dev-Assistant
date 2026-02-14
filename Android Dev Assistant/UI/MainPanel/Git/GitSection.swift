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
    
    var body: some View {
        HStack(spacing: 0) {
            SourceSelectorView()
            GitFileSection()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(gitHelper.selectedBranch == nil ? 0.3 : 1)
            .disabled(gitHelper.selectedBranch == nil)
    }
    
}
