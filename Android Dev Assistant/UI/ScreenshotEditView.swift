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
    @State var imageSize: CGSize = .zero
    @State var dragCorner: DragCorner? = nil
    
    let PADDING: CGFloat = 15
    let HANDLE_RADIUS: CGFloat = 12
    let MIN_SIZE: CGFloat = 50
    
    enum DragCorner {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case drag(startLeft: CGFloat, startRight: CGFloat, startTop: CGFloat, startBottom: CGFloat)
        case invalid
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                .background(
                    GeometryReader { reader in
                        Color.clear
                           .onAppear {
                               imageSize = reader.size
                           }
                    }
                )
                .padding(.all, PADDING)
                .contentShape(Rectangle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            onDrag(value)
                        }.onEnded { _ in
                            dragCorner = nil
                        }
                )
            CropCanvasView(image: image)
                .allowsHitTesting(false)
        }
    }
    
    private func CropCanvasView(image: NSImage) -> some View {
        Canvas { context, size in
            let actualCanvasWidth = size.width - PADDING * 2
            let actualCanvasHeight = size.height - PADDING * 2
            let canvasRatio = actualCanvasWidth / actualCanvasHeight
            let imageRatio = image.size.width / image.size.height
            var imageHeight: CGFloat = 0
            var imageWidth: CGFloat = 0
            var horizontalPadding: CGFloat = 0
            var verticalPadding: CGFloat = 0
            if imageRatio > canvasRatio {
                // Match width
                imageWidth = actualCanvasWidth
                imageHeight = actualCanvasWidth / imageRatio
                verticalPadding = (actualCanvasHeight - imageHeight) / 2
            } else {
                // Match height
                imageWidth = actualCanvasHeight * imageRatio
                imageHeight = actualCanvasHeight
                horizontalPadding = (actualCanvasWidth - imageWidth) / 2
            }
            // Draw crop rect
            let cropRect = CGRect(
                x: leftCrop * imageWidth + horizontalPadding + PADDING,
                y: topCrop * imageHeight + verticalPadding + PADDING,
                width: (rightCrop - leftCrop) * imageWidth,
                height: (bottomCrop - topCrop) * imageHeight
            )
            context.fill(Path(CGRect(
                x: PADDING + horizontalPadding,
                y: PADDING + verticalPadding,
                width: imageWidth,
                height: imageHeight
            )), with: .color(.black.opacity(0.7)))
            context.blendMode = .destinationOut
            context.fill(Path(cropRect), with: .color(.black))
            context.blendMode = .normal
            context.stroke(Path(cropRect), with: .color(.white))
            // Draw crop handles
            let topLeftHandlePath = Path(ellipseIn: CGRect(
                origin: CGPoint(x: cropRect.minX - HANDLE_RADIUS / 2, y: cropRect.minY - HANDLE_RADIUS / 2),
                size: CGSize(width: HANDLE_RADIUS, height: HANDLE_RADIUS)
            ))
            context.fill(topLeftHandlePath, with: .color(.white))
            let topRightHandlePath = Path(ellipseIn: CGRect(
                origin: CGPoint(x: cropRect.maxX - HANDLE_RADIUS / 2, y: cropRect.minY - HANDLE_RADIUS / 2),
                size: CGSize(width: HANDLE_RADIUS, height: HANDLE_RADIUS)
            ))
            context.fill(topRightHandlePath, with: .color(.white))
            let bottomLeftHandlePath = Path(ellipseIn: CGRect(
                origin: CGPoint(x: cropRect.minX - HANDLE_RADIUS / 2, y: cropRect.maxY - HANDLE_RADIUS / 2),
                size: CGSize(width: HANDLE_RADIUS, height: HANDLE_RADIUS)
            ))
            context.fill(bottomLeftHandlePath, with: .color(.white))
            let bottomRightHandlePath = Path(ellipseIn: CGRect(
                origin: CGPoint(x: cropRect.maxX - HANDLE_RADIUS / 2, y: cropRect.maxY - HANDLE_RADIUS / 2),
                size: CGSize(width: HANDLE_RADIUS, height: HANDLE_RADIUS)
            ))
            context.fill(bottomRightHandlePath, with: .color(.white))
        }
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
                Text(name)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }.frame(width: 80)
                .padding(.all)
        }.buttonStyle(.plain)
    }
    
}

