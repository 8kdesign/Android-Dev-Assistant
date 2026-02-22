//
//  ComponentRelationInfo.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 22/2/26.
//

import SwiftUI

class AnalyzeSpacingInfo {
    
    let otherRect: CGRect
    let xGridMap: [Int: CGFloat] // relative pixel to position
    let yGridMap: [Int: CGFloat] // relative pixel to position
    
    init(otherRect: CGRect, xGridMap: [Int : CGFloat], yGridMap: [Int : CGFloat]) {
        self.otherRect = otherRect
        self.xGridMap = xGridMap
        self.yGridMap = yGridMap
    }
    
}
