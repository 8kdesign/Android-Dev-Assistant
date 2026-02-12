//
//  ToggleItemView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 13/2/26.
//

import SwiftUI

struct ToggleItemView: View {
    
    var icon: String
    var label: LocalizedStringResource
    var isLoading: Bool = false
    var isDangerous: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(x: 0.7, y: 0.7)
                        .accentColor(.white)
                        .tint(.white)
                } else {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                        .opacity(0.9)
                    Text(label)
                        .font(.caption2)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                        .opacity(0.9)
                }
            }.frame(width: 60, height: 50)
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: isDangerous ? 0.3 : 0.1, green: 0.1, blue: 0.1))
                ).opacity(0.7)
        }.buttonStyle(.plain)
            .hoverOpacity()
    }
}
