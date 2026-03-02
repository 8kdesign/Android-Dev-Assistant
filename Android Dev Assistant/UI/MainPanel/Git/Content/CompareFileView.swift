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

    // Left side
    @State private var leftBranch: String? = nil
    @State private var leftBranchCommits: [CommitItem] = []
    @State private var leftCommit: CommitItem? = nil
    @State private var leftCommitsJob: Task<(), Never>? = nil

    // Right side
    @State private var rightBranch: String? = nil
    @State private var rightBranchCommits: [CommitItem] = []
    @State private var rightCommit: CommitItem? = nil
    @State private var rightCommitsJob: Task<(), Never>? = nil

    // Content
    @State private var leftLines: [DiffLine] = []
    @State private var rightLines: [DiffLine] = []
    @State private var isLoading: Bool = false
    @State private var isIdentical: Bool = false
    @State private var isBinary: Bool = false
    @State private var contentJob: Task<(), Never>? = nil
    @State private var leftInitialSetupDone: Bool = false
    @State private var rightInitialSetupDone: Bool = false

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
        .onChange(of: leftBranch) { _ in
            fetchBranchCommits(isLeft: true)
        }
        .onChange(of: rightBranch) { _ in
            fetchBranchCommits(isLeft: false)
        }
        .onChange(of: leftCommit) { _ in
            fetchContent()
        }
        .onChange(of: rightCommit) { _ in
            fetchContent()
        }
        .onAppear {
            leftBranch = gitHelper.selectedBranch
            rightBranch = gitHelper.selectedBranch
        }
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
        HStack(spacing: 0) {
            SidePickerView(branch: $leftBranch, commit: $leftCommit, commits: leftBranchCommits)
            Divider().frame(height: 40)
            SidePickerView(branch: $rightBranch, commit: $rightCommit, commits: rightBranchCommits)
        }
        .background(theme.backgroundSecondary)
    }

    private func SidePickerView(branch: Binding<String?>, commit: Binding<CommitItem?>, commits: [CommitItem]) -> some View {
        HStack(spacing: 8) {
            Picker("", selection: branch) {
                Text("").tag(nil as String?)
                ForEach(gitHelper.branches, id: \.self) { b in
                    Text(b).lineLimit(1).tag(b as String?)
                }
            }
            .labelsHidden()
            Picker("", selection: commit) {
                Text("").tag(nil as CommitItem?)
                ForEach(commits) { c in
                    Text("\(c.shortHash) - \(c.message)").lineLimit(1).tag(c as CommitItem?)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .labelsHidden()
            .disabled(branch.wrappedValue == nil)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
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
                Text("\(leftBranch ?? "") \(leftCommit?.shortHash ?? "")")
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(theme.backgroundElevated)
                Divider().frame(height: 24)
                Text("\(rightBranch ?? "") \(rightCommit?.shortHash ?? "")")
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
                            } else {
                                Color.clear.frame(maxWidth: .infinity, minHeight: 1)
                            }
                            Divider()
                            if let line = rightLines[safe: index] {
                                DiffLineRow(line: line)
                            } else {
                                Color.clear.frame(maxWidth: .infinity, minHeight: 1)
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

    private func fetchBranchCommits(isLeft: Bool) {
        if isLeft {
            leftCommitsJob?.cancel()
            leftCommit = nil
            leftBranchCommits = []
            guard let repo = repoHelper.selectedRepo, let branch = leftBranch else { return }
            leftCommitsJob = gitHelper.getBranchCommits(repo: repo, branch: branch) { commits in
                leftBranchCommits = commits
                if !leftInitialSetupDone {
                    leftInitialSetupDone = true
                    if commits.contains(where: { $0.id == currentCommit.id }) {
                        leftCommit = currentCommit
                    }
                }
            }
        } else {
            rightCommitsJob?.cancel()
            rightCommit = nil
            rightBranchCommits = []
            guard let repo = repoHelper.selectedRepo, let branch = rightBranch else { return }
            rightCommitsJob = gitHelper.getBranchCommits(repo: repo, branch: branch) { commits in
                rightBranchCommits = commits
                if !rightInitialSetupDone {
                    rightInitialSetupDone = true
                    if commits.contains(where: { $0.id == currentCommit.id }) {
                        rightCommit = currentCommit
                    }
                }
            }
        }
    }

    private func fetchContent() {
        contentJob?.cancel()
        leftLines = []
        rightLines = []
        isIdentical = false
        isBinary = false

        guard let repo = repoHelper.selectedRepo else { return }

        if let leftHash = leftCommit?.longHash, let rightHash = rightCommit?.longHash {
            // Both selected — diff mode
            isLoading = true
            contentJob = gitHelper.getFileDiff(
                repo: repo,
                fromHash: leftHash,
                toHash: rightHash,
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
        } else if let hash = leftCommit?.longHash ?? rightCommit?.longHash {
            // Single side — plain file view
            let isLeft = leftCommit != nil
            isLoading = true
            contentJob = gitHelper.getFileData(repo: repo, hash: hash, file: file.path) { result in
                guard let result, let string = result as? String else {
                    Task { @MainActor in
                        isLoading = false
                    }
                    return
                }
                let lines = string.components(separatedBy: "\n").enumerated().map { index, text in
                    DiffLine(lineNumber: index + 1, text: text, type: .unchanged)
                }
                Task { @MainActor in
                    if isLeft {
                        leftLines = lines
                        rightLines = []
                    } else {
                        leftLines = []
                        rightLines = lines
                    }
                    isLoading = false
                }
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
