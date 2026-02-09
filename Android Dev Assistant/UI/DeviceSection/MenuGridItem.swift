//
//  MenuGridItem.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 1/2/26.
//

import SwiftUI

struct MenuGridItem: View {
    
    @EnvironmentObject var adbHelper: AdbHelper
    @EnvironmentObject var externalToolsHelper: ExternalToolsHelper
    var name: LocalizedStringResource
    var icon: String
    var requireAdb: Bool
    var action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack(alignment: .top) {
                Text(name)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .opacity(0.7)
                    .padding(.all, 10)
                VStack {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-30))
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                        .opacity(0.1)
                        .offset(x: 10, y: 10)
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }.frame(height: 80)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.13, green: 0.13, blue: 0.13)))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }.buttonStyle(.plain)
            .disabled(requireAdb && isAdbDisabled())
            .opacity(requireAdb && isAdbDisabled() ? 0.3 : 1)
    }
    
}

extension MenuGridItem {
    
    private func isAdbDisabled() -> Bool {
        return adbHelper.isInstalling != nil || adbHelper.selectedDevice == nil || externalToolsHelper.isExternalToolAdbBlocking
    }
    
}
