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
    var branches: [String] = []
    
    init() {
        runOnLogicThread {
            guard let path = runWhich(command: "git") else { return }
            Task { @MainActor in
                self.gitPath = path
            }
        }
    }
    
    func getGitBranches(repo: RepoItem, callback: @escaping @MainActor ([String], String?) -> ()) {
        guard let gitPath else { return }
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
    
    func getBranchCommits(repo: RepoItem, branch: String, callback: @escaping @MainActor ([CommitItem]) -> ()) -> Task<(), Never>? {
        guard let gitPath else { return nil }
        return runOnLogicThread {
            do {
                let result = try await runCommand(
                    path: gitPath,
                    arguments: ["-C", repo.path, "log", branch, "-100", "--pretty=format:\"%H|%h|%an|%ad|%s\"", "--date=short"],
                )
                let string = String(data: result, encoding: .utf8)
                if string?.starts(with: "fatal") == true {
                    Task { @MainActor in
                        callback([])
                    }
                    return
                }
                let commits = string?.split(separator: "\n")
                    .compactMap { line -> CommitItem? in
                        let parts = line.split(separator: "|", maxSplits: 4, omittingEmptySubsequences: false)
                        guard parts.count == 5 else { return nil }
                        return CommitItem(
                            longHash: String(parts[0]),
                            shortHash: String(parts[1]),
                            author: String(parts[2]),
                            date: String(parts[3]),
                            message: String(parts[4].trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
                        )
                    } ?? []
                Task { @MainActor in
                    callback(commits)
                }
            } catch {
                Task { @MainActor in
                    callback([])
                    LogHelper.shared.insertLog(string: error.localizedDescription)
                }
            }
        }
    }
    
}
