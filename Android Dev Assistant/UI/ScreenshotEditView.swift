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
    @State var leftCrop: CGFloat = 0
    @State var rightCrop: CGFloat = 1
    @State var topCrop: CGFloat = 0
    @State var bottomCrop: CGFloat = 1
    
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
                        bottomCrop: $bottomCrop
                    )
                    FooterView(image: holdImage)
                }
            }.frame(maxWidth: 600, maxHeight: 600, alignment: .top)
                .background(RoundedRectangle(cornerRadius: 30).fill(Color(red: 0.05, green: 0.05, blue: 0.05)))
                .onTapGesture {}
                .padding(.all, 50)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.7))
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
            )
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
                copyToClipboard(cropImage(image))
            }
            FooterItemView(name: "Save", icon: "square.and.arrow.up") {
                ScreenshotHelper.save(image: cropImage(image))
            }
            Spacer()
        }.frame(maxWidth: .infinity)
    }
    
    private func FooterItemView(name: LocalizedStringResource, icon: String, action: @escaping () -> ()) -> some View {
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
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                Text(name)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
            }.frame(width: 80)
                .padding(.all)
        }.buttonStyle(.plain)
    }
    
}

extension ScreenshotEditView {
    
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
    
}
