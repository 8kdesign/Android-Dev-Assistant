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
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
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
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        if !output.isEmpty {
            return output
        }
    } catch {
        print("Error running which: \(error)")
    }
    return nil
}

@LogicActor func startADBDeviceListener(adbPath: String, callback: @escaping (String) -> ()) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: adbPath)
    process.arguments = ["track-devices"]
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = Pipe() // discard errors or capture them
    do {
        try process.run()
    } catch {
        return
    }
    pipe.fileHandleForReading.readabilityHandler = { handle in
        let data = handle.availableData
        if !data.isEmpty {
            let output = String(decoding: data, as: UTF8.self)
            callback(output.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}

@LogicActor func locateADBViaSDK() -> String? {
    let home = ProcessInfo.processInfo.environment["HOME"] ?? ""
    let adb = "\(home)/Library/Android/sdk/platform-tools/adb"
    return FileManager.default.isExecutableFile(atPath: adb) ? adb : nil
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
