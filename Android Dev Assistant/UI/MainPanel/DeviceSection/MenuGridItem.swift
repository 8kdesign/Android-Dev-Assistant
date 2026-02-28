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
    @EnvironmentObject var theme: ThemeManager
    var name: LocalizedStringResource
    var icon: String
    var iconColor: Color
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
                    .foregroundStyle(.primary)
                    .opacity(0.7)
                    .padding(.all, 10)
                VStack {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .rotationEffect(.degrees(-30))
                        .foregroundStyle(iconColor)
                        .opacity(theme.isDarkMode ? 0.3 : 0.7)
                        .offset(x: 5, y: 5)
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }.frame(height: 80)
                .background(RoundedRectangle(cornerRadius: 10).fill(theme.backgroundTertiary))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }.buttonStyle(.plain)
            .disabled(requireAdb && isAdbDisabled())
            .opacity(requireAdb && isAdbDisabled() ? 0.3 : 1)
            .hoverOpacity(requireAdb && isAdbDisabled() ? 1 : HOVER_OPACITY)
    }

}

extension MenuGridItem {

    private func isAdbDisabled() -> Bool {
        return adbHelper.isInstalling != nil || adbHelper.selectedDevice == nil || externalToolsHelper.isExternalToolAdbBlocking
    }

}
