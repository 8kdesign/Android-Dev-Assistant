//
//  SettingsView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 4/2/26.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var uiController: UIController
    @EnvironmentObject var adbHelper: AdbHelper
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "X"
    
    var body: some View {
        PopupView(title: "Settings", exit: { uiController.showingPopup = nil }) {
            HStack(spacing: 0) {
                InfoView()
                TogglesView()
            }
        }
    }
    
    private func InfoView() -> some View {
        VStack(spacing: 10) {
            Text("Android Dev Assistant")
                .font(.title2)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            Text("v\(appVersion)")
                .font(.body)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .opacity(0.7)
            Spacer()
            Text("by 8K")
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .opacity(0.3)
        }.padding(.all, 30)
            .frame(maxWidth: 200, maxHeight: .infinity, alignment: .top)
            .background(Color(red: 0.08, green: 0.08, blue: 0.08))
    }
    
    private func TogglesView() -> some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                FolderItemView(title: "ADB", path: adbHelper.adbPath)
            }.padding(.all, 20)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func FolderItemView(title: LocalizedStringResource, path: String?) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .opacity(0.7)
            HStack(spacing: 0) {
                Text(path ?? String(localized: "Not found"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .opacity(0.7)
                    .padding(.all)
                Divider()
                Button {
                    if let path {
                        openFolder(path)
                    }
                } label: {
                    Image(systemName: "folder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .padding(.all, 16)
                        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                }.buttonStyle(.plain)
            }.frame(maxWidth: .infinity)
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
}
