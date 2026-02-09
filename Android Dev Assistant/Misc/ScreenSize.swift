//
//  ScreenSize.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 10/2/26.
//

import Foundation

@LogicActor class ScreenSize: Equatable {
    
    let width: Int
    let height: Int
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    static func == (lhs: ScreenSize, rhs: ScreenSize) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }
    
}
