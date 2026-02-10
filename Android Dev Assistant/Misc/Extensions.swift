//
//  Extensions.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 1/2/26.
//

import Foundation
import AppKit
import SwiftUI

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation else { return nil }
        guard let bitmapImageRep = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImageRep.representation(using: .png, properties: [:])
    }
}

struct HoverOpacity: ViewModifier {
    let hoverOpacity: Double

    @State private var hovering = false

    func body(content: Content) -> some View {
        content
            .opacity(hovering ? hoverOpacity : 1)
            .onHover { hovering = $0 }
    }
}

extension View {
    func hoverOpacity(_ value: Double = HOVER_OPACITY) -> some View {
        modifier(HoverOpacity(hoverOpacity: value))
    }
}
