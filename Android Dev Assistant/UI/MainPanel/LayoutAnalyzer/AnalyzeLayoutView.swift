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
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func SideControlsView() -> some View {
        VStack {
            
        }.padding(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
    }
    
    private func BottomControlsView() -> some View {
        HStack {
            
        }.padding(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
    }
    
}
