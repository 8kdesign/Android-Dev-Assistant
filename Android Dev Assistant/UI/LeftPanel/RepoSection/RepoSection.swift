//
//  RepoSection.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 13/2/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct RepoSection: View {
    
    @EnvironmentObject var repoHelper: RepoHelper
    @State var selectedIndex: Int = 0

    var body: some View {
        ZStack {
            if repoHelper.repos.isEmpty {
                EmptyListView()
            }
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(Array(repoHelper.repos.enumerated()), id: \.offset) { index, item in
                        RepoSectionItemView(item: item, isSelected: index == selectedIndex) {
                            repoHelper.selectedIndex = index
                        }
                    }
                }.padding(.all)
            }.scrollIndicators(.never)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onDrop(of: [.fileURL], delegate: self)
            .onReceive(repoHelper.$selectedIndex) { selectedIndex in
                withAnimation(.linear(duration: 0.2)) {
                    self.selectedIndex = selectedIndex
                }
            }
    }
    
    private func EmptyListView() -> some View {
        VStack {
            Text("Drag and drop repo folders to add them.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.white)
                .foregroundColor(.white)
            Image(systemName: "plus.square.dashed")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(.white)
                .foregroundColor(.white)
        }.padding(.all)
            .opacity(0.5)
    }
    
}

extension RepoSection: DropDelegate {
    
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
                    url = URL(string: string + "/")
                } else {
                    url = nil
                }
                var isDir: ObjCBool = false
                guard let url,
                        FileManager.default.fileExists(atPath: url.path(percentEncoded: false), isDirectory: &isDir),
                        isDir.boolValue else { return }
                let item = RepoItem(url: url)
                Task { @MainActor in
                    repoHelper.addRepo(item)
                }
            }
        }
        return true
    }
    
}
