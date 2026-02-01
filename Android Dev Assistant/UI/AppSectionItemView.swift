//
//  AppSectionItemView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import SwiftUI

struct AppSectionItemView: View {
    
    @EnvironmentObject var apkHelper: ApkHelper
    @EnvironmentObject var adbHelper: AdbHelper
    
    var item: ApkItem
    var isSelected: Bool
    var select: () -> ()
    
    var body: some View {
        VStack(spacing: 7) {
            ContentView()
            if (isSelected) {
                TogglesView()
            }
        }.padding(.all, 5)
            .background(RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? Color(red: 0.07, green: 0.07, blue: 0.07) : .clear))
    }
    
    private func ContentView() -> some View {
        VStack(spacing: 7) {
            Text(item.name)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(item.path)
                .lineLimit(1)
                .truncationMode(.head)
                .font(.callout)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(0.3)
        }.padding(.all)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.2, green: 0.2, blue: 0.2)))
            .opacity(isSelected ? 1 : 0.3)
            .onTapGesture {
                select()
            }
    }
    
    private func TogglesView() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 5) {
                ToggleItemView(icon: "arrow.down.app", label: "Install", isLoading: adbHelper.isInstalling == item.path) { adbHelper.install(item: item) }
                    .disabled(adbHelper.isInstalling != nil || adbHelper.selectedDevice == nil)
                ToggleItemView(icon: "folder", label: "Folder") { openFolder(item) }
                ToggleItemView(icon: "trash", label: "Remove", isDangerous: true) { apkHelper.removeApk(item.path) }
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func ToggleItemView(icon: String, label: LocalizedStringResource, isLoading: Bool = false, isDangerous: Bool = false, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            VStack {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.gray)
                } else {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text(label)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }.padding(.all, 10)
                .frame(width: 60, height: 50)
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: isDangerous ? 0.4 : 0.2, green: 0.2, blue: 0.2))
                ).opacity(0.7)
        }.buttonStyle(.plain)
    }
    
}
