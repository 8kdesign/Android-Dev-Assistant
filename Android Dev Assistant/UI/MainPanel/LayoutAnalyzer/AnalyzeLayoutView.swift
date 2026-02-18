//
//  AnalyzeLayoutView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 19/2/26.
//

import SwiftUI

struct AnalyzeLayoutView: View {
    
    @EnvironmentObject var uiController: UIController
    var item: ComponentLayoutItem
    @State var imageSize: CGSize = .zero

    var body: some View {
        PopupView(title: "Read Layout") {
            if item.image.size.width < item.image.size.height {
                HStack (spacing: 0) {
                    PreviewSectionView()
                    SideControlsView()
                }
            } else {
                PreviewSectionView()
                BottomControlsView()
            }
        }
    }
    
    private func PreviewSectionView() -> some View {
        ZStack {
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
                )
                .gesture(DragGesture(minimumDistance: 0).onEnded(onSelectComponent))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Canvas { context, size in
                
            }.frame(maxWidth: imageSize.width, maxHeight: imageSize.height)
        }.padding(.all, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func SideControlsView() -> some View {
        VStack(spacing: 0) {
            ComponentListView(item: item)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
    }
    
    private func BottomControlsView() -> some View {
        HStack(spacing: 0) {
            ComponentListView(item: item)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
    }
    
}

extension AnalyzeLayoutView {
    
    func onSelectComponent(gesture: DragGesture.Value) {
        guard imageSize.width > 0, imageSize.height > 0 else { return }
        let actualXPosition = gesture.location.x / imageSize.width * item.image.size.width
        let actualYPosition = gesture.location.y / imageSize.height * item.image.size.height
        let components = item.getComponentsAtPoint(point: CGPoint(x: actualXPosition, y: actualYPosition))
    }
    
}
