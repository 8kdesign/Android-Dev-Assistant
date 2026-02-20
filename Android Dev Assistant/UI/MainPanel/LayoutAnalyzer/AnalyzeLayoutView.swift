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
    @State var showMenu: Bool = false
    
    var body: some View {
        PopupView(title: "Read Layout") {
            if item.image.size.width < item.image.size.height {
                HStack (spacing: 0) {
                    AnalyzePreviewSectionView(item: item, showMenu: $showMenu)
                    ControlsView()
                }
            } else {
                AnalyzePreviewSectionView(item: item, showMenu: $showMenu)
                ControlsView()
            }
        }.environmentObject(analyzeScreenHelper)
    }

    
    private func ControlsView() -> some View {
        ZStack {
            VStack(spacing: 0) {
                if item.isLoaded {
                    AnalyzeTabView()
                    VStack {
                        switch analyzeScreenHelper.selectedTab {
                        case .list:
                            ComponentListView(item: item)
                        case .fixed(let component):
                            ComponentInfoView(item: component)
                        case .temp(let component):
                            ComponentInfoView(item: component)
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
            ComponentSelectorListView(showMenu: $showMenu)
                .opacity(showMenu ? 1 : 0)
                .allowsHitTesting(showMenu)
        }
    }
    
}

