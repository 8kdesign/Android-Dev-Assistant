//
//  CommitInfoView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 15/2/26.
//

import SwiftUI

struct CommitInfoView: View {
    
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
            VStack(spacing: 5) {
                Text(item.file)
                    .font(.body.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
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
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                        .opacity(0.5)
                }
            }.padding(.all)
                .frame(maxWidth: 600)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.12, green: 0.12, blue: 0.12)))
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
                    .foregroundStyle(isAdd ? Color(red: 0.6, green: 1, blue: 0.65) : Color(red: 1, green: 0.6, blue: 0.6))
                    .foregroundColor(.white)
                    .opacity(0.5)
            }
        }.frame(maxWidth: .infinity)
    }
    
}
