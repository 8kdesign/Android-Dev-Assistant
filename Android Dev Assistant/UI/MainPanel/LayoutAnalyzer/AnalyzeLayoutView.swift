//
//  AnalyzeLayoutView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 19/2/26.
//

import SwiftUI

struct AnalyzeLayoutView: View {

    @EnvironmentObject var theme: ThemeManager
    @StateObject var analyzeScreenHelper: AnalyzeScreenHelper
    @Binding var showMenu: Bool

    var body: some View {
        Group {
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
                        case .fixed(_), .temp(_):
                            ComponentInfoView()
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(theme.background)
            ComponentSelectorListView(showMenu: $showMenu)
                .opacity(showMenu ? 1 : 0)
                .allowsHitTesting(showMenu)
        }
    }

}
