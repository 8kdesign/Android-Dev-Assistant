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
            CanvasView(relation: positionRelation)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(white: 0.12))
            .onAppear {
                positionRelation = analyzeScreenHelper.compare()
            }.onChange(of: analyzeScreenHelper.compareComponent) { _ in
                positionRelation = analyzeScreenHelper.compare()
            }
    }
    
    private func CanvasView(relation: ComponentPositionRelation?) -> some View {
        Canvas { context, size in
            let mainRect = CGRect(
                origin: CGPoint(x: (size.width - COMPONENT_BOX_WIDTH) / 2, y: (size.height - COMPONENT_BOX_WIDTH) / 2),
                size: CGSize(width: COMPONENT_BOX_WIDTH, height: COMPONENT_BOX_WIDTH)
            )
            let otherRect = relation?.getOtherRect(size: size, mainRect: mainRect)
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
        
}
