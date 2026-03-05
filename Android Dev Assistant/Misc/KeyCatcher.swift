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
        var keyDownMonitor: Any?
        var keyUpMonitor: Any?

        override func viewDidMoveToWindow() {
            guard window != nil else { return }
            keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if let self, let keyCode = self.keyCode, event.keyCode == keyCode {
                    self.onChange?(true)
                    return nil
                }
                return event
            }
            keyUpMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [weak self] event in
                if let self, let keyCode = self.keyCode, event.keyCode == keyCode {
                    self.onChange?(false)
                    return nil
                }
                return event
            }
        }

        override func removeFromSuperview() {
            if let keyDownMonitor { NSEvent.removeMonitor(keyDownMonitor) }
            if let keyUpMonitor { NSEvent.removeMonitor(keyUpMonitor) }
            keyDownMonitor = nil
            keyUpMonitor = nil
            super.removeFromSuperview()
        }
    }
}
