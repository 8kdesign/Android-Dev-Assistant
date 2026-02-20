//
//  ComponentListView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 19/2/26.
//

import SwiftUI

struct ComponentListView: View {
    
    @EnvironmentObject var analyzeScreenHelper: AnalyzeScreenHelper
    @StateObject var item: ComponentLayoutItem
    @State var components: [ComponentItem] = []
    @State var maxDepth = 0

    var body: some View {
        ScrollViewReader { reader in
            ScrollView([.horizontal,.vertical]) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(components) { component in
                        ComponentItemView(component: component)
                            .id(component.id)
                        Divider().opacity(0.3)
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollIndicators(.never)
        }.onReceive(item.$components) { value in
            components = item.getOrderedComponents(components: value)
            maxDepth = components.max(by: { $0.depth < $1.depth })?.depth ?? 0
        }
    }
    
    private func ComponentItemView(component: ComponentItem) -> some View {
        Text(component.getLabel())
            .font(.callout)
            .frame(width: 300 + CGFloat(maxDepth * 10), alignment: .leading)
            .lineLimit(1)
            .foregroundStyle(analyzeScreenHelper.selectedComponent == component ? .yellow : .white)
            .foregroundColor(analyzeScreenHelper.selectedComponent == component ? .yellow : .white)
            .padding(.all, 10)
            .background(.white.opacity(0.00001))
            .onTapGesture {
                if analyzeScreenHelper.selectedComponent == component {
                    // todo: select tab
                } else {
                    analyzeScreenHelper.selectedComponent = component
                }
            }.hoverOpacity()
    }
    
}
