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
        VStack(spacing: 0) {
            ContentView()
            if (isSelected) {
                TogglesView()
            }
        }.background(Color(red: 0.1, green: 0.1, blue: 0.1))
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    private func ContentView() -> some View {
        VStack(spacing: 7) {
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
                .opacity(0.3)
        }.padding(.all)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.08, green: 0.08, blue: 0.08))
            .opacity(isSelected ? 1 : 0.3)
            .onTapGesture {
                select()
            }
    }
    
    private func TogglesView() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 5) {
                ToggleItemView(icon: "arrow.down.app.fill", label: "Install", isLoading: adbHelper.isInstalling == item.path) { adbHelper.install(item: item) }
                    .disabled(adbHelper.isInstalling != nil || adbHelper.selectedDevice == nil)
                ToggleItemView(icon: "folder.fill", label: "Folder") { openFolder(item) }
                ToggleItemView(icon: "trash.fill", label: "Remove", isDangerous: true) { apkHelper.removeApk(item.path) }
            }.padding(.all, 10)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func ToggleItemView(icon: String, label: LocalizedStringResource, isLoading: Bool = false, isDangerous: Bool = false, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            VStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                } else {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                        .opacity(0.9)
                    Text(label)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                        .opacity(0.9)
                }
            }.frame(width: 60, height: 50)
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: isDangerous ? 0.4 : 0.05, green: 0.05, blue: 0.05))
                ).opacity(0.7)
        }.buttonStyle(.plain)
    }
    
}
