//
//  CompareFileView.swift
//  Android Dev Assistant
//

import SwiftUI

enum DiffLineType {
    case unchanged
    case added
    case removed
    case placeholder
}

struct DiffLine: Identifiable {
    let id = UUID()
    let lineNumber: Int?
    let text: String
    let type: DiffLineType
}

struct CompareFileView: View {

    @EnvironmentObject var gitHelper: GitHelper
    @EnvironmentObject var repoHelper: RepoHelper
    @EnvironmentObject var theme: ThemeManager

    let file: GitFileItem
    let currentCommit: CommitItem

    @State private var compareBranch: String? = nil
    @State private var compareBranchCommits: [CommitItem] = []
    @State private var compareCommit: CommitItem? = nil
    @State private var leftLines: [DiffLine] = []
    @State private var rightLines: [DiffLine] = []
    @State private var isLoading: Bool = false
    @State private var isIdentical: Bool = false
    @State private var isBinary: Bool = false
    @State private var diffJob: Task<(), Never>? = nil
    @State private var commitsJob: Task<(), Never>? = nil

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            Divider()
            PickerView()
            Divider()
            ContentView()
        }
        .frame(minWidth: 800, minHeight: 500)
        .background(theme.background)
        .preferredColorScheme(theme.colorScheme)
    }

    private func HeaderView() -> some View {
        HStack(spacing: 10) {
            Image(systemName: "doc.on.doc")
                .foregroundStyle(.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.body.bold())
                    .foregroundStyle(.primary)
                Text(file.path)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .opacity(0.3)
            }
            Spacer()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(theme.backgroundTertiary)
    }

    private func PickerView() -> some View {
        HStack(spacing: 10) {
            Text("Branch:")
                .font(.callout)
                .foregroundStyle(.primary)
            Picker("", selection: $compareBranch) {
                Text("Select a branch").tag(nil as String?)
                ForEach(gitHelper.branches, id: \.self) { branch in
                    Text(branch)
                        .lineLimit(1)
                        .tag(branch as String?)
                }
            }
            .labelsHidden()
            .frame(width: 250, alignment: .leading)
            Text("Commit:")
                .font(.callout)
                .foregroundStyle(.primary)
            Picker("", selection: $compareCommit) {
                Text("Select a commit").tag(nil as CommitItem?)
                ForEach(compareBranchCommits.filter { $0.id != currentCommit.id }) { commit in
                    Text("\(commit.shortHash) - \(commit.message)")
                        .lineLimit(1)
                        .tag(commit as CommitItem?)
                }
            }
            .labelsHidden()
            .frame(width: 400, alignment: .leading)
            .disabled(compareBranch == nil)
            Spacer()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(theme.backgroundSecondary)
        .onChange(of: compareBranch) { _ in
            fetchBranchCommits()
        }
        .onChange(of: compareCommit) { _ in
            fetchDiff()
        }
        .onAppear {
            compareBranch = gitHelper.selectedBranch
        }
    }

    @ViewBuilder
    private func ContentView() -> some View {
        if isLoading {
            VStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.primary)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if isBinary {
            VStack(spacing: 10) {
                Image(systemName: "doc.questionmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.primary)
                Text("Binary files differ")
                    .foregroundStyle(.primary)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if isIdentical {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.green)
                Text("Files are identical")
                    .foregroundStyle(.primary)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !leftLines.isEmpty || !rightLines.isEmpty {
            DiffView()
        } else {
            VStack(spacing: 10) {
                Image(systemName: "arrow.left.arrow.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.primary)
                    .opacity(0.5)
                Text("Select a commit to compare")
                    .foregroundStyle(.primary)
                    .opacity(0.5)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func DiffView() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("\(compareBranch ?? "") \(compareCommit?.shortHash ?? "")")
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(theme.backgroundElevated)
                Divider().frame(height: 24)
                Text("\(gitHelper.selectedBranch ?? "") \(currentCommit.shortHash)")
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(theme.backgroundElevated)
            }
            Divider()
            ScrollView(.vertical) {
                let count = max(leftLines.count, rightLines.count)
                LazyVStack(spacing: 0) {
                    ForEach(0..<count, id: \.self) { index in
                        HStack(spacing: 0) {
                            if let line = leftLines[safe: index] {
                                DiffLineRow(line: line)
                            }
                            Divider()
                            if let line = rightLines[safe: index] {
                                DiffLineRow(line: line)
                            }
                        }.frame(maxWidth: .infinity)
                    }
                }.padding(.vertical, 5)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func DiffLineRow(line: DiffLine) -> some View {
        let bgColor: Color
        switch line.type {
        case .added: bgColor = .green.opacity(0.15)
        case .removed: bgColor = .red.opacity(0.15)
        case .placeholder: bgColor = theme.backgroundInfoPanel
        case .unchanged: bgColor = .clear
        }

        return HStack(alignment: .top, spacing: 0) {
            if let num = line.lineNumber {
                Text("\(num)")
                    .font(.system(.caption, design: .monospaced))
                    .frame(width: 40, alignment: .trailing)
                    .foregroundStyle(.primary)
                    .opacity(0.4)
                    .padding(.vertical, 2)
                    .padding(.trailing, 4)
            } else {
                Text("")
                    .frame(width: 40, alignment: .trailing)
                    .padding(.vertical, 2)
                    .padding(.trailing, 4)
            }
            Divider().opacity(0.3)
            Text(line.text)
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.primary)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
        }
        .background(bgColor)
        .frame(maxWidth: .infinity)
    }

}

extension CompareFileView {

    private func fetchBranchCommits() {
        commitsJob?.cancel()
        compareCommit = nil
        compareBranchCommits = []
        leftLines = []
        rightLines = []
        isIdentical = false
        isBinary = false

        guard let repo = repoHelper.selectedRepo,
              let branch = compareBranch else { return }

        commitsJob = gitHelper.getBranchCommits(repo: repo, branch: branch) { commits in
            compareBranchCommits = commits
        }
    }

    private func fetchDiff() {
        diffJob?.cancel()
        leftLines = []
        rightLines = []
        isIdentical = false
        isBinary = false

        guard let repo = repoHelper.selectedRepo,
              let compareCommit else { return }

        isLoading = true

        diffJob = gitHelper.getFileDiff(
            repo: repo,
            fromHash: compareCommit.longHash,
            toHash: currentCommit.longHash,
            file: file.path
        ) { diffOutput in
            let trimmed = diffOutput.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmed.isEmpty || trimmed.hasPrefix("fatal:") {
                Task { @MainActor in
                    isIdentical = trimmed.isEmpty
                    isLoading = false
                }
                return
            }

            if trimmed.contains("Binary files") && trimmed.contains("differ") {
                Task { @MainActor in
                    isBinary = true
                    isLoading = false
                }
                return
            }

            let result = Self.parseDiff(trimmed)
            Task { @MainActor in
                leftLines = result.left
                rightLines = result.right
                if result.left.isEmpty && result.right.isEmpty {
                    isIdentical = true
                }
                isLoading = false
            }
        }
    }

    static func parseDiff(_ diffOutput: String) -> (left: [DiffLine], right: [DiffLine]) {
        var left: [DiffLine] = []
        var right: [DiffLine] = []
        var leftLineNum = 0
        var rightLineNum = 0

        let lines = diffOutput.components(separatedBy: "\n")
        var inHunk = false

        for line in lines {
            if line.hasPrefix("@@") {
                let pattern = #"@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@"#
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
                   let range1 = Range(match.range(at: 1), in: line),
                   let range2 = Range(match.range(at: 2), in: line),
                   let num1 = Int(line[range1]),
                   let num2 = Int(line[range2]) {
                    leftLineNum = num1 - 1
                    rightLineNum = num2 - 1
                }
                inHunk = true
                continue
            }

            guard inHunk else { continue }

            if line.hasPrefix("diff --git") {
                inHunk = false
                continue
            }

            if line.hasPrefix("index ") || line.hasPrefix("--- ") || line.hasPrefix("+++ ") || line.hasPrefix("\\") {
                continue
            }

            if line.hasPrefix("-") {
                leftLineNum += 1
                left.append(DiffLine(lineNumber: leftLineNum, text: String(line.dropFirst()), type: .removed))
                right.append(DiffLine(lineNumber: nil, text: "", type: .placeholder))
            } else if line.hasPrefix("+") {
                rightLineNum += 1
                left.append(DiffLine(lineNumber: nil, text: "", type: .placeholder))
                right.append(DiffLine(lineNumber: rightLineNum, text: String(line.dropFirst()), type: .added))
            } else if line.hasPrefix(" ") {
                leftLineNum += 1
                rightLineNum += 1
                let text = String(line.dropFirst())
                left.append(DiffLine(lineNumber: leftLineNum, text: text, type: .unchanged))
                right.append(DiffLine(lineNumber: rightLineNum, text: text, type: .unchanged))
            }
        }

        return (left, right)
    }

}
