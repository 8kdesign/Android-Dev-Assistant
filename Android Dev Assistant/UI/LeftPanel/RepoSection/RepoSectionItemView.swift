//
//  RepoSectionItemView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 13/2/26.
//

import SwiftUI

struct RepoSectionItemView: View {
    
    @EnvironmentObject var repoHelper: RepoHelper
    
    var item: RepoItem
    var isSelected: Bool
    var select: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            ContentView()
            if (isSelected) {
                TogglesView()
            }
        }.background(Color(red: 0.15, green: 0.15, blue: 0.15))
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    private func ContentView() -> some View {
        VStack(spacing: 5) {
            Text(item.name)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.white)
                .foregroundColor(.white)
            Text(item.path)
                .lineLimit(1)
                .truncationMode(.head)
                .font(.callout)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.5)
        }.padding(.all)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
            .opacity(isSelected ? 1 : 0.3)
            .onTapGesture {
                select()
            }
    }
    
    private func TogglesView() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 5) {
                ToggleItemView(icon: "folder.fill", label: "Folder") { openFolder(item.path) }
                ToggleItemView(icon: "trash.fill", label: "Remove") { repoHelper.removeRepo(item) }
            }.padding(.all, 10)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
}
