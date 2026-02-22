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
            .aspectRatio(1, contentMode: .fit)
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
            let info = relation?.getOtherRect(size: size, mainRect: mainRect)
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
            context.stroke(line, with: .color(Color(white: 0.3)), style: .init(lineWidth: 1))
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
                    .foregroundColor(Color(white: 0.5))
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
