//
//  ScreenshotHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 1/2/26.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

class ScreenshotHelper {
    
    static func save(image: NSImage) {
        guard let data = image.pngData else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "screenshot.png"
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? data.write(to: url)
            }
        }
    }
    
}
