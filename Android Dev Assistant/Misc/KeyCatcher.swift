//
//  KeyCatcher.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 2/2/26.
//

import SwiftUI

struct KeyCatcher: NSViewRepresentable {
    
    let keyCode: Int
    let onChange: (Bool) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        view.keyCode = keyCode
        view.onChange = onChange
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    class KeyView: NSView {
        var keyCode: Int?
        var onChange: ((Bool) -> Void)?

        override var acceptsFirstResponder: Bool { true }

        override func keyDown(with event: NSEvent) {
            if let keyCode, event.keyCode == keyCode {
                onChange?(true)
            } else {
                super.keyDown(with: event)
            }
        }
        
        override func keyUp(with event: NSEvent) {
            if let keyCode, event.keyCode == keyCode {
                onChange?(false)
            } else {
                super.keyUp(with: event)
            }
        }

        override func viewDidMoveToWindow() {
            window?.makeFirstResponder(self)
        }
    }
}
