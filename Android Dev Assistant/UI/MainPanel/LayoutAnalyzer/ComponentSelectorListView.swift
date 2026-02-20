//
//  ComponentSelectorListView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 20/2/26.
//

import SwiftUI

struct ComponentSelectorListView: View {
    
    @EnvironmentObject var analyzeScreenHelper: AnalyzeScreenHelper
    @Binding var showMenu: Bool

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                Text("Select View")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .padding(.all, 15)
                    .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                Divider()
                ScrollView {
                    if showMenu {
                        LazyVStack(spacing: 0) {
                            ForEach(analyzeScreenHelper.selectedComponentList) { component in
                                ComponentListItemView(component: component)
                                Divider()
                            }
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollIndicators(.never)
            }.frame(maxWidth: .infinity, maxHeight: 300)
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onTapGesture {}
                .padding(.all, 50)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.8))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    showMenu = false
                }
            }
    }
    
    private func ComponentListItemView(component: ComponentItem) -> some View {
        Text(component.getShortLabel())
            .font(.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundStyle(.white)
            .foregroundColor(.white)
            .opacity(0.7)
            .padding(.all, 15)
            .background(.white.opacity(0.000001))
            .onTapGesture {
                analyzeScreenHelper.addTab(component: component, needSet: true)
                withAnimation(.easeInOut(duration: 0.1)) {
                    showMenu = false
                }
            }.hoverOpacity {
                analyzeScreenHelper.selectedComponent = component
            }
    }
    
}
