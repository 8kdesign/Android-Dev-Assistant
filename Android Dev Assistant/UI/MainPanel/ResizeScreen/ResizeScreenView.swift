//
//  ResizeScreenView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 9/2/26.
//

import SwiftUI

struct ResizeScreenView: View {
    
    @EnvironmentObject var uiController: UIController
    @EnvironmentObject var adbHelper: AdbHelper
    @State var originalSize: ScreenSize? = nil
    @State var mockScreenType: MockScreenType = .NORMAL
    
    var body: some View {
        PopupView(title: "Mock Screen", exit: { uiController.showingPopup = nil }) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                    ResizeScreenItemView(type: .NORMAL)
                    ResizeScreenItemView(type: .MOCK_PHONE_23_9)
                    ResizeScreenItemView(type: .MOCK_PHONE_18_9)
                    ResizeScreenItemView(type: .MOCK_PHONE_16_9)
                    ResizeScreenItemView(type: .MOCK_PHONE_SMALL)
                    ResizeScreenItemView(type: .MOCK_FOLD_1_1)
                    ResizeScreenItemView(type: .MOCK_TABLET_16_10)
                    ResizeScreenItemView(type: .MOCK_TABLET_4_3)
                }.padding(.all)
            }
        }.onAppear {
            getCurrentMockType()
        }
    }
    
    private func ResizeScreenItemView(type: MockScreenType) -> some View {
        VStack(spacing: 5) {
            ScreenSizeIconView(type: type)
            Text(type.getLabel())
                .frame(maxWidth: .infinity, alignment: .center)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.7)
        }.padding(.all, 15)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(red: 0.1, green: 0.1, blue: 0.1)))
            .opacity(mockScreenType == type ? 1 : 0.3)
            .onTapGesture {
                setCurrentMockType(type)
            }.hoverOpacity()
    }
    
    private func ScreenSizeIconView(type: MockScreenType) -> some View {
        Canvas { context, size in
            if let originalSize {
                let ratio = type.getPreviewRatio(originalSize: originalSize)
                let height = size.height * (type.isPreviewTablet() ? 0.9 : 0.7)
                let width = height * ratio
                let verticalPadding = (size.height - height) / 2
                let horizontalPadding = (size.width - width) / 2
                context.stroke(
                    Path(roundedRect: CGRect(x: horizontalPadding, y: verticalPadding, width: width, height: height),
                         cornerRadius: CGFloat(size.height) / 15),
                    with: .color(.white),
                    style: .init(lineWidth: 2)
                )
            }
        }.frame(maxWidth: 60, maxHeight: 60)
    }
    
}

extension ResizeScreenView {
    
    func getCurrentMockType() {
        adbHelper.getScreenSize { original, current in
            let type = [MockScreenType.NORMAL, MockScreenType.MOCK_PHONE_16_9, MockScreenType.MOCK_PHONE_18_9,
                        MockScreenType.MOCK_PHONE_23_9, MockScreenType.MOCK_PHONE_SMALL, MockScreenType.MOCK_FOLD_1_1,
                        MockScreenType.MOCK_TABLET_4_3, MockScreenType.MOCK_TABLET_16_10].first {
                let expectedSize = $0.getScreenSize(originalSize: original)
                return expectedSize == current
            }
            Task { @MainActor in
                originalSize = original
                if let type {
                    mockScreenType = type
                } else {
                    mockScreenType = .CUSTOM
                }
            }
        }
    }
    
    func setCurrentMockType(_ type: MockScreenType) {
        guard let originalSize else { return }
        adbHelper.setScreenSize(type: type, originalSize: originalSize) {
            mockScreenType = type
        }
    }
    
}
