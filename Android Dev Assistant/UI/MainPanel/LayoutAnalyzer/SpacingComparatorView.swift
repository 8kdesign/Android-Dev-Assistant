//
//  SpacingComparatorView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 21/2/26.
//

import SwiftUI

struct SpacingComparatorView: View {
    
    @EnvironmentObject var analyzeScreenHelper: AnalyzeScreenHelper
    @State var positionRelation: ComponentPositionRelation? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(white: 0.12))
            .onChange(of: analyzeScreenHelper.compareComponent) { _ in
                positionRelation = analyzeScreenHelper.compare()                
            }
    }
    
}
