//
//  RepoHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 13/2/26.
//

import Foundation
import Combine

class RepoHelper: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()

    var repos: [RepoItem] = [] {
        didSet {
            if (selectedIndex >= repos.count) {
                selectedIndex = max(0, repos.count - 1)
            }
            selectedRepo = repos[safe: selectedIndex]
        }
    }
    @Published var selectedIndex: Int = 0 {
        didSet {
            selectedRepo = repos[safe: selectedIndex]
        }
    }
    @Published var selectedRepo: RepoItem? = nil
    
    init() {
        runOnLogicThread {
            let items = StorageHelper.shared.getRepoItems()
            Task { @MainActor in
                self.repos = items
                self.objectWillChange.send()
            }
        }
    }

    @MainActor func addRepo(_ item: RepoItem) {
        if repos.contains(where: { $0.id == item.id }) { return }
        repos.append(item)
        repos.sort(by: { $0.name < $1.name })
        runOnLogicThread {
            StorageHelper.shared.addRepoItem(await item.path)
        }
        objectWillChange.send()
    }
    
    @MainActor func removeRepo(_ item: RepoItem) {
        repos.removeAll(where: { $0.id == item.id })
        runOnLogicThread {
            StorageHelper.shared.removeRepoItem(await item.path)
        }
        objectWillChange.send()
    }
    
}
