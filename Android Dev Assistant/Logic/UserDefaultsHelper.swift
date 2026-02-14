//
//  UserDefaultsHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 2/2/26.
//

import Foundation

fileprivate let defaults = UserDefaults.standard

fileprivate let SCREENSHOT_EDIT_IS_HIGHLIGHT_KEY = "screenshot_edit_is_highlight"
fileprivate let DISABLE_SCREENSHOT_CLEANER_KEY = "screenshot_cleaner"
fileprivate let LAST_SELECTED_TAB_IS_REPO = "last_selected_tab_is_repo"

class UserDefaultsHelper {
    
    static func setScreenshotEditIsHighlight(_ isHighlight: Bool) {
        defaults.set(isHighlight, forKey: SCREENSHOT_EDIT_IS_HIGHLIGHT_KEY)
    }
    
    static func getScreenshotEditIsHighlight() -> Bool {
        return defaults.bool(forKey: SCREENSHOT_EDIT_IS_HIGHLIGHT_KEY)
    }
    
    static func setScreenshotCleanerEnabled(_ isEnabled: Bool) {
        defaults.set(!isEnabled, forKey: DISABLE_SCREENSHOT_CLEANER_KEY)
    }
    
    static func getScreenshotCleanerEnabled() -> Bool {
        return !defaults.bool(forKey: DISABLE_SCREENSHOT_CLEANER_KEY)
    }
    
    static func setLastSelectedTab(_ isRepo: Bool) {
        defaults.set(isRepo, forKey: LAST_SELECTED_TAB_IS_REPO)
    }
    
    static func getLastSelectedTabIsRepo() -> Bool {
        return defaults.bool(forKey: LAST_SELECTED_TAB_IS_REPO)
    }
    
}
