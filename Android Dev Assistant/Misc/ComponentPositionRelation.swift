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
    
    func getOtherRect(size: CGSize, mainRect: CGRect, componentBoxWidth: CGFloat) -> AnalyzeSpacingInfo? {
        var x1Position: CGFloat = 0
        var x2Position: CGFloat = 0
        var xGridMap: [Int: CGFloat] = [:]
        switch xIntersectType {
        case .negative:
            x2Position = mainRect.minX - (left > 0 ? (componentBoxWidth / 2) : 0)
            x1Position = x2Position - componentBoxWidth
            xGridMap[0] = x1Position
            xGridMap[Int(otherSize.width)] = x2Position
            xGridMap[Int(otherSize.width + left)] = mainRect.minX
            xGridMap[Int(otherSize.width + left + mainSize.width)] = mainRect.maxX
        case .partialNegative:
            x2Position = mainRect.minX + (left > 0 ? (componentBoxWidth / 2) : 0)
            x1Position = x2Position - componentBoxWidth
            xGridMap[0] = x1Position
            xGridMap[Int(left)] = mainRect.minX
            xGridMap[Int(otherSize.width)] = x2Position
            xGridMap[Int(mainSize.width + left)] = mainRect.maxX
        case .inside:
            x1Position = mainRect.minX + (left > 0 ? 20 : 0)
            x2Position = mainRect.maxX - (right > 0 ? 20 : 0)
            xGridMap[0] = mainRect.minX
            xGridMap[Int(left)] = x1Position
            xGridMap[Int(mainSize.width - right)] = x2Position
            xGridMap[Int(mainSize.width)] = mainRect.maxX
        case .partialPositive:
            x2Position = mainRect.maxX + (right > 0 ? (componentBoxWidth / 2) : 0)
            x1Position = x2Position - componentBoxWidth
            xGridMap[0] = mainRect.minX
            xGridMap[Int(mainSize.width - left)] = x1Position
            xGridMap[Int(mainSize.width)] = mainRect.maxX
            xGridMap[Int(mainSize.width + right)] = x2Position
        case .positive:
            x1Position = mainRect.maxX + (right > 0 ? (componentBoxWidth / 2) : 0)
            x2Position = x1Position + componentBoxWidth
            xGridMap[0] = mainRect.minX
            xGridMap[Int(mainSize.width)] = mainRect.maxX
            xGridMap[Int(mainSize.width + right)] = x1Position
            xGridMap[Int(mainSize.width + right + otherSize.width)] = x2Position
        case .outside:
            x1Position = mainRect.minX - (left > 0 ? (componentBoxWidth / 2) : 0)
            x2Position = mainRect.maxX + (right > 0 ? (componentBoxWidth / 2) : 0)
            xGridMap[0] = x1Position
            xGridMap[Int(left)] = mainRect.minX
            xGridMap[Int(left + mainSize.width)] = mainRect.maxX
            xGridMap[Int(left + mainSize.width + right)] = x2Position
        }
        var y1Position: CGFloat = 0
        var y2Position: CGFloat = 0
        var yGridMap: [Int: CGFloat] = [:]
        switch yIntersectType {
        case .negative:
            y2Position = mainRect.minY - (top > 0 ? (componentBoxWidth / 2) : 0)
            y1Position = y2Position - componentBoxWidth
            yGridMap[0] = y1Position
            yGridMap[Int(otherSize.height)] = y2Position
            yGridMap[Int(otherSize.height + top)] = mainRect.minY
            yGridMap[Int(otherSize.height + top + mainSize.height)] = mainRect.maxY
        case .partialNegative:
            y2Position = mainRect.minY + (top > 0 ? (componentBoxWidth / 2) : 0)
            y1Position = y2Position - componentBoxWidth
            yGridMap[0] = y1Position
            yGridMap[Int(top)] = mainRect.minY
            yGridMap[Int(otherSize.height)] = y2Position
            yGridMap[Int(mainSize.height + top)] = mainRect.maxY
        case .inside:
            y1Position = mainRect.minY + (top > 0 ? 20 : 0)
            y2Position = mainRect.maxY - (bottom > 0 ? 20 : 0)
            yGridMap[0] = mainRect.minY
            yGridMap[Int(top)] = y1Position
            yGridMap[Int(mainSize.height - bottom)] = y2Position
            yGridMap[Int(mainSize.height)] = mainRect.maxY
        case .partialPositive:
            y2Position = mainRect.maxY + (bottom > 0 ? (componentBoxWidth / 2) : 0)
            y1Position = y2Position - componentBoxWidth
            yGridMap[0] = mainRect.minY
            yGridMap[Int(mainSize.height - top)] = y1Position
            yGridMap[Int(mainSize.height)] = mainRect.maxY
            yGridMap[Int(mainSize.height + bottom)] = y2Position
        case .positive:
            y1Position = mainRect.maxY + (bottom > 0 ? (componentBoxWidth / 2) : 0)
            y2Position = y1Position + componentBoxWidth
            yGridMap[0] = mainRect.minY
            yGridMap[Int(mainSize.height)] = mainRect.maxY
            yGridMap[Int(mainSize.height + bottom)] = y1Position
            yGridMap[Int(mainSize.height + bottom + otherSize.height)] = y2Position
        case .outside:
            y1Position = mainRect.minY - (top > 0 ? (componentBoxWidth / 2) : 0)
            y2Position = mainRect.maxY + (bottom > 0 ? (componentBoxWidth / 2) : 0)
            yGridMap[0] = y1Position
            yGridMap[Int(top)] = mainRect.minY
            yGridMap[Int(top + mainSize.height)] = mainRect.maxY
            yGridMap[Int(top + mainSize.height + bottom)] = y2Position
        }
        let otherRect = CGRect(x: x1Position, y: y1Position, width: (x2Position - x1Position), height: (y2Position - y1Position))
        return AnalyzeSpacingInfo(otherRect: otherRect, xGridMap: xGridMap, yGridMap: yGridMap)
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
            leftOffset = abs(mainBounds.maxX - otherBounds.minX)
            rightOffset = abs(mainBounds.maxX - otherBounds.maxX)
        } else {
            xIntersectType = .partialNegative
            leftOffset = abs(mainBounds.minX - otherBounds.minX)
            rightOffset = abs(mainBounds.minX - otherBounds.maxX)
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
            topOffset = abs(mainBounds.maxY - otherBounds.minY)
            bottomOffset = abs(mainBounds.maxY - otherBounds.maxY)
        } else {
            yIntersectType = .partialNegative
            topOffset = abs(mainBounds.minY - otherBounds.minY)
            bottomOffset = abs(mainBounds.minY - otherBounds.maxY)
        }
        return ComponentPositionRelation(
            xIntersectType: xIntersectType, yIntersectType: yIntersectType,
            left: leftOffset, right: rightOffset, top: topOffset, bottom: bottomOffset,
            mainSize: mainBounds.size, otherSize: otherBounds.size
        )
    }
    
}
