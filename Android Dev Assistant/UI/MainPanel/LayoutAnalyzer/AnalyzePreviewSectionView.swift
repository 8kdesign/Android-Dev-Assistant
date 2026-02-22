//
//  AnalyzePreviewSectionView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 20/2/26.
//

import SwiftUI

struct AnalyzePreviewSectionView: View {
    
    @EnvironmentObject var analyzeScreenHelper: AnalyzeScreenHelper
    @Binding var showMenu: Bool
    @State var imageSize: CGSize = .zero
    @State var highlightComponents: [ComponentItem] = []

    var body: some View {
        ZStack {
            ImageView()
            CanvasView()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: analyzeScreenHelper.selectedComponent) { value in
                if let value {
                    highlightComponents = analyzeScreenHelper.layout.getHighlightComponents(parent: value)
                }
            }
    }
    
    private func ImageView() -> some View {
        Image(nsImage: analyzeScreenHelper.layout.image)
            .resizable()
            .scaledToFit()
            .background(
                GeometryReader { reader in
                    Color.clear
                       .onAppear {
                           imageSize = reader.size
                       }.onChange(of: reader.size) { size in
                           imageSize = reader.size
                       }
                }
            ).overlay {
                RightClickView { point in
                    onSelectComponent(point: point)
                    if analyzeScreenHelper.selectedComponentList.isEmpty { return }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showMenu = true
                    }
                }
            }.gesture(DragGesture(minimumDistance: 0).onEnded { value in
                onSelectComponent(point: value.location)
            }).frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.all, 20)
    }
    
    private func CanvasView() -> some View {
        Canvas { context, size in
            highlightComponents.forEach { component in
                let bounds = component.bounds
                let scale = (size.width - 40) / max(1, analyzeScreenHelper.layout.image.size.width)
                let x = bounds.minX * scale + 20
                let y = bounds.minY * scale + 20
                let width = bounds.width * scale
                let height = bounds.height * scale
                let scaledRect = CGRect(x: x, y: y, width: width, height: height)
                let isSelectedComponent = component == analyzeScreenHelper.selectedComponent
                context.stroke(Path(scaledRect), with: .color(.yellow.opacity(isSelectedComponent ? 1 : 0.5)), style: .init(lineWidth: isSelectedComponent ? 2 : 1))
            }
            if let component = analyzeScreenHelper.compareComponent {
                let bounds = component.bounds
                let scale = (size.width - 40) / max(1, analyzeScreenHelper.layout.image.size.width)
                let x = bounds.minX * scale + 20
                let y = bounds.minY * scale + 20
                let width = bounds.width * scale
                let height = bounds.height * scale
                let scaledRect = CGRect(x: x, y: y, width: width, height: height)
                context.stroke(Path(scaledRect), with: .color(.red), style: .init(lineWidth: 2))
            }
        }.frame(maxWidth: imageSize.width + 40, maxHeight: imageSize.height + 40)
            .allowsHitTesting(false)
    }
    
}

extension AnalyzePreviewSectionView {
    
    func onSelectComponent(point: CGPoint) {
        guard imageSize.width > 0, imageSize.height > 0 else { return }
        if showMenu {
            withAnimation(.easeInOut(duration: 0.1)) {
                showMenu = false
            }
        }
        let actualImageSize = analyzeScreenHelper.layout.image.size
        let actualXPosition = point.x / imageSize.width * actualImageSize.width
        let actualYPosition = point.y / imageSize.height * actualImageSize.height
        let components = analyzeScreenHelper.layout.getComponentsAtPoint(point: CGPoint(x: actualXPosition, y: actualYPosition))
        analyzeScreenHelper.selectedComponentList = components.reversed()
        if NSEvent.modifierFlags.contains(.shift), analyzeScreenHelper.selectedComponent != nil {
            analyzeScreenHelper.compareComponent = components.last
        } else {
            analyzeScreenHelper.addTab(component: components.last, needSet: true)
        }
    }
    
}
