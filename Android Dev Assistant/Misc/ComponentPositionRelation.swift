//
//  ComponentPositionRelation.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 21/2/26.
//

import Foundation
import SwiftUI

enum ComponentPositionRelation {
    case identical
    case nonIdentical(
        xIntersectType: AxisIntersectType,
        yIntersectType: AxisIntersectType,
        left: CGFloat,
        right: CGFloat,
        top: CGFloat,
        bottom: CGFloat
    )

    enum AxisIntersectType {
        case negative
        case partialNegative
        case inside
        case partialPositive
        case positive
        case outside
    }
    
    static func getPositionRelation(mainBounds: CGRect, otherBounds: CGRect) -> ComponentPositionRelation {
        if mainBounds == otherBounds {
            return .identical
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
        return .nonIdentical(xIntersectType: xIntersectType, yIntersectType: yIntersectType,
                          left: leftOffset, right: rightOffset, top: topOffset, bottom: bottomOffset)
    }

}
