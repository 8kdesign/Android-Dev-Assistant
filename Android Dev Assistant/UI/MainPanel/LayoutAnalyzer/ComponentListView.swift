//
//  ComponentListView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 19/2/26.
//

import SwiftUI

struct ComponentListView: View {
    
    var item: ComponentLayoutItem
    @Binding var selectedComponent: ComponentItem?
    @State var components: [ComponentItem] = []

    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(components) { component in
                        ComponentItemView(component: component)
                            .id(component.id)
                        Divider().opacity(0.3)
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollIndicators(.never)
                .onChange(of: selectedComponent) { value in
                    reader.scrollTo(value?.id, anchor: .center)
                }
        }.onAppear {
            components = item.getOrderedComponents()
        }
    }
    
    private func ComponentItemView(component: ComponentItem) -> some View {
        Text(component.getLabel())
            .font(.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            .foregroundStyle(selectedComponent == component ? .yellow : .white)
            .foregroundColor(selectedComponent == component ? .yellow : .white)
            .padding(.all, 10)
            .background(.white.opacity(0.00001))
            .onTapGesture {
                selectedComponent = component
            }.hoverOpacity()
    }
    
}
