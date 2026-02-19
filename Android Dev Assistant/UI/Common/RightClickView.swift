//
//  RightClickView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 20/2/26.
//

import SwiftUI

struct RightClickView: NSViewRepresentable {

    var onRightClick: (CGPoint) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = RightClickableNSView()
        view.onRightClick = onRightClick
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    final class RightClickableNSView: NSView {

        var onRightClick: ((CGPoint) -> Void)?

        override func rightMouseDown(with event: NSEvent) {
            let location = convert(event.locationInWindow, from: nil)
            onRightClick?(CGPoint(x: location.x, y: bounds.height - location.y))
        }
    }
}
