//
//  GitHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 13/2/26.
//

import Foundation
import Combine

class GitHelper: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    
    var gitPath: String? = nil
    var selectedRepo: RepoItem? = nil {
        didSet {
            fetchRepoBranches(selectedRepo)
        }
    }
    @Published var branches: [String] = []
    var currentBranch: String? = nil
    var selectedBranch: String? = nil
    var commits: [CommitItem] = []
    var selectedCommit: CommitItem?
    var gitJob: Task<(), Never>? = nil

    init() {
        runOnLogicThread {
            guard let path = runWhich(command: "git") else { return }
            Task { @MainActor in
                self.gitPath = path
                self.fetchRepoBranches(self.selectedRepo)
            }
        }
    }

    // Branch
    
    func fetchRepoBranches(_ repo: RepoItem?) {
        gitJob?.cancel()
        branches = []
        commits = []
        selectedCommit = nil
        if let repo {
            getGitBranches(repo: repo) { list, currentBranch in
                self.branches = list
                self.currentBranch = currentBranch
                self.selectedBranch = currentBranch
                if let currentBranch {
                    self.gitJob = self.getBranchCommits(repo: repo, branch: currentBranch) { commits in
                        self.commits = commits
                        self.selectedCommit = commits.first
                        self.objectWillChange.send()
                    }
                }
            }
        } else {
            self.objectWillChange.send()
        }
    }
    
    func selectBranch(branch: String?, repo: RepoItem?) {
        selectedBranch = branch
        gitJob?.cancel()
        commits = []
        selectedCommit = nil
        if let branch = selectedBranch, let repo {
            gitJob = getBranchCommits(repo: repo, branch: branch) { commits in
                self.commits = commits
                self.selectedCommit = commits.first
                self.objectWillChange.send()
            }
        } else {
            objectWillChange.send()
        }
    }
    
    private func getGitBranches(repo: RepoItem, callback: @escaping @MainActor ([String], String?) -> ()) {
        guard let gitPath else {
            callback([], nil)
            return
        }
        runOnLogicThread {
            do {
                let allBranchesResult = try await runCommand(path: gitPath, arguments: ["-C", repo.path, "branch", "--all"])
                let allBranchesString = String(data: allBranchesResult, encoding: .utf8)
                if allBranchesString?.starts(with: "fatal") == true {
                    Task { @MainActor in
                        callback([], nil)
                    }
                    return
                }
                var currentBranch: String? = nil
                var branches: [String] = []
                allBranchesString?
                    .split(separator: "\n")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.contains("->") }
                    .forEach { branch in
                        if branch.starts(with: "*") {
                            let parsedBranch = branch.dropFirst().trimmingCharacters(in: .whitespaces)
                            currentBranch = parsedBranch
                            branches.append(parsedBranch)
                        } else {
                            branches.append(branch)
                        }
                    }
                if (branches.isEmpty || currentBranch == nil) {
                    Task { @MainActor in
                        callback([], nil)
                    }
                    return
                }
                let fixedBranches = branches
                let fixedCurrentBranch = currentBranch
                Task { @MainActor in
                    callback(fixedBranches, fixedCurrentBranch)
                }
            } catch {
                Task { @MainActor in
                    callback([], nil)
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }
    
    // Commit
    
    func selectCommit(commit: CommitItem?) {
        selectedCommit = commit
        objectWillChange.send()
    }
    
    private func getBranchCommits(repo: RepoItem, branch: String, callback: @escaping @MainActor ([CommitItem]) -> ()) -> Task<(), Never>? {
        guard let gitPath else {
            callback([])
            return nil
        }
        return runOnLogicThread {
            do {
                let result = try await runCommand(
                    path: gitPath,
                    arguments: ["-C", repo.path, "log", branch, "-100", "--pretty=format:\"%H|%h|%an|%ad|%s\"", "--date=short"],
                )
                let string = String(data: result, encoding: .utf8)
                if string?.starts(with: "fatal") == true {
                    if !Task.isCancelled {
                        Task { @MainActor in
                            callback([])
                        }
                    }
                    return
                }
                let commits = string?.split(separator: "\n")
                    .compactMap { line -> CommitItem? in
                        let parts = line.split(separator: "|", maxSplits: 4, omittingEmptySubsequences: false)
                        guard parts.count == 5 else { return nil }
                        return CommitItem(
                            longHash: String(parts[0].trimmingCharacters(in: CharacterSet(charactersIn: "\""))),
                            shortHash: String(parts[1]),
                            author: String(parts[2]),
                            date: String(parts[3]),
                            message: String(parts[4].trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
                        )
                    } ?? []
                if !Task.isCancelled {
                    Task { @MainActor in
                        callback(commits)
                    }
                }
            } catch {
                if !Task.isCancelled {
                    Task { @MainActor in
                        callback([])
                        LogHelper.shared.insertLog(string: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // File
    
    func getFiles(repo: RepoItem, hash: String, callback: @escaping @MainActor ([GitFileItem]) -> ()) {
        guard let gitPath else {
            callback([])
            return
        }
        runOnLogicThread {
            do {
                let result = try await runCommand(
                    path: gitPath,
                    arguments: ["-C", repo.path, "ls-tree", "-r", hash, "--name-only"],
                )
                let string = String(data: result, encoding: .utf8)
                if string?.starts(with: "fatal") == true {
                    if !Task.isCancelled {
                        Task { @MainActor in
                            callback([])
                        }
                    }
                    return
                }
                var fileList: [GitFileItem] = []
                for path in string?.split(separator: "\n") ?? [] {
                    let item = await GitFileItem(path: String(path))
                    fileList.append(item)
                }
                let fixedFileList = fileList
                if !Task.isCancelled {
                    Task { @MainActor in
                        callback(fixedFileList)
                    }
                }
            } catch {
                if !Task.isCancelled {
                    Task { @MainActor in
                        callback([])
                        LogHelper.shared.insertLog(string: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func getFileData(repo: RepoItem, hash: String, file: String, callback: @escaping @MainActor (String?) -> ()) -> Task<(), Never>? {
        guard let gitPath else {
            callback(nil)
            return nil
        }
        return runOnLogicThread {
            do {
                let result = try await runCommand(path: gitPath, arguments: ["-C", repo.path, "show", "\(hash):\(file)"])
                let string = String(data: result, encoding: .utf8)
                if string?.starts(with: "fatal") == true {
                    if !Task.isCancelled {
                        Task { @MainActor in
                            callback(nil)
                        }
                    }
                    return
                }
                if !Task.isCancelled {
                    Task { @MainActor in
                        callback(string)
                    }
                }
            } catch {
                if !Task.isCancelled {
                    Task { @MainActor in
                        callback(nil)
                        LogHelper.shared.insertLog(string: error.localizedDescription)
                    }
                }
            }
        }
    }
    
}
