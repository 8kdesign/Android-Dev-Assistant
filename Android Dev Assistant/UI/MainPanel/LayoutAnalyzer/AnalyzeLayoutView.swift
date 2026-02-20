//
//  AnalyzeLayoutView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 19/2/26.
//

import SwiftUI

struct AnalyzeLayoutView: View {
    
    @EnvironmentObject var uiController: UIController
    @StateObject var analyzeScreenHelper: AnalyzeScreenHelper = AnalyzeScreenHelper()
    @StateObject var item: ComponentLayoutItem
    
    var body: some View {
        PopupView(title: "Read Layout") {
            if item.image.size.width < item.image.size.height {
                HStack (spacing: 0) {
                    AnalyzePreviewSectionView(item: item)
                    ControlsView()
                }
            } else {
                AnalyzePreviewSectionView(item: item)
                ControlsView()
            }
        }.environmentObject(analyzeScreenHelper)
    }

    
    private func ControlsView() -> some View {
        VStack(spacing: 0) {
            if item.isLoaded {
                AnalyzeTabView()
                VStack {
                    switch analyzeScreenHelper.selectedTab {
                    case .list:
                        ComponentListView(item: item)
                    case .fixed(let component):
                        EmptyView()
                    case .temp(let component):
                        EmptyView()
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .accentColor(.white)
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
    }
    
}

