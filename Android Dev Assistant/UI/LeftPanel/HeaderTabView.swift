//
//  HeaderTabView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 12/2/26.
//

import SwiftUI

struct HeaderTabView: View {

    @EnvironmentObject var theme: ThemeManager
    @Binding var isRepoTab: Bool

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "smartphone")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.primary)
                .padding(.vertical, 12)
                .padding(.horizontal, 22)
                .background(Capsule().fill(isRepoTab ? .primary.opacity(0.00001) : theme.surfaceHighlighted))
                .onTapGesture {
                    isRepoTab = false
                }.hoverOpacity()
            Image(systemName: "text.word.spacing")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.primary)
                .padding(.vertical, 12)
                .padding(.horizontal, 22)
                .background(Capsule().fill(isRepoTab ? theme.surfaceHighlighted : .primary.opacity(0.00001)))
                .onTapGesture {
                    isRepoTab = true
                }.hoverOpacity()
        }.background(Capsule().fill(theme.backgroundInput))
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: isRepoTab) { value in
                UserDefaultsHelper.setLastSelectedTab(value)
            }
    }
}
