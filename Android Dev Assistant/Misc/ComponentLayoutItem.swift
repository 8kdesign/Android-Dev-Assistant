//
//  ComponentLayoutItem.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 18/2/26.
//

import Foundation
import SwiftyXMLParser
import SwiftUI
import Combine

class ComponentLayoutItem: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var components: [String: ComponentItem] = [:]
    var rootNodes: [ComponentItem] = []
    let image: NSImage
    var isLoaded: Bool = false
    
    @LogicActor init(image: NSImage) async {
        self.image = image
    }
    
    @LogicActor func loadData(data: Data) async {
        let xml = XML.parse(data)
        var queue: [(parent: ComponentItem?, node: XML.Element)] = []
        xml["hierarchy"].element?.childElements.forEach { element in
            if element.name == "node" {
                queue.append((nil, element))
            }
        }
        var components: [String: ComponentItem] = [:]
        var rootNodes: [ComponentItem] = []
        var childrenMap: [String: [String]] = [:]
        while !queue.isEmpty {
            let (parent, element) = queue.removeFirst()
            let item = await ComponentItem(parent: parent, attributes: element.attributes)
            components[item.id] = item
            if let parent {
                if childrenMap[parent.id] == nil {
                    childrenMap[parent.id] = []
                }
                childrenMap[parent.id]?.append(item.id)
            } else {
                rootNodes.append(item)
            }
            element.childElements.forEach { element in
                if element.name == "node" {
                    queue.append((item, element))
                }
            }
        }
        let fixedComponents = components
        let fixedRootNodes = rootNodes
        let fixedChildrenMap = childrenMap
        Task { @MainActor in
            for parent in fixedChildrenMap.keys {
                fixedComponents[parent]?.children = fixedChildrenMap[parent] ?? []
            }
            self.rootNodes = fixedRootNodes
            self.components = fixedComponents
            self.isLoaded = true
            self.objectWillChange.send()
        }
    }
    
    func getOrderedComponents(parent: ComponentItem? = nil, components: [String: ComponentItem], filter: (ComponentItem) -> Bool = { _ in true }) -> [ComponentItem] {
        var result: [ComponentItem] = []
        if let parent {
            parent.children.forEach { id in
                if let item = components[id] {
                    if filter(item) {
                        result.append(item)
                    }
                    result.append(contentsOf: getOrderedComponents(parent: item, components: components, filter: filter))
                }
            }
        } else {
            rootNodes.forEach { item in
                if filter(item) {
                    result.append(item)
                }
                result.append(contentsOf: getOrderedComponents(parent: item, components: components, filter: filter))
            }
        }
        return result
    }
    
    func getComponentsAtPoint(point: CGPoint) -> [ComponentItem] {
        return getOrderedComponents(components: components) { $0.bounds.contains(point) }
    }
    
    func getHighlightComponents(parent: ComponentItem) -> [ComponentItem] {
        var result: [ComponentItem] = []
        var queue: [ComponentItem] = [parent]
        while !queue.isEmpty {
            let item = queue.removeFirst()
            result.append(item)
            item.children.forEach { id in
                if let child = components[id] {
                    queue.append(child)
                }
            }
        }
        return result
    }
    
}

class ComponentItem: Identifiable, Equatable {
    
    let id: String = UUID().uuidString
    let parent: String?
    let resourceId: String
    let componentClass: String
    let bounds: CGRect
    let depth: Int
    
    var children: [String] = []
    
    static func == (lhs: ComponentItem, rhs: ComponentItem) -> Bool {
        lhs.id == rhs.id
    }

    init(parent: ComponentItem?, attributes: [String: String]) {
        self.parent = parent?.id
        if let parent {
            self.depth = parent.depth + 1
        } else {
            self.depth = 0
        }
        self.resourceId = attributes["resource-id"] ?? ""
        self.componentClass = attributes["class"] ?? ""
        self.bounds = parseBounds(attributes["bounds"] ?? "")
    }
    
    func getLabel() -> String {
        var label = ""
        for _ in 0..<depth {
            label += "  "
        }
        if depth > 0 {
            _ = label.drop
            label += "↪ "
        }
        label += componentClass
        if !resourceId.isEmpty {
            label += " (\(resourceId))"
        }
        return label
    }
    
    func getShortLabel() -> String {
        var label = componentClass
        if !resourceId.isEmpty {
            label += " (\(resourceId))"
        }
        return label
    }
    
}

fileprivate func parseBounds(_ string: String) -> CGRect {
    let numbers = string
        .replacingOccurrences(of: "[", with: "")
        .replacingOccurrences(of: "]", with: ",")
        .split(separator: ",")
        .compactMap { Double($0) }
    guard numbers.count == 4 else { return .zero }
    let x = numbers[0]
    let y = numbers[1]
    let width = numbers[2] - x
    let height = numbers[3] - y
    return CGRect(x: x, y: y, width: width, height: height)
}
