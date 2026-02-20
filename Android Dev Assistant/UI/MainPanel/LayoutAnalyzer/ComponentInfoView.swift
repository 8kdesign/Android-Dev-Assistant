//
//  ComponentInfoView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 20/2/26.
//

import SwiftUI

struct ComponentInfoView: View {
    
    @EnvironmentObject var analyzeScreenHelper: AnalyzeScreenHelper
    var component: ComponentItem

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Divider()
                DataRow(key: "Id", value: component.resourceId)
                Divider()
                DataRow(key: "Accessibility Class", value: component.accessibilityClass)
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
                    DataRow(key: "Text", value: text)
                    Divider()
                }
                if let hint = component.hint, !hint.isEmpty {
                    DataRow(key: "Hint", value: hint)
                    Divider()
                }
                if let contentDescription = component.contentDescription, !contentDescription.isEmpty {
                    DataRow(key: "Content Description", value: contentDescription)
                    Divider()
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func DataRow(key: String, value: String) -> some View {
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
        }.frame(maxWidth: .infinity)
    }
    
}
