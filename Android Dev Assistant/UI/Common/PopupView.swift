//
//  PopupView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 4/2/26.
//

import SwiftUI

struct PopupView<Content: View>: View {
    
    var title: LocalizedStringResource
    var exit: () -> ()
    @ViewBuilder var content: () -> Content
    @State var isReady: Bool = false
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HeaderView()
                Divider().opacity(0.7)
                content()
            }.frame(maxWidth: 800, maxHeight: 800, alignment: .top)
                .background(Color(red: 0.05, green: 0.05, blue: 0.05))
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .onTapGesture {}
                .padding(.all, 50)
                .scaleEffect(x: isReady ? 1 : 0.3, y: isReady ? 1 : 0.3)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.7))
            .opacity(isReady ? 1 : 0)
            .background(
                EscapeKeyCatcher {
                    close()
                }
            ).onTapGesture {
                close()
            }.onAppear {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isReady = true
                }
            }
    }
    
    private func HeaderView() -> some View {
        HStack {
            Button {
                close()
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .padding(.all, 17)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
            }.buttonStyle(.plain)
                .hoverOpacity()
            Spacer()
            Text(title)
                .font(.title3)
                .foregroundStyle(.white)
                .foregroundColor(.white)
            Spacer()
            Rectangle()
                .fill(.clear)
                .frame(width: 50, height: 50)
        }.frame(maxWidth: .infinity)
            .background(Color(red: 0.07, green: 0.07, blue: 0.07))
    }
    
}

extension PopupView {
    
    private func close() {
        if !isReady { return }
        withAnimation(.easeInOut(duration: 0.1)) {
            isReady = false
        }
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            exit()
        }
    }
    
}
