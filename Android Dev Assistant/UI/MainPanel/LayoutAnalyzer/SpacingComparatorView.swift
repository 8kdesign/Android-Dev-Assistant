//
//  SpacingComparatorView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 21/2/26.
//

import SwiftUI

struct SpacingComparatorView: View {
    
    let BOX_WIDTH: CGFloat = 70

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
            let mainRect = CGRect(
                origin: CGPoint(x: (size.width - BOX_WIDTH) / 2, y: (size.height - BOX_WIDTH) / 2),
                size: CGSize(width: BOX_WIDTH, height: BOX_WIDTH)
            )
            let otherRect = getOtherRect(size: size, mainRect: mainRect)
            drawLines(context: context, size: size, rect: mainRect)
            if let otherRect {
                drawLines(context: context, size: size, rect: otherRect)
            }
            let mainPath = Path(mainRect)
            context.fill(mainPath, with: .color(.yellow.opacity(0.3)))
            context.stroke(mainPath, with: .color(.yellow), style: .init(lineWidth: 2))
            if let otherRect {
                context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
            }
        }
    }
    
}

extension SpacingComparatorView {
    
    // Draw
    
    private func drawLines(context: GraphicsContext, size: CGSize, rect: CGRect) {
        var topLine = Path()
        topLine.move(to: CGPoint(x: 0, y: rect.minY))
        topLine.addLine(to: CGPoint(x: size.width, y: rect.minY))
        context.stroke(topLine, with: .color(Color(white: 0.2)), style: .init(lineWidth: 1))
        var bottomLine = Path()
        bottomLine.move(to: CGPoint(x: 0, y: rect.maxY))
        bottomLine.addLine(to: CGPoint(x: size.width, y: rect.maxY))
        context.stroke(bottomLine, with: .color(Color(white: 0.2)), style: .init(lineWidth: 1))
        var leftLine = Path()
        leftLine.move(to: CGPoint(x: rect.minX, y: 0))
        leftLine.addLine(to: CGPoint(x: rect.minX, y: size.height))
        context.stroke(leftLine, with: .color(Color(white: 0.2)), style: .init(lineWidth: 1))
        var rightLine = Path()
        rightLine.move(to: CGPoint(x: rect.maxX, y: 0))
        rightLine.addLine(to: CGPoint(x: rect.maxX, y: size.height))
        context.stroke(rightLine, with: .color(Color(white: 0.2)), style: .init(lineWidth: 1))
    }
    
    // Calculation
    
    private func getOtherRect(size: CGSize, mainRect: CGRect) -> CGRect? {
        switch positionRelation {
        case .noOverlap(let xIntersectType, let yIntersectType, let left, let right, let top, let bottom):
            return getNoOverlapRect(size: size, mainRect: mainRect,
                          xIntersectType: xIntersectType, yIntersectType: yIntersectType,
                          left: left, right: right, top: top, bottom: bottom)
        case .mainContainsOther(let left, let right, let top, let bottom):
            return CGRect(
                x: mainRect.minX + (left > 0 ? 20 : 0),
                y: mainRect.minY + (top > 0 ? 20 : 0),
                width: mainRect.width - (left > 0 ? 20 : 0) - (right > 0 ? 20 : 0),
                height: mainRect.height - (top > 0 ? 20 : 0) - (bottom > 0 ? 20 : 0)
            )
        case .otherContainsMain(let left, let right, let top, let bottom):
            return CGRect(
                x: mainRect.minX - (left > 0 ? (BOX_WIDTH / 2) : 0),
                y: mainRect.minY - (top > 0 ? (BOX_WIDTH / 2) : 0),
                width: mainRect.width + (left > 0 ? (BOX_WIDTH / 2) : 0) + (right > 0 ? (BOX_WIDTH / 2) : 0),
                height: mainRect.height + (top > 0 ? (BOX_WIDTH / 2) : 0) + (bottom > 0 ? (BOX_WIDTH / 2) : 0)
            )
        case .partialOverlapHorizontal(_, _, _ ,_):
            return CGRect(
                x: mainRect.minX - (BOX_WIDTH / 2),
                y: mainRect.minY + (BOX_WIDTH / 2),
                width: mainRect.width + BOX_WIDTH,
                height: mainRect.height - BOX_WIDTH
            )
        case .partialOverlapVertical(_, _, _, _):
            return CGRect(
                x: mainRect.minX + (BOX_WIDTH / 2),
                y: mainRect.minY - (BOX_WIDTH / 2),
                width: mainRect.width - BOX_WIDTH,
                height: mainRect.height + BOX_WIDTH
            )
        case .partialOverlapCorner(let corner, let left, let right, let top, let bottom):
            return getOverlapCornerRect(size: size, mainRect: mainRect, corner: corner,
                                    left: left, right: right, top: top, bottom: bottom)
        case .partialOverlapSide(let side, let left, let right, let top, let bottom, let mainSize, let otherSize):
            return getOverlapSideRect(size: size, mainRect: mainRect, side: side,
                                  left: left, right: right, top: top, bottom: bottom,
                                  mainSize: mainSize, otherSize: otherSize)
        case nil, .identical:
            return nil
        }
    }
    
