//
//  LogsSection.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 1/2/26.
//

import SwiftUI

struct LogsSection: View {
    
    @EnvironmentObject var logHelper: LogHelper
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 5) {
                ForEach(Array(logHelper.logs.enumerated()), id: \.offset) { index, item in
                    Text(item)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(180))
                }
            }.padding(.all)
        }.frame(maxWidth: .infinity)
            .frame(height: 100)
            .rotationEffect(.degrees(180))
            .background(Color(red: 0.05, green: 0.05, blue: 0.05))
            .scrollIndicators(.never)
    }
    
}
