//
//  SourceSelectorView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 14/2/26.
//

import SwiftUI

struct SourceSelectorView: View {
    
    @EnvironmentObject var repoHelper: RepoHelper
    @EnvironmentObject var gitHelper: GitHelper
    
    @Binding var selectedBranch: String?
    @Binding var selectedCommit: CommitItem?
    @State var branches: [String] = []
    @State var commits: [CommitItem] = []
    @State var currentBranch: String? = nil
    
    @State var isSelectingBranch: Bool = false
    @State var job: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            SelectedBranchView()
            Divider().opacity(0.7)
            ZStack {
                if isSelectingBranch {
                    BranchSelectorView()
                } else {
                    CommitSelectorView()
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }.frame(width: 200)
            .frame(maxHeight: .infinity)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
            .onReceive(repoHelper.$selectedRepo) { repo in
                job?.cancel()
                commits = []
                selectedCommit = nil
                isSelectingBranch = false
                if let repo {
                    gitHelper.getGitBranches(repo: repo) { list, currentBranch in
                        self.branches = list
                        self.currentBranch = currentBranch
                        self.selectedBranch = currentBranch
                        if let currentBranch {
                            self.job = gitHelper.getBranchCommits(repo: repo, branch: currentBranch) { commits in
                                self.commits = commits
                                selectedCommit = commits.first
                            }
                        }
                    }
                }
            }.onChange(of: selectedBranch) { branch in
                job?.cancel()
                commits = []
                selectedCommit = nil
                if let branch, let repo = repoHelper.selectedRepo {
                    job = gitHelper.getBranchCommits(repo: repo, branch: branch) { commits in
                        self.commits = commits
                        self.selectedCommit = commits.first
                    }
                }
            }
    }
    
    private func SelectedBranchView() -> some View {
        HStack {
            VStack(spacing: 5) {
                Text("Branch")
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .opacity(0.3)
                Text(selectedBranch ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
            }
            Image(systemName: isSelectingBranch ? "chevron.up" : "chevron.down")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .padding(.all, 4)
                .opacity(0.7)
        }.padding(.all, 15)
            .frame(maxWidth: .infinity, maxHeight: 60)
            .background(isSelectingBranch ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.08, green: 0.08, blue: 0.08))
            .onTapGesture {
                withAnimation(.snappy(duration: 0.2)) {
                    isSelectingBranch.toggle()
                }
            }.hoverOpacity()
    }
    
    private func BranchSelectorView() -> some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(branches.enumerated()), id: \.offset) { index, branch in
                        Text(branch)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .truncationMode(.head)
                            .foregroundStyle(.white)
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.00001))
                            .onTapGesture {
                                selectedBranch = branch
                                isSelectingBranch = false
                            }.hoverOpacity()
                        Divider().opacity(0.3)
                    }
                }
            }.frame(maxWidth: .infinity)
                .scrollIndicators(.hidden)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
    }
    
    private func CommitSelectorView() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(commits.enumerated()), id: \.offset) { index, item in
                    let isSelected = item.id == selectedCommit?.id
                    VStack(spacing: 5) {
                        Text(item.shortHash)
                            .font(.footnote)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(isSelected ? .black : .white)
                            .foregroundColor(isSelected ? .black : .white)
                            .opacity(0.5)
                        Text(item.message)
                            .font(.callout)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(isSelected ? .black : .white)
                            .foregroundColor(isSelected ? .black : .white)
                        HStack(spacing: 10) {
                            Text("@\(item.author)")
                                .font(.footnote)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(isSelected ? .black : .white)
                                .foregroundColor(isSelected ? .black : .white)
                                .opacity(0.5)
                            Text(item.date)
                                .font(.footnote)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundStyle(isSelected ? .black : .white)
                                .foregroundColor(isSelected ? .black : .white)
                                .opacity(0.3)
                        }.frame(maxWidth: .infinity)
                    }.padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(.white.opacity(isSelected ? 0.7 : 0.00001))
                        .onTapGesture {
                            selectedCommit = item
                        }.hoverOpacity()
                    Divider().opacity(0.3)
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollIndicators(.hidden)
    }
    
}
