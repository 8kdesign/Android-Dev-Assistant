//
//  VersionHelper.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 25/2/26.
//

import Foundation
import Combine

class VersionHelper: ObservableObject {
    
    var objectWillChange = ObservableObjectPublisher()
    
    var isUpToDate: Bool = true
    
    init() {
        checkVersion()
    }
    
    func checkVersion() {
        guard let url = URL(string: "https://api.github.com/repos/8kdesign/Android-Dev-Assistant/releases/latest") else { return }
        runOnLogicThread {
            var request = URLRequest(url: url)
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data else { return }
                Task.init { @MainActor in
                    guard let release = try? JSONDecoder().decode(GitHubRelease.self, from: data),
                          let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
                    let latestVersion = String(release.tag_name.dropFirst())
                    self.isUpToDate = !self.isVersionGreater(latestVersion, greaterThan: currentVersion)
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }
    
    struct GitHubRelease: Decodable {
        let tag_name: String
        let html_url: String
    }
    
    func isVersionGreater(_ v1: String, greaterThan v2: String) -> Bool {
        let parts1 = v1.split(separator: ".").map { Int($0) ?? 0 }
        let parts2 = v2.split(separator: ".").map { Int($0) ?? 0 }
        let maxLength = max(parts1.count, parts2.count)
        for i in 0..<maxLength {
            let p1 = i < parts1.count ? parts1[i] : 0
            let p2 = i < parts2.count ? parts2[i] : 0
            if p1 > p2 { return true }
            if p1 < p2 { return false }
        }
        return false // equal
    }
    
}
