//
//  ThemeManager.swift
//  Android Dev Assistant
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {

    @Published var isDarkMode: Bool {
        didSet { UserDefaultsHelper.setDarkModeEnabled(isDarkMode) }
    }

    init() {
        isDarkMode = UserDefaultsHelper.getDarkModeEnabled()
    }

    var colorScheme: ColorScheme { isDarkMode ? .dark : .light }

    // MARK: - Backgrounds

    /// Popup overlay dimming background
    var overlayBackground: Color { isDarkMode ? Color(white: 0.01).opacity(0.9) : Color.black.opacity(0.4) }

    /// Deep background for image/preview areas (0.05 dark, 0.97 light)
    var backgroundDeep: Color { Color(white: isDarkMode ? 0.05 : 0.97) }

    /// Search/input field background (0.07 dark, 0.94 light)
    var backgroundInput: Color { Color(white: isDarkMode ? 0.07 : 0.94) }

    /// Settings info panel background (0.08 dark, 0.93 light)
    var backgroundInfoPanel: Color { Color(white: isDarkMode ? 0.08 : 0.93) }

    /// Main app background (0.1 dark, 0.92 light)
    var background: Color { Color(white: isDarkMode ? 0.1 : 0.92) }

    /// Sidebar/secondary panel background (0.12 dark, 0.90 light)
    var backgroundSecondary: Color { Color(white: isDarkMode ? 0.12 : 0.90) }

    /// Elevated elements like headers (0.13 dark, 0.88 light)
    var backgroundElevated: Color { Color(white: isDarkMode ? 0.13 : 0.88) }

    /// Card/item/tertiary background (0.15 dark, 0.85 light)
    var backgroundTertiary: Color { Color(white: isDarkMode ? 0.15 : 0.85) }

    // MARK: - Surfaces

    /// List item wrapper background (0.17 dark, 0.83 light)
    var surface: Color { Color(white: isDarkMode ? 0.17 : 0.83) }

    /// Selected/active surface (0.2 dark, 0.80 light)
    var surfaceHighlighted: Color { Color(white: isDarkMode ? 0.2 : 0.80) }

    // MARK: - Misc

    /// Toast normal style background
    var toastNormal: Color { Color(white: isDarkMode ? 0.25 : 0.78) }

    /// Canvas grid lines
    var gridLine: Color { Color(white: isDarkMode ? 0.3 : 0.70) }

    /// Canvas grid text
    var gridText: Color { Color(white: isDarkMode ? 0.5 : 0.45) }

    // MARK: - Selection

    /// Background for selected items (e.g. selected commit)
    var selectedBackground: Color { isDarkMode ? .white : .black }

    // MARK: - Badge

    /// Settings header badge background
    var badgeBackground: Color { isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8) }

    /// Settings header badge text
    var badgeText: Color { isDarkMode ? .black : .white }

}
