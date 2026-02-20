//
//  AnalyzeScreenHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 20/2/26.
//

import Foundation
import Combine

class AnalyzeScreenHelper: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    private var cancellables = Set<AnyCancellable>()

    var layout: ComponentLayoutItem
    @Published var selectedComponent: ComponentItem? = nil {
        didSet {
            addTab(component: selectedComponent, needSet: false)
        }
    }
    var selectedComponentList: [ComponentItem] = [] {
        didSet {
            objectWillChange.send()
        }
    }
    var selectedTab: AnalyzeTab = .list {
        didSet {
            switch selectedTab {
            case .list: ()
            case .fixed(let component):
                if selectedComponent != component {
                    selectedComponent = component
                }
            case .temp(let component):
                if selectedComponent != component {
                    selectedComponent = component
                }
            }
            objectWillChange.send()
        }
    }
    var tabs: [AnalyzeTab] = [.list]
    
    init(layout: ComponentLayoutItem) {
        self.layout = layout
        layout.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    func addTab(component: ComponentItem?, needSet: Bool) {
        guard let component else {
            selectedTab = .list
            objectWillChange.send()
            return
        }
        if let existingTab = tabs.first(where: { $0 == AnalyzeTab.fixed(component: component) }) {
            selectedTab = existingTab
            objectWillChange.send()
            return
        }
        let newTab = AnalyzeTab.temp(component: component)
        tabs.removeAll(where: { if case .temp(_) = $0 { return true } else { return false } })
        tabs.append(newTab)
        if needSet {
            selectedTab = newTab
        }
        objectWillChange.send()
    }
    
    func fixTab(tab: AnalyzeTab) {
        if case .temp(let component) = tab {
            tabs.removeAll(where: { if case .temp(_) = $0 { return true } else { return false } })
            tabs.append(.fixed(component: component))
            selectedTab = .fixed(component: component)
            objectWillChange.send()
        }
    }
    
    func unfixTab(tab: AnalyzeTab) {
        if case .fixed(let component) = tab {
            tabs.removeAll(where: { $0 == tab })
            tabs.removeAll(where: { if case .temp(_) = $0 { return true } else { return false } })
            tabs.append(.temp(component: component))
            selectedTab = .temp(component: component)
            objectWillChange.send()
        }
    }
    
}
