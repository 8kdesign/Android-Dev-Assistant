//
//  EscapeKeyCatcher.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 2/2/26.
//

import SwiftUI

struct EscapeKeyCatcher: NSViewRepresentable {
    let onEscape: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        view.onEscape = onEscape
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    class KeyView: NSView {
        var onEscape: (() -> Void)?

        override var acceptsFirstResponder: Bool { true }

        override func keyDown(with event: NSEvent) {
            if event.keyCode == 53 { // Escape
                onEscape?()
            } else {
                super.keyDown(with: event)
            }
        }

        override func viewDidMoveToWindow() {
            window?.makeFirstResponder(self)
        }
    }
}
