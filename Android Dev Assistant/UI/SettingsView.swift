//
//  SettingsView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 4/2/26.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var isPresented: Bool
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "X"
    
    var body: some View {
        PopupView(title: "Settings", exit: { isPresented = false }) {
            HStack(spacing: 0) {
                InfoView()
                TogglesView()
            }
        }
    }
    
    private func InfoView() -> some View {
        VStack(spacing: 15) {
            Text("Android Dev Assistant")
                .font(.title2)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            Text("by 8K")
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .opacity(0.3)
            Text("v\(appVersion)")
                .font(.callout)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .opacity(0.7)
        }.padding(.all, 30)
            .frame(maxWidth: 200, maxHeight: .infinity, alignment: .top)
            .background(Color(red: 0.08, green: 0.08, blue: 0.08))
    }
    
    private func TogglesView() -> some View {
        VStack {
            
        }.padding(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}
