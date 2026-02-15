//
//  CommitInfoView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 15/2/26.
//

import SwiftUI

struct CommitInfoView: View {
    
    var diff: [FileDiff]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ListView(diff: diff)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollIndicators(.hidden)
    }
    
    private func ListView(diff: [FileDiff]) -> some View {
        ForEach(Array(diff.enumerated()), id: \.offset) { index, item in
            VStack(spacing: 5) {
                Text(item.file)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                if !item.added.isEmpty {
                    ListDataView(list: Array(item.added.prefix(5)))
                }
                if !item.removed.isEmpty {
                    ListDataView(list: Array(item.removed.prefix(5)))
                }
                if item.added.count > 5 || item.removed.count > 5 {
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
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.12, green: 0.12, blue: 0.12)))
                .padding(.horizontal)
        }
    }
    
    private func ListDataView(list: [String]) -> some View {
        VStack(spacing: 5) {
            ForEach(Array(list.enumerated()), id: \.offset) { index, item in
                Text(item)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .opacity(0.5)
            }
        }.frame(maxWidth: .infinity)
    }
    
}
