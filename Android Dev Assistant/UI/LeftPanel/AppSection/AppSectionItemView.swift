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
    @EnvironmentObject var externalToolsHelper: ExternalToolsHelper

    var item: ApkItem
    var isSelected: Bool
    var select: () -> ()
    
    @State var confirmUninstall: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ContentView()
            if (isSelected) {
                TogglesView()
            }
        }.background(Color(red: 0.15, green: 0.15, blue: 0.15))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .alert("Confirm uninstall?", isPresented: $confirmUninstall) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm", role: .destructive) {
                    adbHelper.uninstall(item: item)
                }
            }
    }
    
    private func ContentView() -> some View {
        VStack(spacing: 5) {
            Text(item.name)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.white)
                .foregroundColor(.white)
            Text(item.versionName ?? "-")
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.3)
            Text(item.packageName ?? item.path)
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
                ToggleItemView(icon: "arrow.down.app.fill", label: "Install", isLoading: adbHelper.isInstalling == item.id) { adbHelper.install(item: item) }
                    .disabled(adbHelper.isInstalling != nil || adbHelper.selectedDevice == nil || externalToolsHelper.isExternalToolAdbBlocking)
                ToggleItemView(icon: "folder.fill", label: "Folder") { openFolder(item.path) }
                ToggleItemView(icon: "exclamationmark.arrow.triangle.2.circlepath", label: "Restart") { adbHelper.forceRestart(item: item) }
                ToggleItemView(icon: "xmark.circle.fill", label: "Uninstall", isDangerous: true) { confirmUninstall = true }
                ToggleItemView(icon: "trash.fill", label: "Remove") { apkHelper.removeApk(item) }
            }.padding(.all, 10)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
}
