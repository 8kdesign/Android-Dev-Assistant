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
    case noOverlap(
        xIntersectType: AxisIntersectType,
        yIntersectType: AxisIntersectType,
        left: CGFloat,
        right: CGFloat,
        top: CGFloat,
        bottom: CGFloat
    )
    case mainContainsOther(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat)
    case otherContainsMain(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat)
    case partialOverlapHorizontal( // start and end are outside, top and bottom are inside
        left: CGFloat,
        right: CGFloat,
        top: CGFloat,
        bottom: CGFloat
    )
    case partialOverlapVertical( // start and end are inside, top and bottom are outside
        left: CGFloat,
        right: CGFloat,
        top: CGFloat,
        bottom: CGFloat
    )
    case partialOverlapCorner(
        corner: Corner,
        left: CGFloat,
        right: CGFloat,
        top: CGFloat,
        bottom: CGFloat
    )
    case partialOverlapSide(
        side: Side,
        left: CGFloat, // if side is top/bottom, check width to determine if inner/outer
        right: CGFloat, // if side is top/bottom, check width to determine if inner/outer
        top: CGFloat, // if side is left/right, check height to determine if inner/outer
        bottom: CGFloat, // if side is left/right, check height to determine if inner/outer
        mainSize: CGSize,
        otherSize: CGSize
    )
    
    enum AxisIntersectType {
        case negative
        case partialNegative
        case inside
        case partialPositive
        case positive
        case outside
    }
    
    enum Corner {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    enum Side {
        case left
        case right
        case top
        case bottom
    }
    
    static func getPositionRelation(mainBounds: CGRect, otherBounds: CGRect) -> ComponentPositionRelation {
        if mainBounds == otherBounds {
            return .identical
        }
        if !mainBounds.intersects(otherBounds) {
            return processNonIntersecting(mainBounds: mainBounds, otherBounds: otherBounds)
        }
        return processIntersecting(mainBounds: mainBounds, otherBounds: otherBounds)
    }
    
    private static func processNonIntersecting(mainBounds: CGRect, otherBounds: CGRect) -> ComponentPositionRelation {
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
        } else if mainBounds.minY > otherBounds.minY && mainBounds.maxY < otherBounds.maxY {
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
        return .noOverlap(xIntersectType: xIntersectType, yIntersectType: yIntersectType,
                          left: leftOffset, right: rightOffset, top: topOffset, bottom: bottomOffset)
    }

    private static func processIntersecting(mainBounds: CGRect, otherBounds: CGRect) -> ComponentPositionRelation {
        let topTopDiff = mainBounds.minY - otherBounds.minY
        let bottomBottomDiff = mainBounds.maxY - otherBounds.maxY
        let leftLeftDiff = mainBounds.minX - otherBounds.minX
        let rightRightDiff = mainBounds.maxX - otherBounds.maxX
        if mainBounds.contains(otherBounds) {
            return .mainContainsOther(
                left: abs(leftLeftDiff),
                right: abs(rightRightDiff),
                top: abs(topTopDiff),
                bottom: abs(bottomBottomDiff)
            )
        }
        if otherBounds.contains(mainBounds) {
            return .otherContainsMain(
                left: abs(leftLeftDiff),
                right: abs(rightRightDiff),
                top: abs(topTopDiff),
                bottom: abs(bottomBottomDiff)
            )
        }
        
        let topBottomDiff = mainBounds.minY - otherBounds.maxY
        let bottomTopDiff = mainBounds.maxY - otherBounds.minY
        let leftRightDiff = mainBounds.minX - otherBounds.maxX
        let rightLeftDiff = mainBounds.maxX - otherBounds.minX
        
        let isLeftInside = mainBounds.minX <= otherBounds.minX && mainBounds.maxX >= otherBounds.minX
        let isRightInside = mainBounds.minX <= otherBounds.maxX && mainBounds.maxX >= otherBounds.maxX
        let isTopInside = mainBounds.minY <= otherBounds.minY && mainBounds.maxY >= otherBounds.minY
        let isBottomInside = mainBounds.minY <= otherBounds.maxY && mainBounds.maxY >= otherBounds.maxY
        var horizontalInsideCount = 0
        var verticalInsideCount = 0
        if isLeftInside { horizontalInsideCount += 1 }
        if isRightInside { horizontalInsideCount += 1 }
        if isTopInside { verticalInsideCount += 1 }
        if isBottomInside { verticalInsideCount += 1 }
        
        if horizontalInsideCount == 1 {
            switch verticalInsideCount {
            case 1: // corner
                let isLeftCorner = isRightInside
                let isTopCorner = isBottomInside
                let corner: Corner = isLeftCorner ? isTopCorner ? .topLeft : .bottomLeft : isTopCorner ? .topRight : .bottomRight
                return .partialOverlapCorner(
                    corner: corner,
                    left: abs(leftLeftDiff),
                    right: abs(rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff)
                )
            case 2: // side, top and bottom inside
                let isLeftSide = isRightInside
                return .partialOverlapSide(
                    side: isLeftSide ? .left : .right,
                    left: abs(isLeftSide ? leftLeftDiff : rightLeftDiff),
                    right: abs(isLeftSide ? leftRightDiff : rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff),
                    mainSize: mainBounds.size,
                    otherSize: otherBounds.size
                )
            default: // side, top and bottom outside
                let isLeftSide = isRightInside
                return .partialOverlapSide(
                    side: isLeftSide ? .left : .right,
                    left: abs(isLeftSide ? leftLeftDiff : rightLeftDiff),
                    right: abs(isLeftSide ? leftRightDiff : rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff),
                    mainSize: mainBounds.size,
                    otherSize: otherBounds.size
                )
            }
        } else if horizontalInsideCount == 2 {
            switch verticalInsideCount {
            case 1: // side, left and right inside
                let isTopSide = isBottomInside
                return .partialOverlapSide(
                    side: isTopSide ? .top : .bottom,
                    left: abs(leftLeftDiff),
                    right: abs(rightRightDiff),
                    top: abs(isTopSide ? topTopDiff : bottomTopDiff),
                    bottom: abs(isTopSide ? topBottomDiff : bottomBottomDiff),
                    mainSize: mainBounds.size,
                    otherSize: otherBounds.size
                )
            case 2: // inside (should have been caught earlier)
                return .mainContainsOther(
                    left: abs(leftLeftDiff),
                    right: abs(rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff)
                )
            default: // vertical
                return .partialOverlapVertical(
                    left: abs(leftLeftDiff),
                    right: abs(rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff)
                )
            }
        } else {
            switch verticalInsideCount {
            case 1: // side, left and right outside
                let isTopSide = isBottomInside
                return .partialOverlapSide(
                    side: isTopSide ? .top : .bottom,
                    left: abs(leftLeftDiff),
                    right: abs(rightRightDiff),
                    top: abs(isTopSide ? topTopDiff : bottomTopDiff),
                    bottom: abs(isTopSide ? topBottomDiff : bottomBottomDiff),
                    mainSize: mainBounds.size,
                    otherSize: otherBounds.size
                )
            case 2: // horizontal
                return .partialOverlapHorizontal(
                    left: abs(leftLeftDiff),
                    right: abs(rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff)
                )
            default: // outside (should have been caught earlier)
                return .otherContainsMain(
                    left: abs(leftLeftDiff),
                    right: abs(rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff)
                )
            }
        }
    }
}
