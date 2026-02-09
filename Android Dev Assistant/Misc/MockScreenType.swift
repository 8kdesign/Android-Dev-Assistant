//
//  MockScreenSize.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 9/2/26.
//

import Foundation

enum MockScreenType: Equatable {
    
    case NORMAL
    case MOCK_PHONE_23_9
    case MOCK_PHONE_18_9
    case MOCK_PHONE_16_9
    case MOCK_TABLET_16_10
    case MOCK_TABLET_4_3
    case CUSTOM
    
    @LogicActor func getScreenSize(originalSize: ScreenSize) -> ScreenSize? {
        var ratio: CGFloat = 1
        switch self {
        case .NORMAL: return originalSize
        case .MOCK_PHONE_23_9: ratio = 23.0 / 9.0
        case .MOCK_PHONE_18_9: ratio = 18.0 / 9.0
        case .MOCK_PHONE_16_9: ratio = 16.0 / 9.0
        case .MOCK_TABLET_16_10: return ScreenSize(width: 3000, height: 4800)
        case .MOCK_TABLET_4_3: return ScreenSize(width: 3000, height: 4000)
        case .CUSTOM: return nil
        }
        let currentRatio = CGFloat(originalSize.height) / CGFloat(originalSize.width)
        if (currentRatio > ratio) {
            // Take width
            let height = originalSize.height
            let width = Int(CGFloat(originalSize.height) / ratio)
            return ScreenSize(width: width, height: height)
        } else {
            // Take height
            let height = Int(CGFloat(originalSize.width) * ratio)
            let width = originalSize.width
            return ScreenSize(width: width, height: height)
        }
    }
    
    @MainActor func getLabel() -> String {
        switch self {
        case .NORMAL: return "Original"
        case .MOCK_PHONE_23_9: return "Phone 23:9"
        case .MOCK_PHONE_18_9: return "Phone 18:9"
        case .MOCK_PHONE_16_9: return "Phone 16:9"
        case .MOCK_TABLET_16_10: return "Tablet 16:10"
        case .MOCK_TABLET_4_3: return "Tablet 4:3"
        case .CUSTOM: return "Custom"
        }
    }
    
    @MainActor func isTablet() -> Bool {
        switch self {
        case .NORMAL,
        .CUSTOM,
        .MOCK_PHONE_23_9,
        .MOCK_PHONE_18_9,
        .MOCK_PHONE_16_9: return false
        case .MOCK_TABLET_16_10,
        .MOCK_TABLET_4_3: return true
        }
    }
    
}
