//
//  ComponentPositionRelation.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 21/2/26.
//

import Foundation
import SwiftUI

class ComponentPositionRelation {
    
    var xIntersectType: AxisIntersectType
    var yIntersectType: AxisIntersectType
    var left: CGFloat
    var right: CGFloat
    var top: CGFloat
    var bottom: CGFloat
    var mainSize: CGSize
    var otherSize: CGSize
    
    enum AxisIntersectType {
        case negative
        case partialNegative
        case inside
        case partialPositive
        case positive
        case outside
    }
    
    init(xIntersectType: AxisIntersectType, yIntersectType: AxisIntersectType,
         left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat,
         mainSize: CGSize, otherSize: CGSize) {
        self.xIntersectType = xIntersectType
        self.yIntersectType = yIntersectType
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
        self.mainSize = mainSize
        self.otherSize = otherSize
    }
    
    func getOtherRect(size: CGSize, mainRect: CGRect) -> CGRect? {
        var x1Position: CGFloat = 0
        var x2Position: CGFloat = 0
        switch xIntersectType {
        case .negative:
            x2Position = mainRect.minX - (left > 0 ? (COMPONENT_BOX_WIDTH / 2) : 0)
            x1Position = x2Position - COMPONENT_BOX_WIDTH
        case .partialNegative:
            x2Position = mainRect.minX + (left > 0 ? (COMPONENT_BOX_WIDTH / 2) : 0)
            x1Position = x2Position - COMPONENT_BOX_WIDTH
        case .inside:
            x1Position = mainRect.minX + (left > 0 ? 20 : 0)
            x2Position = mainRect.maxX - (right > 0 ? 20 : 0)
        case .partialPositive:
            x2Position = mainRect.maxX + (right > 0 ? (COMPONENT_BOX_WIDTH / 2) : 0)
            x1Position = x2Position - COMPONENT_BOX_WIDTH
        case .positive:
            x1Position = mainRect.maxX + (right > 0 ? (COMPONENT_BOX_WIDTH / 2) : 0)
            x2Position = x1Position + COMPONENT_BOX_WIDTH
        case .outside:
            x1Position = mainRect.minX - (left > 0 ? (COMPONENT_BOX_WIDTH / 2) : 0)
            x2Position = mainRect.maxX + (right > 0 ? (COMPONENT_BOX_WIDTH / 2) : 0)
        }
        var y1Position: CGFloat = 0
        var y2Position: CGFloat = 0
        switch yIntersectType {
        case .negative:
            y2Position = mainRect.minY - (top > 0 ? (COMPONENT_BOX_WIDTH / 2) : 0)
            y1Position = y2Position - COMPONENT_BOX_WIDTH
        case .partialNegative:
            y2Position = mainRect.minY + (top > 0 ? (COMPONENT_BOX_WIDTH / 2) : 0)
            y1Position = y2Position - COMPONENT_BOX_WIDTH
        case .inside:
            y1Position = mainRect.minY + (top > 0 ? 20 : 0)
            y2Position = mainRect.maxY - (bottom > 0 ? 20 : 0)
        case .partialPositive:
            y2Position = mainRect.maxY + (bottom > 0 ? (COMPONENT_BOX_WIDTH / 2) : 0)
            y1Position = y2Position - COMPONENT_BOX_WIDTH
        case .positive:
            y1Position = mainRect.maxY + (bottom > 0 ? (COMPONENT_BOX_WIDTH / 2) : 0)
            y2Position = y1Position + COMPONENT_BOX_WIDTH
        case .outside:
            y1Position = mainRect.minY - (top > 0 ? (COMPONENT_BOX_WIDTH / 2) : 0)
            y2Position = mainRect.maxY + (bottom > 0 ? (COMPONENT_BOX_WIDTH / 2) : 0)
        }
        return CGRect(x: x1Position, y: y1Position, width: (x2Position - x1Position), height: (y2Position - y1Position))
    }
    
    static func getPositionRelation(mainBounds: CGRect, otherBounds: CGRect) -> ComponentPositionRelation? {
        if mainBounds == otherBounds {
            return nil
        }
        var xIntersectType: AxisIntersectType
        var leftOffset: CGFloat = 0
        var rightOffset: CGFloat = 0
        var yIntersectType: AxisIntersectType
        var topOffset: CGFloat = 0
        var bottomOffset: CGFloat = 0
        if mainBounds.minX >= otherBounds.maxX {
            xIntersectType = .negative
            leftOffset = abs(mainBounds.minX - otherBounds.maxX)
        } else if mainBounds.maxX <= otherBounds.minX {
            xIntersectType = .positive
            rightOffset = abs(mainBounds.maxX - otherBounds.minX)
        } else if mainBounds.minX <= otherBounds.minX && mainBounds.maxX >= otherBounds.maxX {
            xIntersectType = .inside
            leftOffset = abs(mainBounds.minX - otherBounds.minX)
            rightOffset = abs(mainBounds.maxX - otherBounds.maxX)
        } else if mainBounds.minX > otherBounds.minX && mainBounds.maxX < otherBounds.maxX {
            xIntersectType = .outside
            leftOffset = abs(mainBounds.minX - otherBounds.minX)
            rightOffset = abs(mainBounds.maxX - otherBounds.maxX)
        } else if mainBounds.minX <= otherBounds.minX {
            xIntersectType = .partialPositive
            leftOffset = abs(mainBounds.minX - otherBounds.maxX)
            rightOffset = abs(mainBounds.maxX - otherBounds.maxX)
        } else {
            xIntersectType = .partialNegative
            leftOffset = abs(mainBounds.minX - otherBounds.minX)
            rightOffset = abs(mainBounds.maxX - otherBounds.minX)
        }
        if mainBounds.minY >= otherBounds.maxY {
            yIntersectType = .negative
            topOffset = abs(mainBounds.minY - otherBounds.maxY)
        } else if mainBounds.maxY <= otherBounds.minY {
            yIntersectType = .positive
            bottomOffset = abs(mainBounds.maxY - otherBounds.minY)
        } else if mainBounds.minY <= otherBounds.minY && mainBounds.maxY >= otherBounds.maxY {
            yIntersectType = .inside
            topOffset = abs(mainBounds.minY - otherBounds.minY)
            bottomOffset = abs(mainBounds.maxY - otherBounds.maxY)
        } else if mainBounds.minY >= otherBounds.minY && mainBounds.maxY <= otherBounds.maxY {
            yIntersectType = .outside
            topOffset = abs(mainBounds.minY - otherBounds.minY)
            bottomOffset = abs(mainBounds.maxY - otherBounds.maxY)
        } else if mainBounds.minY <= otherBounds.minY {
            yIntersectType = .partialPositive
            topOffset = abs(mainBounds.minY - otherBounds.maxY)
            bottomOffset = abs(mainBounds.maxY - otherBounds.maxY)
        } else {
            yIntersectType = .partialNegative
            topOffset = abs(mainBounds.minY - otherBounds.minY)
            bottomOffset = abs(mainBounds.maxY - otherBounds.minY)
        }
        return ComponentPositionRelation(
            xIntersectType: xIntersectType, yIntersectType: yIntersectType,
            left: leftOffset, right: rightOffset, top: topOffset, bottom: bottomOffset,
            mainSize: mainBounds.size, otherSize: otherBounds.size
        )
    }
    
}
