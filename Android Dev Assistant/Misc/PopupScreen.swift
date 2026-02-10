//
//  PopupScreen.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 9/2/26.
//

import Foundation
import SwiftUI

enum PopupScreen {
    case settings
    case screenshot(image: NSImage)
    case mockScreenSize
    case lastCrashLogs(logs: String)
}
