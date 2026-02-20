//
//  AnalyzeTab.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 20/2/26.
//

import Foundation

enum AnalyzeTab {
    case list
    case fixed(component: ComponentItem)
    case temp(component: ComponentItem)
}

extension AnalyzeTab: Identifiable, Equatable {
    
    var id: String {
        switch self {
        case .list:
            return "list"
        case .fixed(component: let c):
            return "fixed_" + c.id
        case .temp(component: let c):
            return "temp_" + c.id
        }
    }
    
    static func == (lhs: AnalyzeTab, rhs: AnalyzeTab) -> Bool {
        return lhs.id == rhs.id
    }
    
    
}