extension ScreenshotEditView {
    
    private func onDrag(_ value: DragGesture.Value) {
        if case .invalid = dragCorner { return }
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        guard imageWidth > 0, imageHeight > 0 else { return }
        if let dragCorner {
            let currentX = value.location.x - PADDING
            let currentY = value.location.y - PADDING
            let minWidth = MIN_SIZE / imageWidth
            let minHeight = MIN_SIZE / imageHeight
            let newX = currentX / imageWidth
            let newY = currentY / imageHeight
            switch dragCorner {
            case .topLeft:
                leftCrop = max(0, min(rightCrop - minWidth, newX))
                topCrop = max(0, min(bottomCrop - minHeight, newY))
            case .topRight:
                rightCrop = min(1, max(leftCrop + minWidth, newX))
                topCrop = max(0, min(bottomCrop - minHeight, newY))
            case .bottomLeft:
                leftCrop = max(0, min(rightCrop - minWidth, newX))
                bottomCrop = min(1, max(topCrop + minHeight, newY))
            case .bottomRight:
                rightCrop = min(1, max(leftCrop + minWidth, newX))
                bottomCrop = min(1, max(topCrop + minHeight, newY))
            case .drag(let startLeft, let startRight, let startTop, let startBottom):
                let cropWidth = startRight - startLeft
                let cropHeight = startBottom - startTop
                let offsetX = value.translation.width / imageWidth
                let offsetY = value.translation.height / imageHeight
                if offsetX > 0 {
                    rightCrop = min(1, startRight + offsetX)
                    leftCrop = rightCrop - cropWidth
                } else {
                    leftCrop = max(0, startLeft - abs(offsetX))
                    rightCrop = leftCrop + cropWidth
                }
                if offsetY > 0 {
                    bottomCrop = min(1, startBottom + offsetY)
                    topCrop = bottomCrop - cropHeight
                } else {
                    topCrop = max(0, startTop - abs(offsetY))
                    bottomCrop = topCrop + cropHeight
                }
            case .invalid: ()
            }
        } else if (imageSize.width > 0 && imageSize.height > 0) {
            let startX = value.startLocation.x - PADDING
            let startY = value.startLocation.y - PADDING
            let actualLeftCrop = leftCrop * imageWidth
            let actualRightCrop = rightCrop * imageWidth
            let actualTopCrop = topCrop * imageHeight
            let actualBottomCrop = bottomCrop * imageHeight
            let radiusSquare = pow(HANDLE_RADIUS, 2)
            // Check top left
            if pow(actualLeftCrop - startX, 2) + pow(actualTopCrop - startY, 2) < radiusSquare {
                dragCorner = .topLeft
                return
            }
            // Check top right
            if pow(actualRightCrop - startX, 2) + pow(actualTopCrop - startY, 2) < radiusSquare {
                dragCorner = .topRight
                return
            }
            // Check bottom left
            if pow(actualLeftCrop - startX, 2) + pow(actualBottomCrop - startY, 2) < radiusSquare {
                dragCorner = .bottomLeft
                return
            }
            // Check bottom right
            if pow(actualRightCrop - startX, 2) + pow(actualBottomCrop - startY, 2) < radiusSquare {
                dragCorner = .bottomRight
                return
            }
            if (startX > 0 && startX < imageWidth && startY > 0 && startY < imageHeight) {
                dragCorner = .drag(startLeft: leftCrop, startRight: rightCrop, startTop: topCrop, startBottom: bottomCrop)
                return
            }
            dragCorner = .invalid
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
    
}
