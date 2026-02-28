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
    @EnvironmentObject var theme: ThemeManager
    @FocusState var focus: Bool

    @State var filteredBranches: [String] = []
    @State var searchTerm: String = ""
    @State var isSelectingBranch: Bool = false
    @State var searchJob: Task<(), Never>? = nil

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                SelectedBranchView()
                Divider().opacity(0.7)
                CommitSelectorView()
            }
            if isSelectingBranch {
                BranchSelectorView()
            }
        }.frame(maxHeight: .infinity)
            .frame(width: 200)
            .background(theme.backgroundTertiary)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding([.vertical, .leading])
            .onChange(of: searchTerm) { _ in
                getFilteredBranches(branches: gitHelper.branches)
            }.onChange(of: isSelectingBranch) { value in
                if !value {
                    searchTerm = ""
                }
            }.onReceive(gitHelper.$branches) { value in
                getFilteredBranches(branches: value)
            }.onReceive(repoHelper.$selectedRepo) { repo in
                isSelectingBranch = false
                filteredBranches = []
                gitHelper.selectedRepo = repo
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
                    .foregroundStyle(.primary)
                    .opacity(0.3)
                Text(gitHelper.selectedBranch ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .foregroundStyle(.primary)
            }
            Image(systemName: isSelectingBranch ? "chevron.up" : "chevron.down")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .padding(.all, 4)
                .opacity(0.7)
        }.padding(.all, 15)
            .frame(maxWidth: .infinity, maxHeight: 60)
            .background(isSelectingBranch ? theme.surfaceHighlighted : theme.backgroundTertiary)
            .onTapGesture {
                withAnimation(.snappy(duration: 0.2)) {
                    isSelectingBranch.toggle()
                }
            }.hoverOpacity()
    }

    private func BranchSelectorView() -> some View {
        VStack(spacing: 0) {
            SelectedBranchView()
            TextField("Search", text: $searchTerm)
                .textFieldStyle(.plain)
                .focused($focus)
                .foregroundStyle(.primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(RoundedRectangle(cornerRadius: 10).fill(theme.backgroundTertiary))
                .padding(.horizontal, 5)
                .padding(.bottom, 10)
            Divider().opacity(0.7)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(filteredBranches.enumerated()), id: \.offset) { index, branch in
                        Text(branch)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .truncationMode(.head)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(.primary.opacity(0.00001))
                            .onTapGesture {
                                gitHelper.selectBranch(branch: branch)
                                isSelectingBranch = false
                            }.hoverOpacity()
                        Divider().opacity(0.3)
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: 300)
                .scrollIndicators(.never)
        }.frame(maxWidth: .infinity, alignment: .top)
            .background(theme.surfaceHighlighted)
            .onTapGesture {}
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private func CommitSelectorView() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(gitHelper.commits.enumerated()), id: \.offset) { index, item in
                    CommitItemView(item: item)
                    Divider().opacity(0.3)
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollIndicators(.never)
    }

    private func CommitItemView(item: CommitItem) -> some View {
        let isSelected = item.id == gitHelper.selectedCommit?.id
        return VStack(spacing: 5) {
            Text(item.shortHash)
                .font(.footnote)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(isSelected ? theme.badgeText : .primary)
                .opacity(0.5)
            Text(item.message)
                .font(.callout)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundStyle(isSelected ? theme.badgeText : .primary)
            HStack(spacing: 10) {
                Text("@\(item.author)")
                    .font(.footnote)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(isSelected ? theme.badgeText : .primary)
                    .opacity(0.5)
                Text(item.date)
                    .font(.footnote)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(isSelected ? theme.badgeText : .primary)
                    .opacity(0.3)
            }.frame(maxWidth: .infinity)
        }.padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(theme.selectedBackground.opacity(isSelected ? 0.7 : 0.00001))
            .onTapGesture {
                gitHelper.selectCommit(commit: item)
            }.hoverOpacity()
            .onAppear {
                if item.id == gitHelper.commits.last?.id {
                    gitHelper.loadMoreCommits(offset: gitHelper.commits.count)
                }
            }
    }

}

extension SourceSelectorView {

    private func getFilteredBranches(branches: [String]) {
        searchJob?.cancel()
        if searchTerm.isEmpty {
            filteredBranches = branches
        } else {
            let currentBranches = branches
            let lowercaseSearchTerm = searchTerm.lowercased()
            searchJob = runOnLogicThread {
                let result = currentBranches.filter { $0.lowercased().contains(lowercaseSearchTerm) }
                if Task.isCancelled { return }
                Task { @MainActor in
                    self.filteredBranches = result
                }
            }
        }
    }

}
