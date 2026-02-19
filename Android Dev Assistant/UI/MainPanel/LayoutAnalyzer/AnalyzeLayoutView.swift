//
//  AnalyzeLayoutView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 19/2/26.
//

import SwiftUI

struct AnalyzeLayoutView: View {
    
    @EnvironmentObject var uiController: UIController
    @StateObject var item: ComponentLayoutItem
    @State var selectedComponent: ComponentItem? = nil
    

    var body: some View {
        PopupView(title: "Read Layout") {
            if item.image.size.width < item.image.size.height {
                HStack (spacing: 0) {
                    AnalyzePreviewSectionView(item: item, selectedComponent: $selectedComponent)
                    ControlsView()
                }
            } else {
                AnalyzePreviewSectionView(item: item, selectedComponent: $selectedComponent)
                ControlsView()
            }
        }
    }

    
    private func ControlsView() -> some View {
        VStack(spacing: 0) {
            if item.isLoaded {
                ComponentListView(item: item, selectedComponent: $selectedComponent)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .accentColor(.white)
                    .tint(.white)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
    }
    
}

