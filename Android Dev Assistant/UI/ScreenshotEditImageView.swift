//
//  ScreenshotEditImageView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 2/2/26.
//

import SwiftUI

struct ScreenshotEditImageView: View {
    
    var image: NSImage
    
    @Binding var leftCrop: CGFloat
    @Binding var rightCrop: CGFloat
    @Binding var topCrop: CGFloat
    @Binding var bottomCrop: CGFloat
    @Binding var isHighlight: Bool
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
                ).frame(maxWidth: .infinity, maxHeight: .infinity)
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
            let strokeColor: Color = isHighlight ? .red : .white
            if !isHighlight {
                context.fill(Path(CGRect(
                    x: PADDING + horizontalPadding,
                    y: PADDING + verticalPadding,
                    width: imageWidth,
                    height: imageHeight
                )), with: .color(.black.opacity(0.7)))
                context.blendMode = .destinationOut
                context.fill(Path(cropRect), with: .color(.black))
                context.blendMode = .normal
            }
            context.stroke(Path(cropRect), with: .color(strokeColor))
            // Draw crop handles
            let topLeftHandlePath = Path(ellipseIn: CGRect(
                origin: CGPoint(x: cropRect.minX - HANDLE_RADIUS / 2, y: cropRect.minY - HANDLE_RADIUS / 2),
                size: CGSize(width: HANDLE_RADIUS, height: HANDLE_RADIUS)
            ))
            context.fill(topLeftHandlePath, with: .color(strokeColor))
            let topRightHandlePath = Path(ellipseIn: CGRect(
                origin: CGPoint(x: cropRect.maxX - HANDLE_RADIUS / 2, y: cropRect.minY - HANDLE_RADIUS / 2),
                size: CGSize(width: HANDLE_RADIUS, height: HANDLE_RADIUS)
            ))
            context.fill(topRightHandlePath, with: .color(strokeColor))
            let bottomLeftHandlePath = Path(ellipseIn: CGRect(
                origin: CGPoint(x: cropRect.minX - HANDLE_RADIUS / 2, y: cropRect.maxY - HANDLE_RADIUS / 2),
                size: CGSize(width: HANDLE_RADIUS, height: HANDLE_RADIUS)
            ))
            context.fill(bottomLeftHandlePath, with: .color(strokeColor))
            let bottomRightHandlePath = Path(ellipseIn: CGRect(
                origin: CGPoint(x: cropRect.maxX - HANDLE_RADIUS / 2, y: cropRect.maxY - HANDLE_RADIUS / 2),
                size: CGSize(width: HANDLE_RADIUS, height: HANDLE_RADIUS)
            ))
            context.fill(bottomRightHandlePath, with: .color(strokeColor))
        }
    }
    
}

extension ScreenshotEditImageView {
    
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
    
}
