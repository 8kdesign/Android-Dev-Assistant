//
//  AppSection.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct AppSection: View {
    
    @EnvironmentObject var apkHelper: ApkHelper
    @State var selectedIndex: Int = 0
    
    var body: some View {
        ZStack {
            if (apkHelper.apks.isEmpty) {
                EmptyListView()
            }
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(Array(apkHelper.apks.enumerated()), id: \.offset) { index, item in
                        AppSectionItemView(item: item, isSelected: index == selectedIndex) {
                            apkHelper.selectedIndex = index
                        }
                    }
                }.padding(.all)
            }
        }.frame(maxWidth: 300, maxHeight: .infinity)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
            .onDrop(of: [.fileURL], delegate: self)
            .onReceive(apkHelper.$selectedIndex) { selectedIndex in
                withAnimation(.linear(duration: 0.2)) {
                    self.selectedIndex = selectedIndex
                }
            }
    }
    
    private func EmptyListView() -> some View {
        VStack {
            Text("Drag and drop APK files here to add them.")
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            Image(systemName: "plus.square.dashed")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
        }.padding(.all)
            .opacity(0.5)
    }

}

extension AppSection: DropDelegate {
    
    func performDrop(info: DropInfo) -> Bool {
        info.itemProviders(for: [.fileURL]).forEach { itemProvider in
            itemProvider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { (item, error) in
                let url: URL?
                if let u = item as? URL {
                    url = u
                } else if let u = item as? NSURL {
                    url = u as URL
                } else if let data = item as? Data,
                    let string = String(data: data, encoding: .utf8) {
                    url = URL(string: string)
                } else {
                    url = nil
                }
                guard let url,
                      let item = ApkItem.fromPath(url) else { return }
                Task { @MainActor in
                    apkHelper.addApk(item)
                }
            }
        }
        return true
    }
    
}
