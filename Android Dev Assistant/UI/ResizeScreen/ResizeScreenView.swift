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
            VStack {
                HStack {
                    Spacer()
                    ResizeScreenItemView(type: .NORMAL)
                    ResizeScreenItemView(type: .MOCK_PHONE_23_9)
                    ResizeScreenItemView(type: .MOCK_PHONE_18_9)
                    ResizeScreenItemView(type: .MOCK_PHONE_16_9)
                    Spacer()
                }
                HStack {
                    Spacer()
                    ResizeScreenItemView(type: .MOCK_PHONE_SMALL)
                    ResizeScreenItemView(type: .MOCK_FOLD_1_1)
                    ResizeScreenItemView(type: .MOCK_TABLET_16_10)
                    ResizeScreenItemView(type: .MOCK_TABLET_4_3)
                    Spacer()
                }
            }.padding(.all, 20)
        }.onAppear {
            getCurrentMockType()
        }
    }
    
    func ResizeScreenItemView(type: MockScreenType) -> some View {
        VStack {
            Image(systemName: type.isTablet() ? "ipad.rear.camera" : "iphone.rear.camera")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 60, maxHeight: 60)
                .scaleEffect(type.isTablet() ? 1 : 0.8)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.7)
            Text(type.getLabel())
                .frame(maxWidth: .infinity, alignment: .center)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.white)
                .foregroundColor(.white)
                .opacity(0.7)
        }.padding(.all, 15)
            .frame(maxWidth: 200, maxHeight: 200)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(red: 0.1, green: 0.1, blue: 0.1)))
            .opacity(mockScreenType == type ? 1 : 0.3)
            .onTapGesture {
                setCurrentMockType(type)
            }.hoverOpacity()
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
        adbHelper.setScreenSize(type: type, originalSize: originalSize)
        mockScreenType = type
    }
    
}
