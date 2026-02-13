//
//  Android_Dev_AssistantApp.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import SwiftUI

@main
struct Android_Dev_AssistantApp: App {
    
    @StateObject var uiController: UIController = UIController()
    @StateObject var apkHelper: ApkHelper = ApkHelper()
    @StateObject var adbHelper: AdbHelper = AdbHelper()
    @StateObject var toastHelper: ToastHelper = ToastHelper.shared
    @StateObject var logHelper: LogHelper = LogHelper.shared
    @StateObject var externalToolsHelper: ExternalToolsHelper = ExternalToolsHelper()
    @StateObject var repoHelper: RepoHelper = RepoHelper()
    @StateObject var gitHelper: GitHelper = GitHelper()
    
    var body: some Scene {
        Window("Android Dev Assistant", id: "main") {
            ContentView()
                .environmentObject(uiController)
                .environmentObject(apkHelper)
                .environmentObject(adbHelper)
                .environmentObject(toastHelper)
                .environmentObject(logHelper)
                .environmentObject(externalToolsHelper)
                .environmentObject(repoHelper)
                .environmentObject(gitHelper)
        }
    }
}
