//
//  ComponentInfoView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 20/2/26.
//

import SwiftUI

struct ComponentInfoView: View {
    
    @EnvironmentObject var analyzeScreenHelper: AnalyzeScreenHelper
    var item: ComponentItem

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Divider()
                DataRow(key: "Id", value: item.resourceId)
                Divider()
                DataRow(key: "Class", value: item.componentClass)
                Divider()
                DataRow(key: "Size", value: "\(item.bounds.width) x \(item.bounds.height)")
                Divider()
                DataRow(key: "Absolute Position", value: "x: \(item.bounds.minX), y: \(item.bounds.minY)")
                Divider()
                if let clickable = item.clickable {
                    DataRow(key: "Clickable", value: clickable)
                    Divider()
                }
                if let longClickable = item.longClickable {
                    DataRow(key: "Long Clickable", value: longClickable)
                    Divider()
                }
                if let scrollable = item.scrollable {
                    DataRow(key: "Scrollable", value: scrollable)
                    Divider()
                }
                if let isEnabled = item.isEnabled {
                    DataRow(key: "Enabled", value: isEnabled)
                    Divider()
                }
                if let text = item.text, !text.isEmpty {
                    DataRow(key: "Text", value: text)
                    Divider()
                }
                if let hint = item.hint, !hint.isEmpty {
                    DataRow(key: "Hint", value: hint)
                    Divider()
                }
                if let contentDescription = item.contentDescription, !contentDescription.isEmpty {
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
