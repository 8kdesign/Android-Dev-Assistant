//
//  SpacingComparatorView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 21/2/26.
//

import SwiftUI

struct SpacingComparatorView: View {
    
    @EnvironmentObject var analyzeScreenHelper: AnalyzeScreenHelper
    @EnvironmentObject var theme: ThemeManager
    @State var positionRelation: ComponentPositionRelation? = nil
    
    var body: some View {
        CanvasView(relation: positionRelation)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(theme.backgroundElevated)
            .onAppear {
                positionRelation = analyzeScreenHelper.compare()
            }.onChange(of: analyzeScreenHelper.compareComponent) { _ in
                positionRelation = analyzeScreenHelper.compare()
            }
    }
    
    private func CanvasView(relation: ComponentPositionRelation?) -> some View {
        Canvas { context, size in
            let componentBoxWidth = size.width / 5
            let mainRect = CGRect(
                origin: CGPoint(x: (size.width - componentBoxWidth) / 2, y: (size.height - componentBoxWidth) / 2),
                size: CGSize(width: componentBoxWidth, height: componentBoxWidth)
            )
            let info = relation?.getOtherRect(size: size, mainRect: mainRect, componentBoxWidth: componentBoxWidth)
            if let info {
                drawLines(context: &context, size: size, lines: info.xGridMap, isX: true)
                drawLines(context: &context, size: size, lines: info.yGridMap, isX: false)
            }
            let mainPath = Path(mainRect)
            context.fill(mainPath, with: .color(.yellow.opacity(0.3)))
            context.stroke(mainPath, with: .color(.yellow), style: .init(lineWidth: 2))
            if let otherRect = info?.otherRect {
                context.stroke(Path(otherRect), with: .color(.red), style: .init(lineWidth: 2))
            }
        }
    }
    
}

extension SpacingComparatorView {
    
    // Draw
    
    private func drawLines(context: inout GraphicsContext, size: CGSize, lines: [Int: CGFloat], isX: Bool) {
        let keys = lines.keys.sorted()
        if isX {
            context.translateBy(x: 0, y: size.height)
            context.rotate(by: .degrees(-90))
        }
        let sideSize = isX ? size.height : size.width
        let density = analyzeScreenHelper.layout.density
        for index in keys.indices {
            guard let key = keys[safe: index], let value = lines[key] else { continue }
            var line = Path()
            line.move(to: CGPoint(x: 0, y: value))
            line.addLine(to: CGPoint(x: sideSize, y: value))
            context.stroke(line, with: .color(theme.gridLine), style: .init(lineWidth: 1))
            if let nextKey = keys[safe: index + 1] {
                var message = ""
                if let density {
                    let dp = CGFloat(nextKey - key) / density
                    message = String(format: "%.1f", dp)
                } else {
                    message = "\(nextKey - key)"
                }
                let text = Text(message)
                    .font(.caption)
                    .foregroundColor(theme.gridText)
                if isX {
                    context.draw(
                        text,
                        at: CGPoint(x: 5, y: value + 5),
                        anchor: .topLeading
                    )
                } else {
                    context.draw(
                        text,
                        at: CGPoint(x: sideSize - 5, y: value + 5),
                        anchor: .topTrailing
                    )
                }
            }
        }
        if isX {
            context.rotate(by: .degrees(90))
            context.translateBy(x: 0, y: -size.height)
        }
    }
        
}
