//
//  Threading.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import Foundation

@globalActor actor LogicActor {
    static let shared = LogicActor()
}

@discardableResult
func runOnLogicThread(delayDuration: Double = 0, repeatDuration: Double = -1, _ block: @LogicActor @escaping () async throws -> Void) -> Task<(), Never> {
    return Task { @LogicActor in
        if (delayDuration > 0) {
            try? await Task.sleep(nanoseconds: UInt64(delayDuration * 1_000_000_000))
        }
        if (Task.isCancelled) { return }
        if (repeatDuration > 0) {
            repeat {
                try? await block()
                try? await Task.sleep(nanoseconds: UInt64(repeatDuration * 1_000_000_000))
            } while (!Task.isCancelled)
        } else {
            try? await block()
        }
    }
}

