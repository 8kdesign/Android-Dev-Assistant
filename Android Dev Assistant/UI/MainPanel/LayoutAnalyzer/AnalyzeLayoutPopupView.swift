//
//  AnalyzeLayoutPopupView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 24/2/26.
//

import SwiftUI

struct AnalyzeLayoutPopupView: View {
    
    @EnvironmentObject var adbHelper: AdbHelper
    @State var selectedLayoutHelper: AnalyzeScreenHelper? = nil
    @State var showMenu: Bool = false
    @State var isGettingLayout: Bool = false

    var body: some View {
        PopupView(title: "Read Layout", interceptEscape: interceptEscape) {
            if let selectedLayoutHelper {
                AnalyzeLayoutView(analyzeScreenHelper: selectedLayoutHelper, showMenu: $showMenu)
            } else {
                ControlsView()
            }
        }
    }
    
    private func ControlsView() -> some View {
        HStack(spacing: 20) {
            ControlItemView(title: "Capture New", icon: "plus.circle", action: captureNew)
            if let existingHelper = adbHelper.lastAnalyzeItemHelper {
                ControlItemView(title: "Resume Last", icon: "arrow.counterclockwise.circle") {
                    if isGettingLayout { return }
                    selectedLayoutHelper = existingHelper
                }
            }
        }.padding(.all, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func ControlItemView(
        title: LocalizedStringResource,
        icon: String,
        action: @escaping () -> ()
    ) -> some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.7)
            Text(title)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .center)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.7)
        }.frame(maxWidth: 150, maxHeight: 150)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(white: 0.15)))
            .onTapGesture {
                action()
            }.hoverOpacity()
    }
    
}

extension AnalyzeLayoutPopupView {
    
    private func interceptEscape() -> Bool {
        if showMenu {
            showMenu = false
            return true
        }
        return false
    }
    
    private func captureNew() {
        if isGettingLayout { return }
        isGettingLayout = true
        adbHelper.getLayout { item in
            selectedLayoutHelper = item
        } completionCallback: {
            isGettingLayout = false
        }
    }
    
}
