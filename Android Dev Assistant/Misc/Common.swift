//
//  Common.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import Foundation

@LogicActor func runAdbCommand(adbPath: String?, arguments: [String]) async throws -> String {
    guard let adbPath else { throw CommonError.adbNotFound }
    let process = Process()
    process.executableURL = URL(fileURLWithPath: adbPath)
    process.arguments = arguments
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    try process.run()
    process.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(decoding: data, as: UTF8.self)
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

enum CommonError: Error {
    case adbNotFound
}
