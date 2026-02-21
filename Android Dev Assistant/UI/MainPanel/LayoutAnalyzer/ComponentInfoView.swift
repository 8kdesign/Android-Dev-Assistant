//
//  ComponentInfoView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 20/2/26.
//

import SwiftUI

struct ComponentInfoView: View {
    
    @EnvironmentObject var toastHelper: ToastHelper
    @EnvironmentObject var analyzeScreenHelper: AnalyzeScreenHelper
    @State var component: ComponentItem? = nil
    @State var parentComponent: ComponentItem? = nil
    @State var childrenComponents: [ComponentItem] = []

    var body: some View {
        Group {
            let imageSize = analyzeScreenHelper.layout.image.size
            if imageSize.width < imageSize.height {
                VStack(spacing: 0) {
                    InfoListView()
                    SpacingComparatorView()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HStack(spacing: 0) {
                    InfoListView()
                    SpacingComparatorView()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.onReceive(analyzeScreenHelper.$selectedComponent) { component in
            self.component = component
            if let parentId = component?.parent {
                self.parentComponent = analyzeScreenHelper.layout.components[parentId]
            } else {
                self.parentComponent = nil
            }
            if let childrenIds = component?.children {
                self.childrenComponents = childrenIds.compactMap { analyzeScreenHelper.layout.components[$0] }
            } else {
                self.childrenComponents = []
            }
        }
    }
    
    private func InfoListView() -> some View {
        ScrollView {
            if let component {
                LazyVStack(spacing: 0) {
                    Divider()
                    DataRow(key: "Id", value: component.resourceId) { copy(component.resourceId) }
                    Divider()
                    DataRow(key: "Accessibility Class", value: component.accessibilityClass) { copy(component.accessibilityClass) }
                    Divider()
                    if let boundsDp = component.boundsDp {
                        DataRow(key: "Size", value: "w:\(component.bounds.width) [\(String(format: "%.1f", boundsDp.width))dp], h: \(component.bounds.height) [\(String(format: "%.1f", boundsDp.height))dp]")
                        Divider()
                        DataRow(key: "Absolute Position", value: "x: \(component.bounds.minX) [\(String(format: "%.1f", boundsDp.minX))dp], y: \(component.bounds.minY) [\(String(format: "%.1f", boundsDp.minY))dp]")
                        Divider()
                    } else {
                        DataRow(key: "Size", value: "w:\(component.bounds.width), h: \(component.bounds.height)")
                        Divider()
                        DataRow(key: "Absolute Position", value: "x: \(component.bounds.minX), y: \(component.bounds.minY)")
                        Divider()
                    }
                    if let clickable = component.clickable {
                        DataRow(key: "Clickable", value: clickable)
                        Divider()
                    }
                    if let longClickable = component.longClickable {
                        DataRow(key: "Long Clickable", value: longClickable)
                        Divider()
                    }
                    if let scrollable = component.scrollable {
                        DataRow(key: "Scrollable", value: scrollable)
                        Divider()
                    }
                    if let isEnabled = component.isEnabled {
                        DataRow(key: "Enabled", value: isEnabled)
                        Divider()
                    }
                    if let text = component.text, !text.isEmpty {
                        DataRow(key: "Text", value: text) { copy(text) }
                        Divider()
                    }
                    if let hint = component.hint, !hint.isEmpty {
                        DataRow(key: "Hint", value: hint) { copy(hint) }
                        Divider()
                    }
                    if let contentDescription = component.contentDescription, !contentDescription.isEmpty {
                        DataRow(key: "Content Description", value: contentDescription) { copy(contentDescription) }
                        Divider()
                    }
                    DataRow(key: "Parent", value: parentComponent?.getShortLabel() ?? "") {
                        if let parentComponent {
                            analyzeScreenHelper.addTab(component: parentComponent, needSet: true)
                        }
                    }
                    Divider()
                    ChildrenRow()
                    Divider()
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func DataRow(key: LocalizedStringResource, value: String, action: (() -> ())? = nil) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text(key)
                .frame(width: 80, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.7)
                .padding(.all, 5)
            Divider()
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.7)
                .padding(.all, 5)
                .background(.white.opacity(0.00001))
                .onTapGesture {
                    action?()
                }.hoverOpacity(action == nil ? 1 : HOVER_OPACITY)
        }.frame(maxWidth: .infinity)
    }
    
    private func ChildrenRow() -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text("Children")
                .frame(width: 80, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.7)
                .padding(.all, 5)
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                ForEach(childrenComponents) { component in
                    Text(component.getShortLabel())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .padding(.all, 5)
                        .background(.white.opacity(0.00001))
                        .onTapGesture {
                            analyzeScreenHelper.addTab(component: component, needSet: true)
                        }.hoverOpacity()
                    if component != childrenComponents.last {
                        Divider()
                    }
                }
            }.frame(maxWidth: .infinity)
        }.frame(maxWidth: .infinity)
    }
    
    private func SpacingComparatorView() -> some View {
        HStack(spacing: 0) {
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(white: 0.12))
    }
    
}

extension ComponentInfoView {
    
    private func copy(_ string: String) {
        copyToClipboard(string as NSString)
        toastHelper.addToast("Copied to clipboard", style: .clipboard)
    }
    
}
