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
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(Array(apkHelper.apks.enumerated()), id: \.offset) { index, item in
                    AppSectionItemView(item: item, isSelected: index == selectedIndex) {
                        apkHelper.selectedIndex = index
                    }
                }
            }.padding(.all)
        }.frame(maxWidth: 300, maxHeight: .infinity)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
            .onDrop(of: [.fileURL], delegate: self)
            .onReceive(apkHelper.$selectedIndex) { selectedIndex in
                withAnimation(.linear(duration: 0.2)) {
                    self.selectedIndex = selectedIndex
                }
            }
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
                guard let fileURL = url,
                      fileURL.isFileURL,
                      fileURL.pathExtension == "apk",
                      let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path()) else { return }
                let name = fileURL.lastPathComponent
                let lastModified = attributes[.modificationDate] as? Date ?? Date()
                let item = ApkItem(path: fileURL.path(), name: name, lastModified: lastModified)
                runOnMainThread {
                    apkHelper.addApk(item)
                }
            }
        }
        return true
    }
    
}
