//
//  ScreenshotOverlayView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 1/2/26.
//

import SwiftUI

struct ScreenshotOverlayView: View {
    
    @EnvironmentObject var adbHelper: AdbHelper
    @State var isShowing: Bool = false
    @State var image: NSImage? = nil
    @State var editingImage: NSImage? = nil
    @State var timer: Timer? = nil
    
    var body: some View {
        VStack {
            if let image {
                Button {
                    editingImage = image
                    hideCurrentImage {}
                } label: {
                    ImageView(image: image)
                        .padding(.all, 5)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }.padding(.all, 20)
                    .buttonStyle(.plain)
                    .offset(x: isShowing ? 0 : 100)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .onReceive(adbHelper.$screenshotImage) { image in
                if let image {
                    adbHelper.screenshotImage = nil
                    hideCurrentImage {
                        showImage(image)
                    }
                }
            }.onDisappear {
                timer?.invalidate()
                timer = nil
                isShowing = false
                image = nil
                editingImage = nil
            }.sheet(isPresented: Binding(get: { editingImage != nil }, set: { if !$0 { editingImage = nil } })) {
                ScreenshotEditView(image: $editingImage)
            }
    }
    
    @ViewBuilder
    private func ImageView(image: NSImage) -> some View {
        if image.size.width > image.size.height {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 80)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        } else {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 80)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
    
}

extension ScreenshotOverlayView {
    
    @MainActor private func hideCurrentImage(callback: @escaping () -> ()) {
        timer?.invalidate()
        timer = nil
        if !isShowing {
            callback()
            return
        }
        withAnimation(.easeInOut(duration: 0.1)) {
            isShowing = false
        }
        runOnLogicThread(delayDuration: 0.1) {
            Task { @MainActor in
                self.image = nil
                callback()
            }
        }
    }
    
    @MainActor private func showImage(_ image: NSImage) {
        self.image = image
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowing = true
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            Task { @MainActor in
                hideCurrentImage {}
            }
        }
    }
    
}
