//
//  ScreenshotEditView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 1/2/26.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ScreenshotEditView: View {
    
    @Binding var image: NSImage?
    @State var holdImage: NSImage?
    
    var body: some View {
        VStack {
            HeaderView()
            if let holdImage {
                ImageEditArea(image: holdImage)
                FooterView(image: holdImage)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(red: 0.05, green: 0.05, blue: 0.05))
            .onAppear {
                holdImage = image
            }.onDisappear {
                holdImage = nil
            }
    }
    
    private func HeaderView() -> some View {
        HStack {
            Button {
                image = nil
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .padding(.all, 17)
            }.buttonStyle(.plain)
            Spacer()
            Text("Screenshot")
            Spacer()
            Rectangle()
                .fill(.clear)
                .frame(width: 50, height: 50)
        }.frame(maxWidth: .infinity)
    }
    
    private func ImageEditArea(image: NSImage) -> some View {
        ZStack {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
        }
    }
    
    private func FooterView(image: NSImage) -> some View {
        HStack {
            Spacer()
            FooterItemView(name: "Copy", icon: "list.clipboard") {
                ScreenshotHelper.copyToClipboard(image: image)
            }
            FooterItemView(name: "Save", icon: "square.and.arrow.down") {
                ScreenshotHelper.save(image: image)
            }
            Spacer()
        }.frame(maxWidth: .infinity)
    }
    
    private func FooterItemView(name: String, icon: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .padding(.all, 12)
                    .background(Circle().fill(Color(red: 0.15, green: 0.15, blue: 0.15)))
                Text(name)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }.frame(width: 80)
                .padding(.all)
        }.buttonStyle(.plain)
    }
    
}
