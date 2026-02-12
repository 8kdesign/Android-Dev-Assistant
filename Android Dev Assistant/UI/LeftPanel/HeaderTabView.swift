//
//  HeaderTabView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 12/2/26.
//

import SwiftUI

struct HeaderTabView: View {
    
    @Binding var isDeviceTab: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "smartphone")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 22)
                .background(Capsule().fill(isDeviceTab ? Color(red: 0.15, green: 0.15, blue: 0.15) : .white.opacity(0.00001)))
                .onTapGesture {
                    isDeviceTab = true
                }.hoverOpacity()
            Image(systemName: "text.word.spacing")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 22)
                .background(Capsule().fill(isDeviceTab ? .white.opacity(0.00001) : Color(red: 0.15, green: 0.15, blue: 0.15)))
                .onTapGesture {
                    isDeviceTab = false
                }.hoverOpacity()
        }.background(Capsule().fill(Color(red: 0.1, green: 0.1, blue: 0.1)))
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
