//
//  SpacingComparatorView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 21/2/26.
//

import SwiftUI

struct SpacingComparatorView: View {
    
    @EnvironmentObject var analyzeScreenHelper: AnalyzeScreenHelper
    @State var positionRelation: ComponentPositionRelation? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            CanvasView()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(white: 0.12))
            .onChange(of: analyzeScreenHelper.compareComponent) { _ in
                positionRelation = analyzeScreenHelper.compare()
            }
    }
    
    private func CanvasView() -> some View {
        Canvas { context, size in
            let mainSize = getMainSize()
            let mainRect = CGRect(
                origin: CGPoint(x: (size.width - mainSize) / 2, y: (size.height - mainSize) / 2),
                size: CGSize(width: mainSize, height: mainSize)
            )
            let mainPath = Path(mainRect)
            context.fill(mainPath, with: .color(.yellow.opacity(0.3)))
            context.stroke(mainPath, with: .color(.yellow), style: .init(lineWidth: 2))
            switch positionRelation {
            case .noOverlap(let xIntersectType, let yIntersectType, let left, let right, let top, let bottom):
                drawNoOverlap(context: context, size: size, mainRect: mainRect,
                              xIntersectType: xIntersectType, yIntersectType: yIntersectType,
                              left: left, right: right, top: top, bottom: bottom)
            case .mainContainsOther(let left, let right, let top, let bottom):
                let otherRect = CGRect(
                    x: mainRect.minX + (left > 0 ? 50 : 0),
                    y: mainRect.minY + (top > 0 ? 50 : 0),
                    width: mainRect.width - (left > 0 ? 50 : 0) - (right > 0 ? 50 : 0),
                    height: mainRect.height - (top > 0 ? 50 : 0) - (bottom > 0 ? 50 : 0)
                )
                context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
            case .otherContainsMain(let left, let right, let top, let bottom):
                let otherRect = CGRect(
                    x: mainRect.minX - (left > 0 ? 50 : 0),
                    y: mainRect.minY - (top > 0 ? 50 : 0),
                    width: mainRect.width + (left > 0 ? 50 : 0) + (right > 0 ? 50 : 0),
                    height: mainRect.height + (top > 0 ? 50 : 0) + (bottom > 0 ? 50 : 0)
                )
                context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
            case .partialOverlapHorizontal(let left, let right, let top, let bottom):
                let otherRect = CGRect(
                    x: mainRect.minX - 50,
                    y: mainRect.minY + 50,
                    width: mainRect.width + 100,
                    height: mainRect.height - 100
                )
                context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
            case .partialOverlapVertical(let left, let right, let top, let bottom):
                let otherRect = CGRect(
                    x: mainRect.minX + 50,
                    y: mainRect.minY - 50,
                    width: mainRect.width - 100,
                    height: mainRect.height + 100
                )
                context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
            case .partialOverlapCorner(let corner, let left, let right, let top, let bottom):
                drawCanvasOverlapCorner(context: context, size: size, mainRect: mainRect, corner: corner,
                                        left: left, right: right, top: top, bottom: bottom)
            case .partialOverlapSide(let side, let left, let right, let top, let bottom, let mainSize, let otherSize):
                drawCanvasOverlapSide(context: context, size: size, mainRect: mainRect, side: side,
                                      left: left, right: right, top: top, bottom: bottom,
                                      mainSize: mainSize, otherSize: otherSize)
            case nil, .identical:
                ()
            }
        }
    }
    
}

extension SpacingComparatorView {
    
    private func getMainSize() -> CGFloat {
        if positionRelation == nil {
            return 140
        } else if case .identical = positionRelation {
            return 140
        } else if case .otherContainsMain(_, _, _, _) = positionRelation {
            return 70
        } else if case .noOverlap(_, _, _, _, _, _) = positionRelation {
            return 70
        } else {
            return 200
        }
    }
    
    private func drawNoOverlap(
        context: GraphicsContext,
        size: CGSize,
        mainRect: CGRect,
        xIntersectType: ComponentPositionRelation.AxisIntersectType,
        yIntersectType: ComponentPositionRelation.AxisIntersectType,
        left: CGFloat,
        right: CGFloat,
        top: CGFloat,
        bottom: CGFloat
    ) {
        let otherWidth: CGFloat = 70
        var x1Position: CGFloat = 0
        var x2Position: CGFloat = 0
        switch xIntersectType {
        case .negative:
            x2Position = mainRect.minX - (left > 0 ? 40 : 0)
            x1Position = x2Position - otherWidth
        case .partialNegative:
            x2Position = mainRect.minX + (left > 0 ? 40 : 0)
            x1Position = x2Position - otherWidth
        case .inside:
            x1Position = mainRect.minX + (left > 0 ? 20 : 0)
            x2Position = mainRect.maxX - (right > 0 ? 20 : 0)
        case .partialPositive:
            x2Position = mainRect.maxX + (right > 0 ? 40 : 0)
            x1Position = x2Position - otherWidth
        case .positive:
            x1Position = mainRect.maxX + (right > 0 ? 40 : 0)
            x2Position = x1Position + otherWidth
        case .outside:
            x1Position = mainRect.minX - (left > 0 ? 20 : 0)
            x2Position = mainRect.maxX + (right > 0 ? 20 : 0)
        }
        var y1Position: CGFloat = 0
        var y2Position: CGFloat = 0
        switch yIntersectType {
        case .negative:
            y2Position = mainRect.minY - (top > 0 ? 40 : 0)
            y1Position = y2Position - otherWidth
        case .partialNegative:
            y2Position = mainRect.minY + (top > 0 ? 40 : 0)
            y1Position = y2Position - otherWidth
        case .inside:
            y1Position = mainRect.minY + (top > 0 ? 20 : 0)
            y2Position = mainRect.maxY - (bottom > 0 ? 20 : 0)
        case .partialPositive:
            y2Position = mainRect.maxY + (bottom > 0 ? 40 : 0)
            y1Position = y2Position - otherWidth
        case .positive:
            y1Position = mainRect.maxY + (bottom > 0 ? 40 : 0)
            y2Position = y1Position + otherWidth
        case .outside:
            y1Position = mainRect.minY - (top > 0 ? 20 : 0)
            y2Position = mainRect.maxY + (bottom > 0 ? 20 : 0)
        }
        let rect = CGRect(x: x1Position, y: y1Position, width: (x2Position - x1Position), height: (y2Position - y1Position))
        context.stroke(Path(rect), with: .color(.red), style: .init(lineWidth: 2))
    }
    
