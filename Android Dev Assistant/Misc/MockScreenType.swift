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
    case MOCK_PHONE_SMALL
    case MOCK_FOLD_1_1
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
        case .MOCK_PHONE_SMALL: return ScreenSize(width: 1080, height: 1920)
        case .MOCK_FOLD_1_1: ratio = 1.0
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
    
    @MainActor func getLabel() -> LocalizedStringResource {
        switch self {
        case .NORMAL: return "Original"
        case .MOCK_PHONE_23_9: return "Phone 23:9"
        case .MOCK_PHONE_18_9: return "Phone 18:9"
        case .MOCK_PHONE_16_9: return "Phone 16:9"
        case .MOCK_PHONE_SMALL: return "Phone Small"
        case .MOCK_FOLD_1_1: return "Fold 1:1"
        case .MOCK_TABLET_16_10: return "Tablet 16:10"
        case .MOCK_TABLET_4_3: return "Tablet 4:3"
        case .CUSTOM: return "Custom"
        }
    }

    @MainActor func getPreviewRatio(originalSize: ScreenSize) -> CGFloat {
        switch self {
        case .NORMAL: return CGFloat(originalSize.width) / CGFloat(max(1, originalSize.height))
        case .MOCK_PHONE_23_9: return 0.39
        case .MOCK_PHONE_18_9: return 0.5
        case .MOCK_PHONE_16_9: return 0.5625
        case .MOCK_PHONE_SMALL: return 0.5625
        case .MOCK_FOLD_1_1: return 1
        case .MOCK_TABLET_16_10: return 0.625
        case .MOCK_TABLET_4_3: return 0.75
        case .CUSTOM: return 0.75
        }
    }
    
    
    @MainActor func isPreviewTablet() -> Bool {
        switch self {
        case .NORMAL,
        .CUSTOM,
        .MOCK_PHONE_23_9,
        .MOCK_PHONE_18_9,
        .MOCK_PHONE_16_9,
        .MOCK_PHONE_SMALL,
        .MOCK_FOLD_1_1: return false
        case.MOCK_TABLET_16_10,
        .MOCK_TABLET_4_3: return true
        }
    }
    
}
