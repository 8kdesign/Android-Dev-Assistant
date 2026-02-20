//
//  AnalyzePreviewSectionView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 20/2/26.
//

import SwiftUI

struct AnalyzePreviewSectionView: View {
    
    @EnvironmentObject var analyzeScreenHelper: AnalyzeScreenHelper
    var item: ComponentLayoutItem
    @State var imageSize: CGSize = .zero
    @State var showMenu: Bool = false
    @State var nonAnimatedShowMenu: Bool = false
    @State var selectedComponentList: [ComponentItem] = []
    @State var highlightComponents: [ComponentItem] = []

    var body: some View {
        ZStack {
            ImageView()
            CanvasView()
            ComponentSelectorListView()
                .opacity(showMenu ? 1 : 0)
                .allowsHitTesting(showMenu)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: analyzeScreenHelper.selectedComponent) { value in
                if let value {
                    highlightComponents = item.getHighlightComponents(parent: value)
                }
            }
    }
    
    private func ImageView() -> some View {
        Image(nsImage: item.image)
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
                    if selectedComponentList.isEmpty { return }
                    nonAnimatedShowMenu = true
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
                let scale = (size.width - 40) / max(1, item.image.size.width)
                let x = bounds.minX * scale + 20
                let y = bounds.minY * scale + 20
                let width = bounds.width * scale
                let height = bounds.height * scale
                let scaledRect = CGRect(x: x, y: y, width: width, height: height)
                context.stroke(Path(scaledRect), with: .color(.yellow), style: .init(lineWidth: 2))
            }
        }.frame(maxWidth: imageSize.width + 40, maxHeight: imageSize.height + 40)
            .allowsHitTesting(false)
    }
    
    private func ComponentSelectorListView() -> some View {
        VStack {
            VStack(spacing: 0) {
                Text("Select View")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .padding(.all, 15)
                    .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                Divider()
                ScrollView {
                    if nonAnimatedShowMenu {
                        LazyVStack(spacing: 0) {
                            ForEach(selectedComponentList) { component in
                                ComponentListItemView(component: component)
                                Divider()
                            }
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollIndicators(.never)
            }.frame(maxWidth: .infinity, maxHeight: 300)
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onTapGesture {}
                .padding(.all, 50)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.8))
            .onTapGesture {
                nonAnimatedShowMenu = false
                withAnimation(.easeInOut(duration: 0.1)) {
                    showMenu = false
                }
            }
    }
    
    private func ComponentListItemView(component: ComponentItem) -> some View {
        Text(component.getShortLabel())
            .font(.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundStyle(.white)
            .foregroundColor(.white)
            .opacity(0.7)
            .padding(.all, 15)
            .background(.white.opacity(0.000001))
            .onTapGesture {
                analyzeScreenHelper.addTab(component: component, needSet: true)
                nonAnimatedShowMenu = false
                withAnimation(.easeInOut(duration: 0.1)) {
                    showMenu = false
                }
            }.hoverOpacity()
    }
    
}

extension AnalyzePreviewSectionView {
    
    func onSelectComponent(point: CGPoint) {
        guard imageSize.width > 0, imageSize.height > 0 else { return }
        let actualXPosition = point.x / imageSize.width * item.image.size.width
        let actualYPosition = point.y / imageSize.height * item.image.size.height
        let components = item.getComponentsAtPoint(point: CGPoint(x: actualXPosition, y: actualYPosition))
        selectedComponentList = components.reversed()
        analyzeScreenHelper.addTab(component: components.last, needSet: true)
    }
    
}
