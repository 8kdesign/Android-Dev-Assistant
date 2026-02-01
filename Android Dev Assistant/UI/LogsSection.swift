//
//  LogsSection.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 1/2/26.
//

import SwiftUI

struct LogsSection: View {
    
    @EnvironmentObject var adbHelper: AdbHelper
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 5) {
                ForEach(Array(adbHelper.logs.enumerated()), id: \.offset) { index, item in
                    Text(item)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                }
            }.padding(.all)
        }.frame(maxWidth: .infinity, alignment: .topLeading)
            .frame(height: 100)
            .background(.black)
    }
    
}