    private func drawCanvasOverlapCorner(
        context: GraphicsContext,
        size: CGSize,
        mainRect: CGRect,
        corner: ComponentPositionRelation.Corner,
        left: CGFloat,
        right: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
    ) {
        let leftPadding: CGFloat = left > 0 ? 50 : 0
        let rightPadding: CGFloat = right > 0 ? 50 : 0
        let topPadding: CGFloat = top > 0 ? 50 : 0
        let bottomPadding: CGFloat = bottom > 0 ? 50 : 0
        switch corner {
        case .topLeft:
            let otherRect = CGRect(
                x: mainRect.minX - leftPadding,
                y: mainRect.minY - topPadding,
                width: mainRect.width - rightPadding + leftPadding,
                height: mainRect.height - bottomPadding + topPadding
            )
            context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
        case .topRight:
            let otherRect = CGRect(
                x: mainRect.minX + leftPadding,
                y: mainRect.minY - topPadding,
                width: mainRect.width + rightPadding - leftPadding,
                height: mainRect.height - bottomPadding + topPadding
            )
            context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
        case .bottomLeft:
            let otherRect = CGRect(
                x: mainRect.minX - leftPadding,
                y: mainRect.minY + topPadding,
                width: mainRect.width - rightPadding + leftPadding,
                height: mainRect.height + bottomPadding - topPadding
            )
            context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
        case .bottomRight:
            let otherRect = CGRect(
                x: mainRect.minX + leftPadding,
                y: mainRect.minY + topPadding,
                width: mainRect.width + rightPadding - leftPadding,
                height: mainRect.height + bottomPadding - topPadding
            )
            context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
        }
    }
    
    private func drawCanvasOverlapSide(
        context: GraphicsContext,
        size: CGSize,
        mainRect: CGRect,
        side: ComponentPositionRelation.Side,
        left: CGFloat, // if side is top/bottom, check width to determine if inner/outer
        right: CGFloat, // if side is top/bottom, check width to determine if inner/outer
        top: CGFloat, // if side is left/right, check height to determine if inner/outer
        bottom: CGFloat, // if side is left/right, check height to determine if inner/outer
        mainSize: CGSize,
        otherSize: CGSize
    ) {
        switch side {
        case .left:
            let topOffset: CGFloat = top > 0 ? mainSize.height > otherSize.height ? 50 : -50  : 0
            let bottomOffset: CGFloat = bottom > 0 ? mainSize.height > otherSize.height ? -50 : 50 : 0
            let otherRect = CGRect(
                x: mainRect.minX - 50,
                y: mainRect.minY + topOffset,
                width: 100,
                height: mainRect.height - topOffset + bottomOffset
            )
            context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
        case .right:
            let topOffset: CGFloat = top > 0 ? mainSize.height > otherSize.height ? 50 : -50  : 0
            let bottomOffset: CGFloat = bottom > 0 ? mainSize.height > otherSize.height ? -50 : 50 : 0
            let otherRect = CGRect(
                x: mainRect.maxX - 50,
                y: mainRect.minY + topOffset,
                width: 100,
                height: mainRect.height - topOffset + bottomOffset
            )
            context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
        case .top:
            let leftOffset: CGFloat = left > 0 ? mainSize.width > otherSize.width ? 50 : -50  : 0
            let rightOffset: CGFloat = right > 0 ? mainSize.width > otherSize.width ? -50 : 50 : 0
            let otherRect = CGRect(
                x: mainRect.minX + leftOffset,
                y: mainRect.minY - 50,
                width: mainRect.width - leftOffset + rightOffset,
                height: 100
            )
            context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
        case .bottom:
            let leftOffset: CGFloat = left > 0 ? mainSize.width > otherSize.width ? 50 : -50  : 0
            let rightOffset: CGFloat = right > 0 ? mainSize.width > otherSize.width ? -50 : 50 : 0
            let otherRect = CGRect(
                x: mainRect.maxX + leftOffset,
                y: mainRect.minY - 50,
                width: mainRect.width - leftOffset + rightOffset,
                height: 100
            )
            context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
        }
    }
    
}
