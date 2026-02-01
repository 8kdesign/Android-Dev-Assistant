//
//  Extensions.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 1/2/26.
//

import Foundation
import AppKit

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation else { return nil }
        guard let bitmapImageRep = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImageRep.representation(using: .png, properties: [:])
    }
}