    private func getNoOverlapRect(
        size: CGSize,
        mainRect: CGRect,
        xIntersectType: ComponentPositionRelation.AxisIntersectType,
        yIntersectType: ComponentPositionRelation.AxisIntersectType,
        left: CGFloat,
        right: CGFloat,
        top: CGFloat,
        bottom: CGFloat
    ) -> CGRect {
        var x1Position: CGFloat = 0
        var x2Position: CGFloat = 0
        switch xIntersectType {
        case .negative:
            x2Position = mainRect.minX - (left > 0 ? (BOX_WIDTH / 2) : 0)
            x1Position = x2Position - BOX_WIDTH
        case .partialNegative:
            x2Position = mainRect.minX + (left > 0 ? (BOX_WIDTH / 2) : 0)
            x1Position = x2Position - BOX_WIDTH
        case .inside:
            x1Position = mainRect.minX + (left > 0 ? 20 : 0)
            x2Position = mainRect.maxX - (right > 0 ? 20 : 0)
        case .partialPositive:
            x2Position = mainRect.maxX + (right > 0 ? (BOX_WIDTH / 2) : 0)
            x1Position = x2Position - BOX_WIDTH
        case .positive:
            x1Position = mainRect.maxX + (right > 0 ? (BOX_WIDTH / 2) : 0)
            x2Position = x1Position + BOX_WIDTH
        case .outside:
            x1Position = mainRect.minX - (left > 0 ? (BOX_WIDTH / 2) : 0)
            x2Position = mainRect.maxX + (right > 0 ? (BOX_WIDTH / 2) : 0)
        }
        var y1Position: CGFloat = 0
        var y2Position: CGFloat = 0
        switch yIntersectType {
        case .negative:
            y2Position = mainRect.minY - (top > 0 ? (BOX_WIDTH / 2) : 0)
            y1Position = y2Position - BOX_WIDTH
        case .partialNegative:
            y2Position = mainRect.minY + (top > 0 ? (BOX_WIDTH / 2) : 0)
            y1Position = y2Position - BOX_WIDTH
        case .inside:
            y1Position = mainRect.minY + (top > 0 ? 20 : 0)
            y2Position = mainRect.maxY - (bottom > 0 ? 20 : 0)
        case .partialPositive:
            y2Position = mainRect.maxY + (bottom > 0 ? (BOX_WIDTH / 2) : 0)
            y1Position = y2Position - BOX_WIDTH
        case .positive:
            y1Position = mainRect.maxY + (bottom > 0 ? (BOX_WIDTH / 2) : 0)
            y2Position = y1Position + BOX_WIDTH
        case .outside:
            y1Position = mainRect.minY - (top > 0 ? (BOX_WIDTH / 2) : 0)
            y2Position = mainRect.maxY + (bottom > 0 ? (BOX_WIDTH / 2) : 0)
        }
        return CGRect(x: x1Position, y: y1Position, width: (x2Position - x1Position), height: (y2Position - y1Position))
    }
    
