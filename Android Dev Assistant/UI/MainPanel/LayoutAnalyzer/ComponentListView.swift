//
//  ComponentListView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 19/2/26.
//

import SwiftUI

struct ComponentListView: View {
    
    var item: ComponentLayoutItem
    @State var components: [ComponentItem] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(components) { component in
                    ComponentItemView(component: component)
                    Divider().opacity(0.3)
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollIndicators(.never)
            .onAppear {
                components = item.getOrderedComponents()
            }
    }
    
    private func ComponentItemView(component: ComponentItem) -> some View {
        Text(component.getLabel())
            .font(.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            .foregroundStyle(.white)
            .foregroundColor(.white)
            .padding(.all, 10)
    }
    
}
