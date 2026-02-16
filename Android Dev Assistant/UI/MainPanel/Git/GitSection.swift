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
    @State private var rotated = false

    var body: some View {
        VStack(spacing: 0) {
            if repoHelper.selectedRepo != nil {
                HStack(spacing: 10) {
                    Text(repoHelper.selectedRepo?.name ?? "")
                        .font(.title2.bold())
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .rotationEffect(.degrees(rotated ? 360 : 0))
                        .onTapGesture {
                            gitHelper.fetchRepoBranches()
                            rotated = false
                            withAnimation(.easeInOut(duration: 0.2)) {
                                rotated = true
                            }
                        }.hoverOpacity()
                }.padding([.horizontal, .top])
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 0) {
                    SourceSelectorView()
                    GitFileSection()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(gitHelper.selectedBranch == nil ? 0.3 : 1)
                    .disabled(gitHelper.selectedBranch == nil)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}
