//
//  MenuGridItem.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 1/2/26.
//

import SwiftUI

struct MenuGridItem: View {
    
    var deviceId: String
    var name: LocalizedStringResource
    var icon: String
    var action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 0) {
                Text(name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.tail)
                    .opacity(0.7)
                HStack {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-30))
                        .opacity(0.2)
                        .offset(x: 20, y: 20)
                }.frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(.all)
                .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.1, green: 0.1, blue: 0.1)))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }.buttonStyle(.plain)
    }
    
}
