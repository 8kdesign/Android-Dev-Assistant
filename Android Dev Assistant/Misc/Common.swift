//
//  Common.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import Foundation
import AppKit

enum CommonError: Error {
    case adbNotFound
}

@LogicActor func runAdbCommand(adbPath: String?, arguments: [String]) async throws -> Data {
    guard let adbPath else { throw CommonError.adbNotFound }
    let process = Process()
    process.executableURL = URL(fileURLWithPath: adbPath)
    process.arguments = arguments
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    try process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return data
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

func openFolder(_ item: ApkItem) {
    let url = URL(fileURLWithPath: item.path).deletingLastPathComponent()
    NSWorkspace.shared.open(url)
}

func copyToClipboard(_ item: any NSPasteboardWriting) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.writeObjects([item])
}
