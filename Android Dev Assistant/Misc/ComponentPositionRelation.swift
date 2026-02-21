//
//  ComponentPositionRelation.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 21/2/26.
//

import Foundation
import SwiftUI

enum ComponentPositionRelation {
    case noOverlap(mainBounds: CGRect, otherBounds: CGRect)
    case mainContainsOther(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat, mainSize: CGSize, otherSize: CGSize)
    case otherContainsMain(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat, mainSize: CGSize, otherSize: CGSize)
    case partialOverlapHorizontal( // start and end are outside, top and bottom are inside
        left: CGFloat,
        right: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
        mainSize: CGSize,
        otherSize: CGSize
    )
    case partialOverlapVertical( // start and end are inside, top and bottom are outside
        left: CGFloat,
        right: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
        mainSize: CGSize,
        otherSize: CGSize
    )
    case partialOverlapCorner(
        corner: Corner,
        x: CGFloat, // opposing corners x displacement
        y: CGFloat, // opposing corners y displacement
        mainSize: CGSize,
        otherSize: CGSize
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
    
    static func getPositionRelation(bounds1: CGRect, bounds2: CGRect) -> ComponentPositionRelation {
        if !bounds1.intersects(bounds2) {
            return .noOverlap(mainBounds: bounds1, otherBounds: bounds2)
        }
        let topTopDiff = bounds1.minY - bounds2.minY
        let bottomBottomDiff = bounds1.maxY - bounds2.maxY
        let leftLeftDiff = bounds1.minX - bounds2.minX
        let rightRightDiff = bounds1.maxX - bounds2.maxX
        let topBottomDiff = bounds1.minY - bounds2.maxY
        let bottomTopDiff = bounds1.maxY - bounds2.minY
        let leftRightDiff = bounds1.minX - bounds2.maxX
        let rightLeftDiff = bounds1.maxX - bounds2.minX
        
        let isLeftInside = bounds1.minX <= bounds2.minX && bounds1.maxX >= bounds2.minX
        let isRightInside = bounds1.minX <= bounds2.maxX && bounds1.maxX >= bounds2.maxX
        let isTopInside = bounds1.minY <= bounds2.minY && bounds1.maxY >= bounds2.minY
        let isBottomInside = bounds1.minY <= bounds2.maxY && bounds1.maxY >= bounds2.maxY
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
                    x: abs(isLeftCorner ? leftRightDiff : rightLeftDiff),
                    y: abs(isTopCorner ? topBottomDiff : bottomTopDiff),
                    mainSize: bounds1.size,
                    otherSize: bounds2.size
                )
            case 2: // side, top and bottom inside
                let isLeftSide = isRightInside
                return .partialOverlapSide(
                    side: isLeftSide ? .left : .right,
                    left: abs(isLeftSide ? leftLeftDiff : rightLeftDiff),
                    right: abs(isLeftSide ? leftRightDiff : rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff),
                    mainSize: bounds1.size,
                    otherSize: bounds2.size
                )
            default: // side, top and bottom outside
                let isLeftSide = isRightInside
                return .partialOverlapSide(
                    side: isLeftSide ? .left : .right,
                    left: abs(isLeftSide ? leftLeftDiff : rightLeftDiff),
                    right: abs(isLeftSide ? leftRightDiff : rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff),
                    mainSize: bounds1.size,
                    otherSize: bounds2.size
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
                    mainSize: bounds1.size,
                    otherSize: bounds2.size
                )
            case 2: // inside
                return .mainContainsOther(
                    left: abs(leftLeftDiff),
                    right: abs(rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff),
                    mainSize: bounds1.size,
                    otherSize: bounds2.size
                )
            default: // vertical
                return .partialOverlapVertical(
                    left: abs(leftLeftDiff),
                    right: abs(rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff),
                    mainSize: bounds1.size,
                    otherSize: bounds2.size
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
                    mainSize: bounds1.size,
                    otherSize: bounds2.size
                )
            case 2: // horizontal
                return .partialOverlapHorizontal(
                    left: abs(leftLeftDiff),
                    right: abs(rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff),
                    mainSize: bounds1.size,
                    otherSize: bounds2.size
                )
            default: // outside
                return .otherContainsMain(
                    left: abs(leftLeftDiff),
                    right: abs(rightRightDiff),
                    top: abs(topTopDiff),
                    bottom: abs(bottomBottomDiff),
                    mainSize: bounds1.size,
                    otherSize: bounds2.size
                )
            }
        }
    }
}
