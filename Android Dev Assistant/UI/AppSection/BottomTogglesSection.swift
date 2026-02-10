//
//  BottomTogglesSection.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 4/2/26.
//

import Foundation
import SwiftUI

struct BottomTogglesSection: View {
    
    @EnvironmentObject var uiController: UIController
    
    var body: some View {
        HStack {
            SettingsToggle()
            FolderToggle()
            Spacer()
        }.padding(.all)
            .frame(maxWidth: .infinity)
    }
    
    private func SettingsToggle() -> some View {
        Button {
            uiController.showingPopup = .settings
        } label: {
            Image(systemName: "gearshape.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.9)
                .frame(width: 36, height: 36)
        }.buttonStyle(.plain)
            .hoverOpacity()
    }
    
    private func FolderToggle() -> some View {
        Button {
            runOnLogicThread {
                if let path = appSupportURL?.path(percentEncoded: false) {
                    Task { @MainActor in
                        openFolder(path)
                    }
                }
            }
        } label: {
            Image(systemName: "folder.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.9)
                .frame(width: 36, height: 36)
        }.buttonStyle(.plain)
            .hoverOpacity()
    }
    
}
