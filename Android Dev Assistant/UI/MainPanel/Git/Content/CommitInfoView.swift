//
//  CommitInfoView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 15/2/26.
//

import SwiftUI

struct CommitInfoView: View {

    @EnvironmentObject var theme: ThemeManager
    @Binding var selectedFile: GitFileItem?
    var diff: [FileDiff]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ListView(diff: diff)
            }.frame(maxWidth: .infinity)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollIndicators(.never)
    }

    private func ListView(diff: [FileDiff]) -> some View {
        ForEach(Array(diff.enumerated()), id: \.offset) { index, item in
            VStack(spacing: 0) {
                Text(item.file)
                    .font(.body.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(theme.surfaceHighlighted)
                if !(item.added.isEmpty && item.removed.isEmpty) {
                    VStack(spacing: 5) {
                        if !item.added.isEmpty {
                            ListDataView(list: Array(item.added), isAdd: true)
                        }
                        if !item.removed.isEmpty {
                            ListDataView(list: Array(item.removed), isAdd: false)
                        }
                        if item.added.count + item.removed.count > 10 {
                            Text("...")
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundStyle(.primary)
                                .opacity(0.5)
                        }
                    }.padding(.horizontal, 15)
                        .padding(.vertical, 10)
                }
            }.frame(maxWidth: 600)
                .background(theme.backgroundTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onTapGesture {
                    selectedFile = GitFileItem(path: item.file)
                }.hoverOpacity()
                .padding(.horizontal, 15)
        }
    }

    private func ListDataView(list: [String], isAdd: Bool) -> some View {
        VStack(spacing: 5) {
            ForEach(Array(list.enumerated()), id: \.offset) { index, item in
                Text(item)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(getColor(isAdd: isAdd))
                    .opacity(0.5)
            }
        }.frame(maxWidth: .infinity)
    }

}

extension CommitInfoView {
    
    private func getColor(isAdd: Bool) -> Color {
        if theme.isDarkMode {
            return isAdd ? Color(red: 0.6, green: 1, blue: 0.65) : Color(red: 1, green: 0.6, blue: 0.6)
        } else {
            return isAdd ? Color(red: 0, green: 0.5, blue: 0) : Color(red: 0.5, green: 0, blue: 0)
        }
    }
    
}
