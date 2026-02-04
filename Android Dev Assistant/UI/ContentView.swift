//
//  ContentView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var externalTool: ExternalToolsHelper
    @State var showSettings: Bool = false
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    AppSection()
//                    BottomTogglesSection(showSettings: $showSettings)
                }.frame(maxWidth: 300, maxHeight: .infinity)
                    .background(Color(red: 0.03, green: 0.03, blue: 0.03))
                Divider().opacity(0.7)
                VStack(spacing: 0) {
                    DeviceSection()
                    Divider().opacity(0.7)
                    LogsSection()
                }
            }
            ScreenshotOverlayView()
            if showSettings {
                SettingsView(isPresented: $showSettings)
            }
            ToastView()
        }.frame(minWidth: 900, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
            .opacity(externalTool.isExternalToolAdbBlocking ? 0.3 : 1)
            .background(Color(red: 0.07, green: 0.07, blue: 0.07))
            .allowsHitTesting(!externalTool.isExternalToolAdbBlocking)
    }
}
