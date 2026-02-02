//
//  ToastView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 2/2/26.
//

import SwiftUI

struct ToastView: View {
    
    @EnvironmentObject var toastHelper: ToastHelper
    @State var toasts: [Toast] = []
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(toasts) { toast in
                        ToastItemView(toast: toast)
                    }
                }.padding(10)
            }.frame(maxWidth: 300, maxHeight: .infinity)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            .allowsHitTesting(false)
            .onReceive(toastHelper.$toasts) { toasts in
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.toasts = toasts
                }
            }
    }
    
    private func ToastItemView(toast: Toast) -> some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: toast.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                Text(toast.message)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
            }.padding(.all)
                .background(Capsule().fill(Color(red: 0.1, green: 0.1, blue: 0.1)))
        }.frame(maxWidth: .infinity, alignment: .trailing)
    }
    
}
