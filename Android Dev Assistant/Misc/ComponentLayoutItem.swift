//
//  ComponentLayoutItem.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 18/2/26.
//

import Foundation
import SwiftyXMLParser
import SwiftUI

class ComponentLayoutItem {
    
    let components: [String: ComponentItem]
    
    init?(data: Data) {
        let xml = XML.parse(data)
        var queue: [(parent: String?, node: XML.Element)] = []
        xml["hierarchy"].element?.childElements.forEach { element in
            if element.name == "node" {
                queue.append((nil, element))
            }
        }
        var components: [String: ComponentItem] = [:]
        while !queue.isEmpty {
            let (parent, element) = queue.removeFirst()
            let item = ComponentItem(parent: parent, attributes: element.attributes)
            components[item.id] = item
            if let parent {
                components[parent]?.children.append(item.id)
            }
            element.childElements.forEach { element in
                if element.name == "node" {
                    queue.append((nil, element))
                }
            }
        }
        if !components.isEmpty {
            self.components = components
        } else {
            return nil
        }
    }
    
    func getComponentsAtPoint(point: CGPoint) -> [ComponentItem] {
        return components.values.filter { $0.bounds.contains(point) }
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

class ComponentItem {
    
    let id: String = UUID().uuidString
    let parent: String?
    let resourceId: String
    let componentClass: String
    let bounds: CGRect
    
    var children: [String] = []

    init(parent: String?, attributes: [String: String]) {
        self.parent = parent
        self.resourceId = attributes["resource-id"] ?? ""
        self.componentClass = attributes["class"] ?? ""
        self.bounds = parseBounds(attributes["bounds"] ?? "")
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
