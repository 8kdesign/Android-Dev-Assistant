//
//  ContentView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                AppSection()
                VStack(spacing: 0) {
                    DeviceSection()
                    Divider()
                    LogsSection()
                }
            }
            ScreenshotOverlayView()
            ToastView()
        }.frame(minWidth: 900, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
            .background(Color(red: 0.05, green: 0.05, blue: 0.05))
    }
}
