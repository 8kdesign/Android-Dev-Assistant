//
//  LogsSection.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 1/2/26.
//

import SwiftUI

struct LogsSection: View {

    @EnvironmentObject var logHelper: LogHelper
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 5) {
                ForEach(Array(logHelper.logs.enumerated()), id: \.offset) { index, item in
                    Text(item)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.primary)
                        .rotationEffect(.degrees(180))
                }
            }.padding(.all)
        }.frame(maxWidth: .infinity)
            .frame(height: 100)
            .rotationEffect(.degrees(180))
            .background(theme.backgroundSecondary)
            .scrollIndicators(.never)
    }

}
