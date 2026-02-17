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
            fetchRepoBranches()
        }
    }
    @Published var branches: [String] = []
    var currentBranch: String? = nil
    var selectedBranch: String? = nil
    var commits: [CommitItem] = []
    var selectedCommit: CommitItem? {
        didSet {
            selectedCommitFileDiff = nil
        }
    }
    var selectedCommitFileDiff: [FileDiff]? = nil {
        didSet {
            objectWillChange.send()
        }
    }
    var gitJob: Task<(), Never>? = nil

    init() {
        runOnLogicThread {
            guard let path = runWhich(command: "git") else { return }
            Task { @MainActor in
                self.gitPath = path
                self.fetchRepoBranches()
            }
        }
    }

    // Branch
    
    func fetchRepoBranches() {
        gitJob?.cancel()
        branches = []
        commits = []
        selectCommit(commit: nil)
        if let repo = selectedRepo {
            getGitBranches(repo: repo) { list, currentBranch in
                self.branches = list
                self.currentBranch = currentBranch
                self.selectBranch(branch: currentBranch)
            }
        } else {
            self.objectWillChange.send()
        }
    }
    
    func selectBranch(branch: String?) {
        selectedBranch = branch
        gitJob?.cancel()
        commits = []
        selectCommit(commit: nil)
        if let branch = selectedBranch, let selectedRepo {
            gitJob = getBranchCommits(repo: selectedRepo, branch: branch) { commits in
                self.commits = commits
                self.selectCommit(commit: commits.first)
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
        if let selectedRepo, let commit {
            getCommitInfo(repo: selectedRepo, hash: commit.longHash)
        }
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
    
    func getCommitInfo(repo: RepoItem, hash: String) {
        gitJob?.cancel()
        guard let gitPath else {
            selectedCommitFileDiff = nil
            return
        }
        gitJob = runOnLogicThread {
            do {
                let result = try await runCommand(
                    path: gitPath,
                    arguments: ["-C", repo.path, "show", "--pretty=format:", hash],
                )
                guard let string = String(data: result, encoding: .utf8), !string.starts(with: "fatal") else {
                    if !Task.isCancelled {
                        Task { @MainActor in
                            self.selectedCommitFileDiff = nil
                        }
                    }
                    return
                }
                let lines = string.components(separatedBy: "\n")
                var diffs: [FileDiff] = []
                var currentFile: FileDiff?
                for line in lines {
                    if line.hasPrefix("diff --git ") {
                        if let f = currentFile {
                            diffs.append(f)
                        }
                        let prefixLength = "diff --git ".count
                        let pathsPart = line.dropFirst(prefixLength)
                        let components = pathsPart.components(separatedBy: " b/")
                        if components.count == 2 {
                            let filePath = components[1]
                            currentFile = FileDiff(file: filePath)
                        } else {
                            currentFile = nil
                        }
                        continue
                    }
                    if (currentFile?.added.count ?? 0) + (currentFile?.removed.count ?? 0) > 11 {
                        continue
                    }
                    if line.hasPrefix("+") && !line.hasPrefix("+++ ") {
                        currentFile?.added.append("+ " + String(line.dropFirst().trimmingCharacters(in: .whitespaces)))
                    } else if line.hasPrefix("-") && !line.hasPrefix("--- ") {
                        currentFile?.removed.append("- " + String(line.dropFirst().trimmingCharacters(in: .whitespaces)))
                    }
                }
                if let f = currentFile {
                    diffs.append(f)
                }
                let fixedDiffs = diffs
                if !Task.isCancelled {
                    Task { @MainActor in
                        if self.selectedCommit?.longHash == hash {
                            self.selectedCommitFileDiff = fixedDiffs
                        }
                    }
                }
            } catch {
                if !Task.isCancelled {
                    Task { @MainActor in
                        self.selectedCommitFileDiff = nil
                        LogHelper.shared.insertLog(string: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // File
    
    func getFiles(repo: RepoItem, hash: String, callback: @escaping @MainActor ([GitFileItem]) -> ()) -> Task<(), Never>? {
        guard let gitPath else {
            callback([])
            return nil
        }
        return runOnLogicThread {
            do {
                let result = try await runCommand(
                    path: gitPath,
                    arguments: ["-C", repo.path, "ls-tree", "-z", "-r", hash, "--name-only"],
                )
                let paths = result.split(separator: 0)
                let fileList: [GitFileItem] = await withControlledTaskGroup(items: paths) {
                    let path = String(decoding: $0, as: UTF8.self)
                    let item = await GitFileItem(path: String(path))
                    return item
                }
                if !Task.isCancelled {
                    Task { @MainActor in
                        callback(fileList)
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
