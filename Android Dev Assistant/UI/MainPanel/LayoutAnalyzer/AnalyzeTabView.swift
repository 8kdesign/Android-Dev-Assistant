//
//  AnalyzeTabView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 20/2/26.
//

import SwiftUI

struct AnalyzeTabView: View {

    @EnvironmentObject var analyzeScreenHelper: AnalyzeScreenHelper
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 1) {
                ForEach(analyzeScreenHelper.tabs) { tab in
                    switch tab {
                    case .list: ListTabView()
                    case .fixed(let component): FixedTabView(component: component)
                    case .temp(let component): TempTabView(component: component)
                    }
                }
            }.frame(height: 35)
                .padding([.top, .horizontal], 5)
        }.frame(height: 40)
            .frame(maxWidth: .infinity)
            .scrollIndicators(.never)
            .background(theme.backgroundTertiary)
    }

    private func ListTabView() -> some View {
        Image(systemName: "list.bullet.indent")
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundStyle(.primary)
            .padding(.horizontal)
            .frame(height:35)
            .opacity(analyzeScreenHelper.selectedTab == .list ? 1 : 0.3)
            .background(analyzeScreenHelper.selectedTab == .list ? theme.background : theme.backgroundElevated)
            .onTapGesture {
                analyzeScreenHelper.selectedTab = .list
            }.hoverOpacity()
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 5, topTrailing: 5)))
    }

    private func TempTabView(component: ComponentItem) -> some View {
        HStack{
            Image(systemName: "pin")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.primary)
                .onTapGesture {
                    analyzeScreenHelper.fixTab(tab: .temp(component: component))
                }.hoverOpacity()
            Text(component.getShortLabel())
                .font(.callout)
                .frame(maxWidth: 100, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.primary)
        }.padding(.horizontal)
            .frame(height:35)
            .opacity(analyzeScreenHelper.selectedTab == .temp(component: component) ? 1 : 0.3)
            .background(analyzeScreenHelper.selectedTab == .temp(component: component) ? theme.background : theme.backgroundElevated)
            .onTapGesture {
                analyzeScreenHelper.selectedTab = .temp(component: component)
            }.hoverOpacity()
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 5, topTrailing: 5)))
    }

    private func FixedTabView(component: ComponentItem) -> some View {
        HStack{
            Image(systemName: "pin.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.primary)
                .onTapGesture {
                    analyzeScreenHelper.unfixTab(tab: .fixed(component: component))
                }.hoverOpacity()
            Text(component.getShortLabel())
                .font(.callout)
                .frame(maxWidth: 100, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.primary)
        }.padding(.horizontal)
            .frame(height:35)
            .opacity(analyzeScreenHelper.selectedTab == .fixed(component: component) ? 1 : 0.3)
            .background(analyzeScreenHelper.selectedTab == .fixed(component: component) ? theme.background : theme.backgroundElevated)
            .onTapGesture {
                analyzeScreenHelper.selectedTab = .fixed(component: component)
            }.hoverOpacity()
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 5, topTrailing: 5)))
    }


}
