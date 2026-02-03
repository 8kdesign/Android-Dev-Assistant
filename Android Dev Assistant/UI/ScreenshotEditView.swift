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
    
    @EnvironmentObject var toastHelper: ToastHelper
    
    @Binding var image: NSImage?
    @State var holdImage: NSImage?
    @State var leftCrop: CGFloat = 0
    @State var rightCrop: CGFloat = 1
    @State var topCrop: CGFloat = 0
    @State var bottomCrop: CGFloat = 1
    @State var isHighlight: Bool = UserDefaultsHelper.getScreenshotEditIsHighlight()
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HeaderView()
                if let holdImage {
                    ScreenshotEditImageView(
                        image: holdImage,
                        leftCrop: $leftCrop,
                        rightCrop: $rightCrop,
                        topCrop: $topCrop,
                        bottomCrop: $bottomCrop,
                        isHighlight: $isHighlight
                    )
                    FooterView(image: holdImage)
                }
            }.frame(maxWidth: 800, maxHeight: 800, alignment: .top)
                .background(RoundedRectangle(cornerRadius: 30).fill(Color(red: 0.05, green: 0.05, blue: 0.05)))
                .onTapGesture {}
                .padding(.all, 50)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.7))
            .onTapGesture {
                image = nil
            }.onAppear {
                holdImage = image
            }.onDisappear {
                holdImage = nil
            }.background(
                EscapeKeyCatcher {
                    image = nil
                }
            ).onChange(of: isHighlight) { value in
                UserDefaultsHelper.setScreenshotEditIsHighlight(value)
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
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
            }.buttonStyle(.plain)
            Spacer()
            Text("Screenshot")
                .font(.title3)
                .foregroundStyle(.white)
                .foregroundColor(.white)
            Spacer()
            Rectangle()
                .fill(.clear)
                .frame(width: 50, height: 50)
        }.frame(maxWidth: .infinity)
    }
    
    private func FooterView(image: NSImage) -> some View {
        HStack {
            Spacer()
            FooterItemView(name: "Copy", icon: "list.clipboard") {
                copyToClipboard(processImage(image))
                toastHelper.addToast("Copied to clipboard", icon: "list.bullet.clipboard")
            }
            FooterItemView(name: "Save", icon: "square.and.arrow.up") {
                ScreenshotHelper.save(image: processImage(image))
            }
            Spacer()
            ModeSwitchView()
            Spacer()
        }.padding(.all)
            .frame(maxWidth: .infinity)
    }
    
    private func FooterItemView(name: LocalizedStringResource, icon: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .padding(.all, 12)
                    .background(Circle().fill(Color(red: 0.15, green: 0.15, blue: 0.15)))
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                Text(name)
                    .font(.callout)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .opacity(0.7)
            }.frame(width: 80)
        }.buttonStyle(.plain)
    }
    
    private func ModeSwitchView() -> some View {
        HStack(spacing: 5) {
            Image(systemName: "crop")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(isHighlight ? 0.5 : 1)
            Toggle(isOn: $isHighlight, label: {})
                .toggleStyle(.switch)
            Image(systemName: "highlighter")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(isHighlight ? 1 : 0.5)
        }
    }
    
}

extension ScreenshotEditView {
    
    private func processImage(_ image: NSImage) -> NSImage {
        if isHighlight {
            return highlightImage(image)
        } else {
            return cropImage(image)
        }
    }
    
    private func cropImage(_ image: NSImage) -> NSImage {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return image }
        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)
        let cropX = originalWidth * leftCrop
        let cropY = originalHeight * topCrop
        let croppedWidth = originalWidth * (rightCrop - leftCrop)
        let croppedHeight = originalHeight * (bottomCrop - topCrop)
        guard let croppedImage = cgImage.cropping(to: CGRect(x: cropX, y: cropY, width: croppedWidth, height: croppedHeight)) else { return image }
        return NSImage(cgImage: croppedImage, size: CGSize(width: croppedWidth, height: croppedHeight))
    }
    
    private func highlightImage(_ image: NSImage) -> NSImage {
        return NSImage(size: image.size, flipped: false) { rect in
            image.draw(in: rect)
            NSColor.red.setStroke()
            let lineWidth: CGFloat = 5
            let originalWidth = image.size.width
            let originalHeight = image.size.height
            let cropX = originalWidth * leftCrop + lineWidth / 2
            let cropY = originalHeight * (1 - bottomCrop) + lineWidth / 2
            let croppedWidth = originalWidth * (rightCrop - leftCrop) - lineWidth
            let croppedHeight = originalHeight * (bottomCrop - topCrop) - lineWidth
            let path = NSBezierPath(rect: NSRect(x: cropX, y: cropY, width: croppedWidth, height: croppedHeight))
            path.lineWidth = 5
            path.stroke()
            return true
        }
    }
    
}
