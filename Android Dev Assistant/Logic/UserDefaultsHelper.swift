//
//  UserDefaultsHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 2/2/26.
//

import Foundation

fileprivate let defaults = UserDefaults.standard

fileprivate let SCREENSHOT_EDIT_IS_HIGHLIGHT_KEY = "screenshot_edit_is_highlight"

class UserDefaultsHelper {
    
    static func setScreenshotEditIsHighlight(_ isHighlight: Bool) {
        defaults.set(isHighlight, forKey: SCREENSHOT_EDIT_IS_HIGHLIGHT_KEY)
    }
    
    static func getScreenshotEditIsHighlight() -> Bool {
        return defaults.bool(forKey: SCREENSHOT_EDIT_IS_HIGHLIGHT_KEY)
    }
    
}
