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
    @EnvironmentObject var theme: ThemeManager
    @State var component: ComponentItem? = nil
    @State var parentComponent: ComponentItem? = nil
    @State var childrenComponents: [ComponentItem] = []

    var body: some View {
        Group {
            let imageSize = analyzeScreenHelper.layout.image.size
            if imageSize.width < imageSize.height {
                VStack(spacing: 0) {
                    AnalyzeTabView()
                    InfoListView()
                    Spacer(minLength: 0)
                    Divider().opacity(0.3)
                    SpacingComparatorView()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        AnalyzeTabView()
                        InfoListView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    Divider().opacity(0.3)
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
        }.contextMenu {
            if let component {
                if analyzeScreenHelper.disabledComponentList.contains(component) {
                    Button {
                        analyzeScreenHelper.disabledComponentList.remove(component)
                    } label: {
                        Text("Enable Selection")
                    }
                } else {
                    Button {
                        analyzeScreenHelper.disabledComponentList.insert(component)
                    } label: {
                        Text("Disable Selection")
                    }
                }
            }
        }
    }

    private func InfoListView() -> some View {
        ScrollView {
            if let component {
                LazyVStack(spacing: 0) {
                    DataRow(key: "Id", value: component.resourceId) { copy(component.resourceId) }
                    Divider().opacity(0.3)
                    DataRow(key: "Accessibility Class", value: component.accessibilityClass) { copy(component.accessibilityClass) }
                    Divider().opacity(0.3)
                    if let boundsDp = component.boundsDp {
                        DataRow(key: "Size", value: "w:\(component.bounds.width) [\(String(format: "%.1f", boundsDp.width))dp], h: \(component.bounds.height) [\(String(format: "%.1f", boundsDp.height))dp]")
                        Divider().opacity(0.3)
                        DataRow(key: "Absolute Position", value: "x: \(component.bounds.minX) [\(String(format: "%.1f", boundsDp.minX))dp], y: \(component.bounds.minY) [\(String(format: "%.1f", boundsDp.minY))dp]")
                        Divider().opacity(0.3)
                    } else {
                        DataRow(key: "Size", value: "w:\(component.bounds.width), h: \(component.bounds.height)")
                        Divider().opacity(0.3)
                        DataRow(key: "Absolute Position", value: "x: \(component.bounds.minX), y: \(component.bounds.minY)")
                        Divider().opacity(0.3)
                    }
                    if let clickable = component.clickable {
                        DataRow(key: "Clickable", value: clickable)
                        Divider().opacity(0.3)
                    }
                    if let longClickable = component.longClickable {
                        DataRow(key: "Long Clickable", value: longClickable)
                        Divider().opacity(0.3)
                    }
                    if let scrollable = component.scrollable {
                        DataRow(key: "Scrollable", value: scrollable)
                        Divider().opacity(0.3)
                    }
                    if let isEnabled = component.isEnabled {
                        DataRow(key: "Enabled", value: isEnabled)
                        Divider().opacity(0.3)
                    }
                    if let text = component.text, !text.isEmpty {
                        DataRow(key: "Text", value: text) { copy(text) }
                        Divider().opacity(0.3)
                    }
                    if let hint = component.hint, !hint.isEmpty {
                        DataRow(key: "Hint", value: hint) { copy(hint) }
                        Divider().opacity(0.3)
                    }
                    if let contentDescription = component.contentDescription, !contentDescription.isEmpty {
                        DataRow(key: "Content Description", value: contentDescription) { copy(contentDescription) }
                        Divider().opacity(0.3)
                    }
                    DataRow(key: "Parent", value: parentComponent?.getShortLabel() ?? "") {
                        if let parentComponent {
                            analyzeScreenHelper.addTab(component: parentComponent, needSet: true)
                        }
                    }
                    Divider().opacity(0.3)
                    ChildrenRow()
                }.background(theme.backgroundTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.all)
            }
        }.frame(maxWidth: .infinity)
            .scrollIndicators(.never)
    }

    private func DataRow(key: LocalizedStringResource, value: String, action: (() -> ())? = nil) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text(key)
                .frame(width: 80, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.primary)
                .opacity(0.7)
                .padding(.all, 10)
            Divider().opacity(0.3)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.primary)
                .opacity(0.7)
                .padding(.all, 10)
                .background(.primary.opacity(0.00001))
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
                .foregroundStyle(.primary)
                .opacity(0.7)
                .padding(.all, 10)
            Divider().opacity(0.3)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(childrenComponents) { component in
                    Text(component.getShortLabel())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.primary)
                        .opacity(0.7)
                        .padding(.all, 10)
                        .background(.primary.opacity(0.00001))
                        .onTapGesture {
                            analyzeScreenHelper.addTab(component: component, needSet: true)
                        }.hoverOpacity()
                    if component != childrenComponents.last {
                        Divider().opacity(0.3)
                    }
                }
            }.frame(maxWidth: .infinity)
        }.frame(maxWidth: .infinity)
    }

}

extension ComponentInfoView {

    private func copy(_ string: String) {
        copyToClipboard(string as NSString)
        toastHelper.addToast("Copied to clipboard", style: .clipboard)
    }

}
