//
//  Common.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import Foundation
import AppKit
import CryptoKit

@LogicActor let ROOT_PATH: String = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
@LogicActor let appSupportURL = FileManager.default
    .urls(for: .applicationSupportDirectory, in: .userDomainMask)
    .first?
    .appendingPathComponent("AndroidDevAssistant", isDirectory: true)
let HOVER_OPACITY = 0.8

enum CommonError: Error {
    case notFound
}

@LogicActor func runCommand(path: String?, arguments: [String], environment: [String: String]? = nil, directory: URL? = nil) async throws -> Data {
    guard let path else { throw CommonError.notFound }
    let process = Process()
    process.executableURL = URL(fileURLWithPath: path)
    process.arguments = arguments
    process.currentDirectoryURL = directory ?? appSupportURL
    if let environment {
        process.environment = environment
    }
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    try process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return data
}

@LogicActor func runLS(path: String) -> [String]? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/ls")
    process.arguments = [path]
    let pipe = Pipe()
    process.standardOutput = pipe
    do {
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        if let output = String(data: data, encoding: .utf8) {
            return output.components(separatedBy: "\n").filter { !$0.isEmpty }
        }
    } catch {
        print("Error running ls: \(error)")
    }
    return nil
}

@LogicActor func runWhich(command: String) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
    process.arguments = [command]
    process.environment = ["PATH": ROOT_PATH]
    let pipe = Pipe()
    process.standardOutput = pipe
    do {
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        let output = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        if !output.isEmpty {
            return output
        }
    } catch {
        print("Error running which: \(error)")
    }
    return nil
}

@LogicActor func startADBDeviceListener(
    adbPath: String,
    callback: @escaping (_ serial: String, _ state: String) -> Void
) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: adbPath)
    process.arguments = ["track-devices"]
    let pipe = Pipe()
    process.standardOutput = pipe
    var buffer = Data()
    pipe.fileHandleForReading.readabilityHandler = { handle in
        let chunk = handle.availableData
        guard !chunk.isEmpty else { return }
        Task { @MainActor in
            runOnLogicThread {
                buffer.append(chunk)
                while true {
                    guard buffer.count >= 4 else { return }
                    let lengthData = buffer.prefix(4)
                    guard
                        let lengthHex = String(data: lengthData, encoding: .ascii),
                        let length = Int(lengthHex, radix: 16)
                    else {
                        buffer.removeAll()
                        return
                    }
                    guard buffer.count >= 4 + length else { return }
                    let payload = buffer.subdata(in: 4 ..< 4 + length)
                    buffer.removeSubrange(0 ..< 4 + length)
                    handleADBPayload(payload, callback: callback)
                }
            }
        }
    }
    do {
        try process.run()
    } catch {
        print("Failed to start adb track-devices:", error)
    }
}

@LogicActor private func handleADBPayload(
    _ data: Data,
    callback: (_ serial: String, _ state: String) -> Void
) {
    guard let text = String(data: data, encoding: .utf8) else { return }
    let lines = text.split(separator: "\n")

    for line in lines {
        let parts = line.split(separator: "\t")
        guard parts.count == 2 else { continue }

        let serial = String(parts[0])
        let state = String(parts[1])

        callback(serial, state)
    }
}

@LogicActor func locateADBViaSDK() -> String? {
    let home = ProcessInfo.processInfo.environment["HOME"] ?? ""
    let candidates = [
          "/opt/homebrew/bin/adb",
          "/usr/local/bin/adb",
          "\(home)/Library/Android/sdk/platform-tools/adb",
          "/Applications/Android Studio.app/Contents/jbr/bin/adb"
      ]
    for path in candidates {
        if FileManager.default.isExecutableFile(atPath: path) {
            return path
        }
    }
    return nil
}

@LogicActor func locateAaptViaSDK() async -> String? {
    let home = ProcessInfo.processInfo.environment["HOME"] ?? ""
    guard let result = runLS(path: "\(home)/Library/Android/sdk/build-tools/"),
            let version = result.last else { return nil }
    let aapt = "\(home)/Library/Android/sdk/build-tools/\(version)/aapt"
    return FileManager.default.isExecutableFile(atPath: aapt) ? aapt : nil
}

func openFolder(_ path: String) {
    var isDir: ObjCBool = false
    if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
        if isDir.boolValue {
            let url = URL(fileURLWithPath: path)
            NSWorkspace.shared.open(url)
        } else {
            let url = URL(fileURLWithPath: path).deletingLastPathComponent()
            NSWorkspace.shared.open(url)
        }
    }
}

func openInTerminal(_ path: String) {
    let url = URL(fileURLWithPath: path)
    NSWorkspace.shared.open(
        [url],
        withApplicationAt: URL(fileURLWithPath: "/System/Applications/Utilities/Terminal.app"),
        configuration: NSWorkspace.OpenConfiguration()
    )
}

func copyToClipboard(_ item: any NSPasteboardWriting) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.writeObjects([item])
}

func sha256(_ string: String) -> String {
    let data = Data(string.utf8)
    let hash = SHA256.hash(data: data)
    return hash.map { String(format: "%02x", $0) }.joined()
}

@LogicActor func withControlledTaskGroup<T, S>(
    items: [S],
    maxSetSize: Int = 100,
    action: @escaping (S) async -> T?,
    progressUpdate: @escaping (Int) -> () = { _ in }
) async -> [T] {
    return await withTaskGroup(of: (Int, [T]).self, returning: [T].self) { group in
        var setSize = maxSetSize
        var setCount = Int(ceil(Double(items.count) / Double(setSize)))
        if (setCount > 20) {
            setCount = 20
            setSize = Int(ceil(Double(items.count) / Double(setCount)))
        }
        for i in 0..<setCount {
            let startIndex = i * setSize
            let endIndex = min(startIndex + setSize, items.count)
            if (endIndex <= startIndex) { break }
            group.addTask {
                var result: [T] = []
                for itemIndex in startIndex..<endIndex {
                    guard let item = await items[safe: itemIndex] else { break }
                    if let value = await action(item) {
                        result.append(value)
                    }
                }
                progressUpdate(endIndex)
                return (i, result)
            }
        }
        var result: [(index: Int, result: [T])] = []
        for await array in group {
            result.append(array)
        }
        var sortedResult: [T] = []
        result.sorted { $0.index < $1.index }.forEach { index, array in
            sortedResult.append(contentsOf: array)
        }
        return sortedResult
    }
}