    private func getOverlapCornerRect(
        size: CGSize,
        mainRect: CGRect,
        corner: ComponentPositionRelation.Corner,
        left: CGFloat,
        right: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
    ) -> CGRect {
        let leftPadding: CGFloat = left > 0 ? (BOX_WIDTH / 2) : 0
        let rightPadding: CGFloat = right > 0 ? (BOX_WIDTH / 2) : 0
        let topPadding: CGFloat = top > 0 ? (BOX_WIDTH / 2) : 0
        let bottomPadding: CGFloat = bottom > 0 ? (BOX_WIDTH / 2) : 0
        switch corner {
        case .topLeft:
            return CGRect(
                x: mainRect.minX - leftPadding,
                y: mainRect.minY - topPadding,
                width: mainRect.width - rightPadding + leftPadding,
                height: mainRect.height - bottomPadding + topPadding
            )
        case .topRight:
            return CGRect(
                x: mainRect.minX + leftPadding,
                y: mainRect.minY - topPadding,
                width: mainRect.width + rightPadding - leftPadding,
                height: mainRect.height - bottomPadding + topPadding
            )
        case .bottomLeft:
            return CGRect(
                x: mainRect.minX - leftPadding,
                y: mainRect.minY + topPadding,
                width: mainRect.width - rightPadding + leftPadding,
                height: mainRect.height + bottomPadding - topPadding
            )
        case .bottomRight:
            return CGRect(
                x: mainRect.minX + leftPadding,
                y: mainRect.minY + topPadding,
                width: mainRect.width + rightPadding - leftPadding,
                height: mainRect.height + bottomPadding - topPadding
            )
        }
    }
    
    private func getOverlapSideRect(
        size: CGSize,
        mainRect: CGRect,
        side: ComponentPositionRelation.Side,
        left: CGFloat, // if side is top/bottom, check width to determine if inner/outer
        right: CGFloat, // if side is top/bottom, check width to determine if inner/outer
        top: CGFloat, // if side is left/right, check height to determine if inner/outer
        bottom: CGFloat, // if side is left/right, check height to determine if inner/outer
        mainSize: CGSize,
        otherSize: CGSize
    ) -> CGRect {
        switch side {
        case .left:
            let topOffset: CGFloat = top > 0 ? mainSize.height > otherSize.height ? (BOX_WIDTH / 2) : -(BOX_WIDTH / 2)  : 0
            let bottomOffset: CGFloat = bottom > 0 ? mainSize.height > otherSize.height ? -(BOX_WIDTH / 2) : (BOX_WIDTH / 2) : 0
            return CGRect(
                x: mainRect.minX - (BOX_WIDTH / 2),
                y: mainRect.minY + topOffset,
                width: BOX_WIDTH,
                height: mainRect.height - topOffset + bottomOffset
            )
        case .right:
            let topOffset: CGFloat = top > 0 ? mainSize.height > otherSize.height ? (BOX_WIDTH / 2) : -(BOX_WIDTH / 2)  : 0
            let bottomOffset: CGFloat = bottom > 0 ? mainSize.height > otherSize.height ? -(BOX_WIDTH / 2) : (BOX_WIDTH / 2) : 0
            return CGRect(
                x: mainRect.maxX - (BOX_WIDTH / 2),
                y: mainRect.minY + topOffset,
                width: BOX_WIDTH,
                height: mainRect.height - topOffset + bottomOffset
            )
        case .top:
            let leftOffset: CGFloat = left > 0 ? mainSize.width > otherSize.width ? (BOX_WIDTH / 2) : -(BOX_WIDTH / 2)  : 0
            let rightOffset: CGFloat = right > 0 ? mainSize.width > otherSize.width ? -(BOX_WIDTH / 2) : (BOX_WIDTH / 2) : 0
            return CGRect(
                x: mainRect.minX + leftOffset,
                y: mainRect.minY - (BOX_WIDTH / 2),
                width: mainRect.width - leftOffset + rightOffset,
                height: BOX_WIDTH
            )
        case .bottom:
            let leftOffset: CGFloat = left > 0 ? mainSize.width > otherSize.width ? (BOX_WIDTH / 2) : -(BOX_WIDTH / 2)  : 0
            let rightOffset: CGFloat = right > 0 ? mainSize.width > otherSize.width ? -(BOX_WIDTH / 2) : (BOX_WIDTH / 2) : 0
            return CGRect(
                x: mainRect.minX + leftOffset,
                y: mainRect.maxY - (BOX_WIDTH / 2),
                width: mainRect.width - leftOffset + rightOffset,
                height: BOX_WIDTH
            )
        }
    }
    
}
