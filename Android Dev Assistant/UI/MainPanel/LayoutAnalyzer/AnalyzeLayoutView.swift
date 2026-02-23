//
//  AnalyzeLayoutView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 19/2/26.
//

import SwiftUI

struct AnalyzeLayoutView: View {
    
    @EnvironmentObject var uiController: UIController
    @StateObject var analyzeScreenHelper: AnalyzeScreenHelper
    @State var showMenu: Bool = false
    
    var body: some View {
        PopupView(title: "Read Layout", interceptEscape: interceptEscape) {
            let imageSize = analyzeScreenHelper.layout.image.size
            if imageSize.width < imageSize.height {
                HStack (spacing: 0) {
                    AnalyzePreviewSectionView(showMenu: $showMenu)
                    ControlsView()
                }
            } else {
                AnalyzePreviewSectionView(showMenu: $showMenu)
                ControlsView()
            }
        }.environmentObject(analyzeScreenHelper)
    }

    
    private func ControlsView() -> some View {
        ZStack {
            VStack(spacing: 0) {
                if analyzeScreenHelper.layout.isLoaded {
                    VStack {
                        switch analyzeScreenHelper.selectedTab {
                        case .list:
                            ComponentListView()
                        case .fixed(_):
                            ComponentInfoView()
                        case .temp(_):
                            ComponentInfoView()
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
                .background(Color(white: 0.1))
            ComponentSelectorListView(showMenu: $showMenu)
                .opacity(showMenu ? 1 : 0)
                .allowsHitTesting(showMenu)
        }
    }
    
}

extension AnalyzeLayoutView {
    
    private func interceptEscape() -> Bool {
        if showMenu {
            showMenu = false
            return true
        }
        return false
    }
    
}
